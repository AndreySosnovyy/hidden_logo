## Features

The package allows you to add hidden logo under the Notch or the Dynamic Island for iPhone devices.


![readme_welcome_image.png](https://github.com/AndreySosnovyy/hidden_logo/blob/main/readme_welcome_image.png)

❗Using this package will **NOT** affect your application running on any other 
platforms except iOS. Also, it will not affect your app running on the 
iPhones that is not marked as the Target ones 
(See the [List of Target iPhones](#table-of-iphones-hardware-top-barrier-types-target-iphones) 
in the table down below).

## Usage

Wrap your `MaterialApp` or `CupertinoApp` with `HiddenLogo` widget or define 
its `builder` function (as in the example). Then you have to provide 2 builders
for 2 cases: iPhones with Notch and the ones with Dynamic Island.

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
  );
}
```

The size of your brand logo can be adaptive thanks to constraints provided 
by the widget. They define `maxWidth`
and `maxHeight` where you can draw and remain hidden.<br>
Also do not forget to define `BorderRadius` property for your Notch logo widget to make it look prettier! And the Dynamic Island widget will be rounded automatically.

## Common mistakes

- Don't place kinky visual trash (especially adds) but only your brand or 
application logo. Obviously, doing opposite may cause troubles with releasing
your app to the store
- Round your widget's barriers, so it nicely fits hardware barrier and 
non-visible when not need to be

## Additional information

You do not have to worry - all the existing iPhone variants starting from 
iPhone X are tested, so the widget always return correct max constraints!

To test visual appearance of your widget when developing you can either 
minimize your app to tray or take a screenshot of your app (for ios 
simulator: Device → Trigger Screenshot)

### Table of iPhones hardware top barrier types (Target iPhones)

| iPhones with Notch | iPhones with Dynamic Island |
|:-------------------|:----------------------------|
| X                  | 14 Pro                      |
| XR                 | 14 Pro Max                  |
| XS                 | 15                          |
| XS Max             | 15 Plus                     |
| 11                 | 15 Pro                      |
| 11 Pro             | 15 Pro Max                  |
| 11 Pro Max         |                             |
| 12                 |                             |
| 12 Mini            |                             |
| 12 Pro             |                             |
| 12 Pro Max         |                             |
| 13                 |                             |
| 13 Mini            |                             |
| 13 Pro             |                             |
| 13 Pro Max         |                             |
| 14                 |                             |
| 14 Plus            |                             |

### About further updates

When the new iPhones will come out the logos will not appear on them 
because the actual shape and size configuration of
further devices are unknown in advance!<br>
But the package will be updated as soon as possible after the release!

**Any Issues or Pull request are appreciated!**<br>
**Thanks!**