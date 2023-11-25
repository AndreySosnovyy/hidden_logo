import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hidden_logo/src/util.dart';

typedef LogoBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

enum LogoShowType {
  /// Always show the logo
  always,

  /// Show the logo only when application is paused, inactive or hidden
  onlyInBackground,
}

class HiddenLogo extends StatefulWidget {
  const HiddenLogo({
    required this.body,
    required this.notchBuilder,
    required this.dynamicIslandBuilder,
    this.showType = LogoShowType.always,
    this.isShown = true,
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
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _isForeground = false;
    }
    super.didChangeAppLifecycleState(state);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DeviceInfoPlugin().deviceInfo,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final notchUtil = IosHiddenLogoUtil(deviceInfo: snapshot.data!);
        final logoConstraints = notchUtil.logoConstraints;
        return Stack(
          children: [
            widget.body,
            if (notchUtil.isTargetDevice &&
                widget.isShown &&
                (widget.showType == LogoShowType.always
                    ? true
                    : !_isForeground))
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: notchUtil.dynamicIslandTopMargin,
                  ),
                  child: switch (notchUtil.logoType) {
                    LogoType.notch => widget.notchBuilder(
                        context,
                        logoConstraints,
                      ),
                    LogoType.dynamicIsland => ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        child: widget.dynamicIslandBuilder(
                          context,
                          logoConstraints,
                        ),
                      ),
                  },
                ),
              ),
          ],
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
