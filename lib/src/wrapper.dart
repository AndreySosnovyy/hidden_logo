import 'package:flutter/material.dart';
import 'package:hidden_logo/src/base.dart';
import 'package:hidden_logo/src/parser.dart';

/// Logo builder function
typedef LogoBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

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
class HiddenLogo extends StatefulWidget {
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
  State<HiddenLogo> createState() => _HiddenLogoState();
}

class _HiddenLogoState extends State<HiddenLogo> {
  late final HiddenLogoParser _parser;

  @override
  void initState() {
    super.initState();
    _parser = HiddenLogoParser();
  }

  @override
  Widget build(BuildContext context) {
    return HiddenLogoBase(
      body: widget.body,
      notchBuilder: widget.notchBuilder,
      dynamicIslandBuilder: widget.dynamicIslandBuilder,
      visibilityMode: widget.visibilityMode,
      isVisible: widget.isVisible,
      parser: _parser,
    );
  }
}
