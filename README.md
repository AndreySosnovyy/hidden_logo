# hidden_logo

Place a brand widget behind an iPhone's notch or Dynamic Island. It stays hidden
in normal portrait use and can appear in screenshots or screen mirroring.

![hidden_logo preview](readme_welcome_image.png)

<p align="left">
<a href="https://pub.dev/packages/hidden_logo"><img src="https://img.shields.io/pub/v/hidden_logo.svg?style=flat&colorB=blue" alt="Pub"></a>
<a href="https://github.com/AndreySosnovyy/hidden_logo"><img src="https://img.shields.io/github/stars/andreysosnovyy/hidden_logo.svg?&style=flat&logo=github&color=red&label=stars" alt="Star on Github"></a>
</p>

## Requirements

- Flutter ≥3.24.0
- iOS ≥13.0
- Swift Package Manager: Flutter ≥3.27.0 (stable); CocoaPods works from Flutter 3.24.0.

## Usage

Add `hidden_logo` to your dependencies and import
`package:hidden_logo/hidden_logo.dart`. Place it in your app builder:

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    builder: (context, child) => HiddenLogo(
      body: child!,
      notchBuilder: (context, constraints) => MyNotchLogoBuilder(),
      dynamicIslandBuilder: (context, constraints) => MyDynamicIslandLogoBuilder(),
    ),
    home: const Scaffold(
      body: Center(child: Text('App content')),
    ),
  );
}
```

Replace `MyNotchLogoBuilder` and `MyDynamicIslandLogoBuilder` with your own widgets.
Use the supplied maximum constraints to size them and round the notch logo's
corners. Dynamic Island corners are rounded automatically; Display Zoom scaling
is handled by the plugin.

The logo is decorative and appears only in portrait on supported iPhones.
Other devices display the app body without a logo.

- Set `isVisible: false` to hide the logo, for example during a splash screen.
- `LogoVisibilityMode.onlyInBackground` hides it while the app is resumed.
  Screenshot and app-switcher capture timing depends on iOS.
- Use a screenshot to preview the logo. Keep interactive or sensitive content
  in the app body.

## Supported iPhones

| Notch      | Dynamic Island |
|:-----------|:---------------|
| X          | 14 Pro         |
| XR         | 14 Pro Max     |
| XS         | 15             |
| XS Max     | 15 Plus        |
| 11         | 15 Pro         |
| 11 Pro     | 15 Pro Max     |
| 11 Pro Max | 16             |
| 12         | 16 Plus        |
| 12 Mini    | 16 Pro         |
| 12 Pro     | 16 Pro Max     |
| 12 Pro Max | 17             |
| 13         | Air            |
| 13 Mini    | 17 Pro         |
| 13 Pro     | 17 Pro Max     |
| 13 Pro Max | 18 Pro         |
| 14         | 18 Pro Max     |
| 14 Plus    |                |
| 16e        |                |
| 17e        |                |


Unknown models, including iPhone Duo, display no logo until explicitly supported.

## Links

[Example](example/README.md) · [Changelog](CHANGELOG.md) ·
[Contributing](CONTRIBUTING.md) ·
[Report an issue](https://github.com/AndreySosnovyy/hidden_logo/issues/new)
