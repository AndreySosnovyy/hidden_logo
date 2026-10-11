# hidden_logo example

This app places a decorative brand logo behind the notch or Dynamic Island using
`HiddenLogo` in `CupertinoApp.builder`. Both builders use the maximum dimensions
provided by the plugin. The notch builder also supplies rounded corners and margins.

The logo appears only in portrait on explicitly supported iPhones. Other platforms
and unknown identifiers display the app body without a logo. The overlay ignores
pointer events, keyboard focus and accessibility semantics.

## Run locally

Use Flutter 3.24.0 or later. From this directory:

```sh
flutter pub get
flutter devices
flutter run -d <device-id>
```

For iOS, install Xcode and its simulator runtime and complete Apple's setup first.
Flutter supports Swift Package Manager and CocoaPods integration for this plugin.
The plugin supports iOS 13 or later; the required deployment target of the example
also depends on your Flutter and Xcode versions. Newer Xcode versions can require
a higher example deployment target without changing the plugin's declared minimum.
Running on a physical iPhone also requires a valid development signing identity
and a development team selected for `Runner` in Xcode. Unsigned simulator builds
do not verify device installation or hardware masks.

## Inspect the logo

The example uses `LogoVisibilityMode.always`. On a supported portrait simulator,
compare its masked onscreen view with a screenshot (Device → Trigger Screenshot).
The screenshot can reveal the logo behind the hardware cutout. Check both the notch
and Dynamic Island builders and rotate the device to confirm the logo disappears
in landscape.

To experiment with `LogoVisibilityMode.onlyInBackground`, set `visibilityMode` in
`main.dart`. This hides the logo while the app is resumed and enables it for other
Flutter lifecycle states, including inactive. An inactive app may still be onscreen;
iOS screenshot and app-switcher capture timing requires manual verification.

## Build examples

```sh
flutter build apk --debug
flutter build web
```

On macOS with the relevant tools installed:

```sh
flutter build ios --release --no-codesign
flutter build macos
```

The macOS deployment target also depends on the installed toolchain. With
Flutter 3.24.0 and Xcode 27, the default example target (macOS 10.14) is rejected.
The local release check passed with command-only overrides to macOS 12 and
arm64; the universal build was blocked by an incompatibility between that
Flutter version's `lipo` invocation and Xcode 27. CI checks the minimum Flutter
version with Xcode 16.4 instead. These overrides are not package requirements.

Linux and Windows desktop builds require the corresponding host platform and
Flutter desktop toolchain. All non-iOS builds intentionally show only the app body.

Package tests and metadata checks run from the parent directory:

```sh
cd ..
python3 tool/check_repository.py
python3 tool/check_readme_example.py
flutter analyze
flutter test
```

See the [package README](../README.md) for the supported models, usage contract,
Display Zoom behavior and the intentional iPhone Duo limitation.
