import 'package:flutter/material.dart';
import 'package:hidden_logo/src/base.dart';

/// Builds a decorative logo within the supplied maximum bounds.
///
/// The overlay clips overflow and excludes pointer events, keyboard focus,
/// and semantics.
typedef LogoBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

/// Determines when to show your logo
enum LogoVisibilityMode {
  /// Always show the logo
  always,

  /// Show while the app is inactive, paused, hidden or detached.
  onlyInBackground,
}

/// {@template hidden_logo.HiddenLogo}
/// Hidden Logo widget wrapper. It wraps the body widget and displays a widget
/// built via the provided functions at the top of the screen where it is not
/// visible under the physical hardware barrier.
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

  /// Full-screen app content.
  ///
  /// Use the app builder when logos need inherited theme or localization.
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
    );
  }
}
