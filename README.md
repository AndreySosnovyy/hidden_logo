[//]: # (TODO: format the file)

## Features

The package allows you to add hidden logo under the notch for old iPhones and under the Dynamic Island for new ones.

[//]: # (TODO: add gif example)

## Usage

Wrap your `MaterialApp` or `CupertinoApp` with `HiddenLogo` widget or define its `builder` function (as in the example below). Then you have to provide 2 builders for 2 cases: iPhones with notch and the ones with Dynamic Island.

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

The size of your brand logo can be adaptive thanks to constraints provided by the widget. They define `maxWidth` and `maxHeight` where you can draw and remain hidden.\
Also do not forget to define `BorderRadius` property for your logo widgets!

[//]: # (TODO: add table of logo types for all iPhones)

## Additional information

You do not have to worry - all the existing iPhone variants starting from iPhone X are tested, so the widget always return correct max constraints!

When the new iPhones will come out the logos will not appear on them because the actual shape and size configuration of further devices are unknown in advance!\
But the package will be updated as soon as possible after the release!

Any Issues or Pull request are appreciated!\
Thanks!