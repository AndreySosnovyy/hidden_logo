import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hidden_logo/src/parser.dart';

/// Logo builder function
typedef LogoBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

/// Determines when to show your logo
enum LogoShowType {
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
    this.showType = LogoShowType.always,
    this.isShown = true,
    Key? key,
  }) : super(key: key);

  /// Your widget to be wrapped (usually MaterialApp or CupertinoApp)
  final Widget body;

  /// What would you like to see behind iPhone's notch
  /// depending on its provided size
  final LogoBuilder notchBuilder;

  /// What would you like to see behind iPhone's Dynamic Island
  /// depending on its provided size
  final LogoBuilder dynamicIslandBuilder;

  /// Determines when to show your logo
  final LogoShowType showType;

  /// You can force hiding of the logo whilst the parameter is set to false
  final bool isShown;

  @override
  State<HiddenLogo> createState() => _HiddenLogoState();
}

class _HiddenLogoState extends State<HiddenLogo> with WidgetsBindingObserver {
  bool _isForeground = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isForeground = true;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _isForeground = false;
        break;
    }
    super.didChangeAppLifecycleState(state);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) return widget.body;
        return FutureBuilder(
          future: DeviceInfoPlugin().deviceInfo,
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.hasError ||
                snapshot.data == null) {
              return widget.body;
            }
            final parser =
                HiddenLogoParser(deviceInfo: snapshot.data! as BaseDeviceInfo);
            final constraints = parser.logoConstraints;
            return Stack(
              children: [
                widget.body,
                if (parser.isTargetDevice &&
                    widget.isShown &&
                    (widget.showType == LogoShowType.always
                        ? true
                        : !_isForeground))
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: parser.dynamicIslandTopMargin,
                      ),
                      child: parser.logoType == LogoType.notch
                          ? widget.notchBuilder(
                              context,
                              constraints,
                            )
                          : ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100.0),
                              ),
                              child: widget.dynamicIslandBuilder(
                                context,
                                constraints,
                              ),
                            ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
