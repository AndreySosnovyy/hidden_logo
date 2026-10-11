# Contributing

Open an [issue](https://github.com/AndreySosnovyy/hidden_logo/issues/new) or a pull
request describing the change. For new devices, follow the
[device support guide](adding_new_iphones_support.md).

## Local checks

Use Flutter 3.24.0 or later and Python 3.9 or later (standard library only).
From the repository root:

```sh
flutter pub get
python3 tool/check_repository.py
python3 tool/check_readme_example.py
flutter analyze
flutter test
flutter pub publish --dry-run
```

The repository checker compares documentation with device and native manifests,
validates local documentation links and checks resource references. The README
checker compiles and runs its usage example with stand-ins for the two brand widgets.

Use Flutter 3.24.0's Dart formatter to match CI:

```sh
dart format --output=none --set-exit-if-changed .
```

## Example builds and CI

From `example/`, build the relevant target with `flutter build apk --debug`,
`flutter build web --release`, `flutter build ios --release --no-codesign`, or
`flutter build <macos|linux|windows> --release` on the matching host with its
Flutter toolchain installed. See the [example guide](example/README.md) for running it.

CI checks the minimum and current stable Flutter versions on Android, Web,
Linux, Windows and macOS. iOS uses CocoaPods from Flutter 3.24.0 and Swift Package
Manager from Flutter 3.27.0 on stable. The minimum Apple builds use Xcode 16.4;
the minimum Windows build uses Visual Studio 2022. Newer native toolchains may
require higher example deployment targets than those declared by the plugin.
The workflow also validates GitHub Actions expressions with actionlint.

## Documentation and releases

Keep README focused on installation, usage and compatibility. Put contributor
instructions here, example instructions in `example/README.md`, and release
history in `CHANGELOG.md`. Keep package and podspec versions synchronized when
preparing a release. Publish only after the changes and checks are approved.
