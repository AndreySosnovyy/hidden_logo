#!/usr/bin/env python3
"""Check documented contracts and source manifests without third-party packages.

This checks the repository's authored YAML/Dart layout, not arbitrary YAML or
Dart syntax. Missing or changed declarations fail explicitly instead of silently
skipping a check. It does not prove device geometry or native compilation.
Pass an optional repository path to check a temporary snapshot.
"""

import json
import plistlib
import re
import subprocess
import struct
import sys
import xml.etree.ElementTree as ET
import zlib
from pathlib import Path


class RepositoryCheck:
    def __init__(self, root):
        self.root = root.resolve()
        self.errors = []
        self.checks = 0
        self.png_sizes = {}

    def require(self, condition, message):
        self.checks += 1
        if not condition:
            self.errors.append(message)

    def read(self, relative):
        try:
            return (self.root / relative).read_text()
        except (OSError, UnicodeError) as error:
            self.errors.append(f"{relative}: cannot read source: {error}")
            return ""

    def declaration(self, text, pattern, source, description):
        matches = re.findall(pattern, text, re.MULTILINE)
        self.require(len(matches) == 1,
                     f"{source}: expected exactly one {description}, got {len(matches)}")
        return matches[0] if len(matches) == 1 else None

    def contracts(self):
        pub = self.read("pubspec.yaml")
        example = self.read("example/pubspec.yaml")
        pod = self.read("ios/hidden_logo.podspec")
        spm = self.read("ios/hidden_logo/Package.swift")
        readme = self.read("README.md")
        flutter_pattern = r"^  flutter:\s*['\"]>=([0-9.]+)['\"]\s*$"
        flutter = self.declaration(pub, flutter_pattern, "pubspec.yaml", "Flutter minimum")
        example_flutter = self.declaration(example, flutter_pattern,
                                           "example/pubspec.yaml", "Flutter minimum")
        self.require(flutter == example_flutter and flutter is not None,
                     "example/pubspec.yaml: Flutter minimum must match pubspec.yaml")
        documented_flutter = self.declaration(
            readme, r"^- Flutter ≥([0-9.]+)\s*$", "README.md", "Flutter requirement")
        self.require(flutter == documented_flutter and flutter is not None,
                     "README.md: Flutter requirement must match pubspec.yaml")
        dart_pattern = r"^  sdk:\s*['\"]([^'\"]+)['\"]\s*$"
        dart = self.declaration(pub, dart_pattern, "pubspec.yaml", "Dart constraint")
        example_dart = self.declaration(example, dart_pattern,
                                        "example/pubspec.yaml", "Dart constraint")
        self.require(dart == example_dart and dart is not None,
                     "example/pubspec.yaml: Dart constraint must match pubspec.yaml")
        version = self.declaration(pub, r"^version:\s*(\S+)\s*$",
                                   "pubspec.yaml", "package version")
        pod_version = self.declaration(pod, r"s\.version\s*=\s*'([^']+)'",
                                       "ios/hidden_logo.podspec", "pod version")
        self.require(version == pod_version and version is not None,
                     "ios/hidden_logo.podspec: version must match pubspec.yaml")
        ios = self.declaration(pod, r"s\.platform\s*=\s*:ios,\s*'([0-9.]+)'",
                               "ios/hidden_logo.podspec", "iOS deployment minimum")
        spm_ios = self.declaration(spm, r'\.iOS\("([0-9.]+)"\)',
                                   "ios/hidden_logo/Package.swift", "iOS deployment minimum")
        documented_ios = self.declaration(readme, r"^- iOS ≥([0-9.]+)\s*$",
                                          "README.md", "iOS requirement")
        self.require(ios == spm_ios == documented_ios and ios is not None,
                     "README.md / CocoaPods / SwiftPM: iOS deployment minimum must agree")
        workflow = self.read(".github/workflows/main.yml")
        spm_flutter = self.declaration(
            readme, r"^- Swift Package Manager: Flutter ≥([0-9.]+) \(stable\);",
            "README.md", "Swift Package Manager Flutter minimum")
        pinned_sdks = re.findall(r"flutter-version:\s*'([0-9.]+)'", workflow)
        self.require(flutter is not None and spm_flutter is not None and
                     set(pinned_sdks) == {flutter, spm_flutter},
                     ".github/workflows/main.yml: pinned lanes must match Flutter and stable SPM floors")
        license_file = self.declaration(pod, r":file\s*=>\s*'([^']+)'",
                                        "ios/hidden_logo.podspec", "license file")
        self.require(license_file is not None and
                     (self.root / "ios" / (license_file or "")).is_file(),
                     "ios/hidden_logo.podspec: referenced license file must exist")
        license_type = self.declaration(pod, r":type\s*=>\s*'([^']+)'",
                                        "ios/hidden_logo.podspec", "license type")
        self.require(license_type == "BSD-3-Clause" and
                     self.read("LICENSE").startswith("BSD 3-Clause License\n"),
                     "ios/hidden_logo.podspec: license type must match LICENSE (BSD-3-Clause)")

    def device_table(self):
        source = self.read("lib/src/parser.dart")
        enum = self.declaration(source, r"enum DeviceModel \{([\s\S]*?)^\}",
                                "lib/src/parser.dart", "DeviceModel enum")
        if enum is None:
            return
        members = re.findall(r"^  (iPhone\w+),\s*$", enum, re.MULTILINE)
        self.require(bool(members), "lib/src/parser.dart: no DeviceModel entries parsed")
        getter = self.declaration(source,
                                  r"LogoType get iPhonesLogoType \{([\s\S]*?)^  \}",
                                  "lib/src/parser.dart", "logo type getter")
        if getter is None:
            return
        groups = {}
        pending = []
        for line in getter.splitlines():
            case = re.fullmatch(r"\s*case DeviceModel\.(iPhone\w+):\s*", line)
            result = re.fullmatch(r"\s*return LogoType\.(notch|dynamicIsland);\s*", line)
            if case:
                pending.append(case.group(1))
            elif result:
                for member in pending:
                    self.require(member not in groups,
                                 f"lib/src/parser.dart: duplicate logo type case {member}")
                    groups[member] = result.group(1)
                pending.clear()
        self.require(set(members) == set(groups),
                     "lib/src/parser.dart: every DeviceModel must have one logo type case")
        readme = self.read("README.md")
        section = self.declaration(
            readme, r"^## Supported iPhones\s*([\s\S]*?)(?=^## |\Z)",
            "README.md", "target device table")
        if section is None:
            return
        expected = {re.sub(r"[^a-z0-9]", "", member[6:].lower()): member
                    for member in members}
        seen = set()
        for row in re.findall(r"^\|([^|]*)\|([^|]*)\|\s*$", section, re.MULTILINE):
            if row[0].strip() == "Notch" or row[0].strip().startswith(":"):
                continue
            for cell, logo_type in zip(row, ("notch", "dynamicIsland")):
                label = cell.strip()
                if not label:
                    continue
                member = expected.get(re.sub(r"[^a-z0-9]", "", label.lower()))
                self.require(member is not None, f"README.md: unknown target-table label {label!r}")
                if member is None:
                    continue
                self.require(member not in seen, f"README.md: duplicate target-table model {label!r}")
                self.require(groups.get(member) == logo_type,
                             f"README.md: {label!r} is in the wrong hardware-barrier column")
                seen.add(member)
        self.require(set(members) == seen,
                     f"README.md: target table missing models {sorted(set(members) - seen)}")

    def source_files(self):
        # A snapshot need not contain .git. Avoid generated caches and local
        # evidence in that case; neither belongs to the published source checks.
        excluded = {".git", ".dart_tool", "build", "output", "node_modules", ".gradle",
                    ".build", ".swiftpm", "Pods", ".symlinks", ".plugin_symlinks",
                    "ephemeral", "__pycache__"}
        if (self.root / ".git").exists():
            result = subprocess.run(["git", "-C", str(self.root), "ls-files", "-co",
                                     "--exclude-standard", "-z"],
                                    capture_output=True, check=False)
            self.require(result.returncode == 0, "git ls-files: cannot enumerate source")
            if result.returncode == 0:
                return [self.root / path for path in
                        dict.fromkeys(result.stdout.decode().split("\0")) if path and
                        not excluded.intersection(Path(path).parts)]
        return [path for path in self.root.rglob("*") if path.is_file() and
                not excluded.intersection(path.relative_to(self.root).parts)]

    def png_dimensions(self, path):
        """Check the complete PNG stream, not just its dimension-bearing prefix."""
        if path in self.png_sizes:
            return self.png_sizes[path]
        relative = path.relative_to(self.root)
        data = path.read_bytes()
        dimensions = None
        try:
            if data[:8] != b"\x89PNG\r\n\x1a\n":
                raise ValueError("invalid PNG signature")
            offset = 8
            compressed = bytearray()
            ended = False
            while offset < len(data):
                if len(data) - offset < 12:
                    raise ValueError("truncated PNG chunk")
                length, kind = struct.unpack(">I4s", data[offset:offset + 8])
                end = offset + 12 + length
                if end > len(data):
                    raise ValueError("truncated PNG chunk payload")
                payload = data[offset + 8:end - 4]
                crc = struct.unpack(">I", data[end - 4:end])[0]
                if zlib.crc32(kind + payload) != crc:
                    raise ValueError(f"invalid {kind!r} chunk checksum")
                if offset == 8 and kind != b"IHDR":
                    raise ValueError("IHDR must be the first chunk")
                if kind == b"IHDR":
                    if dimensions is not None or length != 13:
                        raise ValueError("invalid or duplicate IHDR")
                    dimensions = struct.unpack(">II", payload[:8])
                    if not all(dimensions):
                        raise ValueError("zero PNG dimensions")
                    depth, color, compression, filtering, interlace = payload[8:]
                    depths = {0: (1, 2, 4, 8, 16), 2: (8, 16),
                              3: (1, 2, 4, 8), 4: (8, 16), 6: (8, 16)}
                    if (color not in depths or depth not in depths[color] or
                            compression != 0 or filtering != 0 or interlace not in (0, 1)):
                        raise ValueError("invalid PNG encoding parameters")
                elif kind == b"IDAT":
                    compressed.extend(payload)
                elif kind == b"IEND":
                    if length != 0 or end != len(data):
                        raise ValueError("invalid IEND or trailing file data")
                    ended = True
                    break
                offset = end
            if not ended or not compressed:
                raise ValueError("missing IEND or image data")
            decoder = zlib.decompressobj()
            pixels = decoder.decompress(compressed) + decoder.flush()
            if not pixels or not decoder.eof or decoder.unused_data:
                raise ValueError("incomplete or trailing compressed image data")
            channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[color]
            passes = ([(0, 0, 1, 1)] if interlace == 0 else
                      [(0, 0, 8, 8), (4, 0, 8, 8), (0, 4, 4, 8),
                       (2, 0, 4, 4), (0, 2, 2, 4), (1, 0, 2, 2), (0, 1, 1, 2)])
            cursor = 0
            for x, y, step_x, step_y in passes:
                width = max(0, (dimensions[0] - x + step_x - 1) // step_x)
                height = max(0, (dimensions[1] - y + step_y - 1) // step_y)
                if not width or not height:
                    continue
                stride = 1 + (width * channels * depth + 7) // 8
                if cursor + stride * height > len(pixels):
                    raise ValueError("truncated decoded scanlines")
                if any(pixels[cursor + row * stride] > 4 for row in range(height)):
                    raise ValueError("invalid scanline filter")
                cursor += stride * height
            if cursor != len(pixels):
                raise ValueError("extra decoded scanline data")
            self.require(True, f"{relative}: PNG stream integrity")
        except (ValueError, zlib.error) as error:
            self.require(False, f"{relative}: invalid PNG: {error}")
            dimensions = None
        self.png_sizes[path] = dimensions
        return dimensions

    def image_reference(self, owner, item, field):
        filename = item[field]
        path = owner.parent / filename
        relative = owner.relative_to(self.root)
        self.require(path.is_file(), f"{relative}: missing image {filename}")
        if not path.is_file() or path.suffix.lower() != ".png":
            return
        actual = self.png_dimensions(path)
        if actual is None:
            return
        expected = None
        if "size" in item and "scale" in item:
            scale = float(item["scale"].removesuffix("x"))
            expected = tuple(round(float(value) * scale) for value in item["size"].split("x"))
        elif "sizes" in item and re.fullmatch(r"[0-9]+x[0-9]+", item["sizes"]):
            expected = tuple(int(value) for value in item["sizes"].split("x"))
        if expected is not None:
            self.require(actual == expected,
                         f"{relative}: {filename} has pixels {actual}, declared {expected}")

    def resources(self):
        for path in self.source_files():
            relative = path.relative_to(self.root)
            try:
                if path.suffix == ".json":
                    data = json.loads(path.read_text())
                    self.checks += 1
                    if path.name == "Contents.json":
                        for item in data.get("images", []):
                            if item.get("filename"):
                                self.image_reference(path, item, "filename")
                    if relative == Path("example/web/manifest.json"):
                        for icon in data.get("icons", []):
                            self.image_reference(path, icon, "src")
                elif path.suffix in (".plist", ".entitlements"):
                    plistlib.loads(path.read_bytes())
                    self.checks += 1
                elif path.suffix in (".xml", ".xib", ".xcworkspacedata", ".xcscheme"):
                    ET.parse(path)
                    self.checks += 1
                elif path.suffix == ".rc":
                    # Resource-script icon paths are relative to the runner's
                    # source directory and use escaped Windows separators.
                    icons = re.findall(r'^\s*\w+\s+ICON\s+"([^"]+)"',
                                       path.read_text(), re.MULTILINE)
                    for filename in icons:
                        icon = path.parent / filename.replace("\\\\", "/")
                        self.require(icon.is_file(),
                                     f"{relative}: missing icon {filename}")
            except (OSError, ValueError, ET.ParseError, KeyError, TypeError, AttributeError) as error:
                self.errors.append(f"{relative}: invalid source manifest: {error}")
        for doc in ("README.md", "example/README.md", "CONTRIBUTING.md",
                    "adding_new_iphones_support.md", "CHANGELOG.md"):
            for target in re.findall(r"\]\(([^)]+)\)", self.read(doc)):
                if re.match(r"[a-z]+:|#", target):
                    continue
                target = target.split("#", 1)[0]
                local = self.root / Path(doc).parent / target
                self.require(local.is_file(),
                             f"{doc}: missing local documentation reference {target}")
                if local.is_file() and local.suffix.lower() == ".png":
                    self.png_dimensions(local)

    def run(self):
        self.contracts()
        self.device_table()
        self.resources()
        if self.errors:
            for error in self.errors:
                print(f"ERROR: {error}", file=sys.stderr)
            print(f"Repository checks failed: {len(self.errors)} issue(s).", file=sys.stderr)
            return 1
        print(f"Repository metadata and resources: {self.checks} checks passed.")
        return 0


if __name__ == "__main__":
    if len(sys.argv) > 2:
        print("Usage: python3 tool/check_repository.py [repository-path]", file=sys.stderr)
        sys.exit(2)
    root = Path(sys.argv[1]) if len(sys.argv) == 2 else Path(__file__).resolve().parent.parent
    sys.exit(RepositoryCheck(root).run())
