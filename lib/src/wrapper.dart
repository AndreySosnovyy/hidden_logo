import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hidden_logo/src/base.dart';

/// Logo builder function
typedef LogoBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

/// Determines when to show your logo
enum LogoVisibilityMode {
  /// Always show the logo
  always,

  /// Show the logo only when application is paused, inactive or hidden
  onlyInBackground,
}

/// {@template hidden_logo.HiddenLogo}
/// Hidden Logo widget wrapper. It wraps body widget and displays
/// widget built via provided functions on top of the screen where it it
/// not visible under the physical hardware barrier.
/// {@endtemplate}
class HiddenLogo extends StatelessWidget {
  /// {@macro hidden_logo.HiddenLogo}
  const HiddenLogo({
    required this.body,
    required this.notchBuilder,
    required this.dynamicIslandBuilder,
    this.visibilityMode = LogoVisibilityMode.always,
    this.isVisible = true,
    super.key,
  });

  /// Your widget to be wrapped (usually MaterialApp or CupertinoApp)
  final Widget body;

  /// What would you like to see behind iPhone's notch
  /// depending on its provided size
  final LogoBuilder notchBuilder;

  /// What would you like to see behind iPhone's Dynamic Island
  /// depending on its provided size
  final LogoBuilder dynamicIslandBuilder;

  /// Determines when to show your logo
  final LogoVisibilityMode visibilityMode;

  /// You can force hiding of the logo whilst the parameter is set to false
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return HiddenLogoBase(
      body: body,
      notchBuilder: notchBuilder,
      dynamicIslandBuilder: dynamicIslandBuilder,
      visibilityMode: visibilityMode,
      isVisible: isVisible,
      deviceInfoPlugin: DeviceInfoPlugin(),
    );
  }
}
