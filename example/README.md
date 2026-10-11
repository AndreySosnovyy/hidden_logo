# hidden_logo example

A Cupertino app with separate notch and Dynamic Island logos.

## Run

From this directory, with Flutter 3.24.0 or later:

```sh
flutter pub get
flutter devices
flutter run -d <device-id>
```

For iOS, complete Xcode setup and install a simulator runtime. Use CocoaPods with
Flutter 3.24 or Swift Package Manager with Flutter 3.27 or later on stable.
A physical iPhone also needs a development team and signing configured in Xcode.

## Preview the logo

On a supported iPhone simulator in portrait, take a screenshot using
Device → Trigger Screenshot. Compare it with the masked simulator view to check
that the logo fits behind the cutout. Rotate to landscape to check that it hides.

The example uses `LogoVisibilityMode.always`. Change `visibilityMode` in
[main.dart](lib/main.dart) to try `onlyInBackground`; app-switcher capture timing
needs a check on a physical device. Other platforms display only the app body.

[Package usage and supported models](../README.md) ·
[Development and build checks](../CONTRIBUTING.md)
