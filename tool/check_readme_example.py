#!/usr/bin/env python3
"""Compile and run the README's actual app-builder example with Flutter.

The two user-supplied brand widgets have small stand-ins. This verifies the
documented public API and app wiring, not those widgets' visual appearance.
All generated files live in a temporary consumer package.
"""

import argparse
import json
import re
import subprocess
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--flutter", default="flutter", help="Flutter executable")
    parser.add_argument("--repository", type=Path,
                        default=Path(__file__).resolve().parent.parent)
    args = parser.parse_args()
    root = args.repository.resolve()
    snippets = re.findall(r"```dart\n([\s\S]*?)\n```", (root / "README.md").read_text())
    if not snippets or "Widget build(BuildContext context)" not in snippets[0]:
        parser.error("README.md: expected the documented Widget build example")
    with tempfile.TemporaryDirectory(prefix="hidden-logo-readme-") as directory:
        consumer = Path(directory)
        # JSON-style quoted paths are valid YAML scalar strings as well.
        (consumer / "pubspec.yaml").write_text(
            "name: readme_example_check\npublish_to: none\n"
            "environment:\n  sdk: '>=3.0.0 <4.0.0'\n"
            "dependencies:\n  flutter:\n    sdk: flutter\n  hidden_logo:\n"
            f"    path: {json.dumps(str(root))}\n"
            "dev_dependencies:\n  flutter_test:\n    sdk: flutter\n"
        )
        (consumer / "test").mkdir()
        harness = r"""
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/device_info_service.dart';

class ReadmeApp extends StatelessWidget {
  const ReadmeApp({super.key});
  // README_EXAMPLE
}

class MyNotchLogoBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text('Notch brand');
}

class MyDynamicIslandLogoBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text('Island brand');
}

void main() {
  for (final identifier in ['iPhone13,2', 'iPhone19,2']) {
    testWidgets('README usage builds on $identifier', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      DeviceInfoService.setMockMachineIdentifier(identifier);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.display.size = const Size(400, 800);
      try {
        await tester.pumpWidget(const ReadmeApp());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('App content'), findsOneWidget);
        expect(find.text(identifier == 'iPhone13,2' ? 'Notch brand' : 'Island brand'),
            findsOneWidget);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        debugDefaultTargetPlatformOverride = null;
        DeviceInfoService.reset();
        tester.view.reset();
        tester.view.display.reset();
      }
    });
  }
}
"""
        (consumer / "test/readme_test.dart").write_text(
            harness.replace("// README_EXAMPLE", snippets[0])
        )
        return subprocess.run([args.flutter, "test", "test/readme_test.dart"],
                              cwd=consumer, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
