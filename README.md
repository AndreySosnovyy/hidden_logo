## Features

The **hidden_logo** plugin allows you to add any Flutter widget under the Notch or
the Dynamic Island for iPhones. It can be your brand logo or its simplified version.
The hardware cutout hides the logo during normal portrait use. Screenshots and
screen mirroring can reveal it; app-switcher previews may also include it, depending
on when iOS captures the app.

![readme_welcome_image.png](readme_welcome_image.png)

<p align="left">
<a href="https://pub.dev/packages/hidden_logo"><img src="https://img.shields.io/pub/v/hidden_logo.svg?style=flat&colorB=blue" alt="Pub"></a>
<a href="https://github.com/AndreySosnovyy/hidden_logo"><img src="https://img.shields.io/github/stars/andreysosnovyy/hidden_logo.svg?&style=flat&logo=github&color=red&label=stars" alt="Star on Github"></a>
</p>

❗No additional checks or manually written conditions are required when using `HiddenLogo`:</br>

- **Application running on any other devices not marked as target ones will not be
  affected**. Supported models are listed explicitly below, including iPhone 18 Pro and Pro Max.
  Unknown identifiers keep the app body unchanged and do not draw a logo. </br>
  You can see the [List of Target iPhones](#iphones-hardware-barrier-types-target-devices) separated by hardware barrier
  type (Notch or Dynamic Island) in the table down below.
- It provides **maximum size constraints for the supported models** and clips
  content that paints outside those bounds. Use the supplied constraints and
  suitable rounded corners for notch logos, as described below.
- Corners of your Dynamic Island widget will be **rounded automatically**.
- Your child widget will only be visible in **portrait mode**.
- Logo constraints and Dynamic Island positioning adapt to iOS **Display Zoom**.
  Use the supplied constraints when sizing your logo, and place `HiddenLogo` at
  the full-screen app level, as shown below.

## Requirements

- Flutter ≥3.24.0
- iOS ≥13.0
- Swift Package Manager and CocoaPods integrations are supported; choose the
  integration through your Flutter toolchain settings

## Usage

Wrap your `MaterialApp` or `CupertinoApp` with `HiddenLogo` widget or define
its `builder` function. Prefer the app builder when your logo needs inherited
theme, text direction or localization. Then provide 2 builders for 2 cases:
iPhones with Notch and the ones with Dynamic Island.
In the example below, `MyNotchLogoBuilder` and `MyDynamicIslandLogoBuilder` are
your own widgets. `home` provides the app content wrapped by `child`.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    builder: (context, child) {
      return HiddenLogo(
        body: child!,
        notchBuilder: (context, constraints) {
          return MyNotchLogoBuilder();
        },
        dynamicIslandBuilder: (context, constraints) {
          return MyDynamicIslandLogoBuilder();
        },
      );
    },
    home: const Scaffold(
      body: Center(child: Text('App content')),
    ),
  );
}
```

The size of your brand logo can be adaptive thanks to constraints provided
by the widget. They define `maxWidth` and `maxHeight` where you can draw and remain hidden.<br>
The supported device configurations have automated tests. The overlay enforces
these bounds and clips content that paints outside them.

Also do not forget to define the `BorderRadius` property for your Notch logo widget,
so it nicely fits under the hardware barrier and is non-visible when not intended to.</br>

## Additional information

### Recommendations and tips

❌ Do not place kinky visual trash (especially ads) but only your brand or
application logo. Doing the opposite may cause trouble with releasing
your app to the store.

❌ Do not place any important or sensitive information in the `HiddenLogo` widget.
Assume that users don't even see your widget there.

The logo is decorative: it ignores pointer events and is excluded from keyboard
focus and accessibility semantics. Put interactive controls and accessible content
in the app body.

❌ Do not use the `HiddenLogo` widget if the top of the screen in your app already
has many details in app bars. Doing the opposite will make it look even more overloaded.

✅ Hide your HiddenLogo widget while the splashscreen is displayed. You can achieve this
by setting the `isVisible` property to `false` in the `HiddenLogo` widget.

✅ Set `visibilityMode: LogoVisibilityMode.onlyInBackground` to hide the logo
while the app is resumed. This mode enables it when Flutter reports an inactive,
paused, hidden or detached lifecycle state. An inactive state can also occur while
the app is still onscreen. Screenshot and app-switcher capture timing depends on
iOS, so this option does not guarantee that a particular capture includes or excludes
the logo.

✅ If your brand's logo is complicated and has many small details you may want to
use a simplified version. Or just display its name.

✅ Feel free to slightly animate your child widget if needed. But don't overdo it!

### Debugging

To inspect the logo while developing, use `LogoVisibilityMode.always` and take
a screenshot (in the iOS simulator: Device → Trigger Screenshot). The screenshot
can reveal content hidden by the simulated cutout. Also inspect the running app
with the simulator mask enabled to check that the logo stays hidden.

To check `onlyInBackground`, compare a foreground screenshot with an app-switcher
preview. Treat preview timing as a manual device check, since widget lifecycle tests
do not reproduce when iOS captures that preview.

### iPhones hardware barrier types (Target devices)

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

## About new device support

When the new iPhones are released, your logos won't appear on their screens because
the actual shape and size configuration of further devices are unknown in advance.
But the plugin will be updated as soon as possible when all necessary SDKs are available!

The iPhone 18 Pro and Pro Max identifiers were checked against Apple's Xcode 27
simulator profiles. The adopted logo area is `93 × 34` logical pixels at top
offset `15.3`, a 1-point inset from the original `95 × 36` area at `14.3`.
This avoids color leaking at its edges.
This was checked with saturated logo captures both with and without the simulator mask.
Display Zoom scaling also has automated tests. The runtime mask captures cover
the idle portrait island. Physical-device masks, actual Display Zoom and animated
or active island states still need manual verification.

Dynamic Island models from iPhone 14 Pro through iPhone 17 use `120 × 34.7`
logical pixels, also inset by 1 point. Their top offsets are `12.3` for
14 Pro/Pro Max, the 15 series and 16/16 Plus; `15.0` for 16 Pro/Pro Max and
17/17 Pro/17 Pro Max; and `21.0` for Air. Runtime mask captures revealed faint
color leakage at the previous bounds. Pixel regression fixtures use the opaque
mask interiors measured independently from those captures, including synthetic
Display Zoom layouts. They do not replace physical-device checks.
All 16 supported Dynamic Island models were captured in standard portrait on
iOS 27. Four additional device/runtime combinations were checked on iOS 17,
18 and 26; these checks cover the idle island shape.

The iPhone 12 family also uses a bottom inset after verification against Apple's
simulator masks: maximum height is `31.0` for 12/12 Pro/12 Pro Max and `33.3` for
12 mini. Regression tests check painted pixels in standard and zoomed layouts.
The notch builder still needs suitable rounded corners, as described above.

### iPhone Duo

iPhone Duo is intentionally left without a logo in this update. The app body is
preserved, and unrecognized device identifiers never enable a logo automatically.
The existing centered notch and Dynamic Island presets must not be reused for it.

Support can be reconsidered after its identifiers, both screen configurations and
camera masks are independently verified using the Duo simulator and SDK in
[Xcode 27.1 or later](https://developer.apple.com/documentation/xcode-release-notes/xcode-27_1-release-notes).

### Contribute 🛠

You can also contribute to this plugin on [GitHub](https://github.com/AndreySosnovyy/hidden_logo). </br>
Suggest your ideas or bug reports by opening an [issue](https://github.com/AndreySosnovyy/hidden_logo/issues/new) or
creating a [pull request](https://github.com/AndreySosnovyy/hidden_logo/pulls).
</br>
</br>
</br>


## Development checks

The documentation checkers require Python 3.9 or later and use only its standard
library. From the repository root, run:

```sh
python3 tool/check_repository.py
python3 tool/check_readme_example.py
flutter pub get
flutter analyze
flutter test
flutter pub publish --dry-run
```

The metadata check compares the documented device table and SDK requirements with
the package and native manifests, and validates local documentation assets and
native resource references. The README app-builder example is compiled and run
on both SDKs with stand-ins for the two user-supplied brand widgets, checking the
public API and app wiring. CI is configured to build the Android, Web, iOS,
Linux, Windows and macOS examples with the minimum and current stable Flutter
SDKs. Formatting is checked with Flutter 3.24.0
because Dart formatter output changes between SDK releases. See the
[example instructions](example/README.md) for local builds and visual checks.

CI also validates the workflow with actionlint 1.7.12, including GitHub expression
contexts that a YAML syntax check alone does not verify.
