// ignore_for_file: public_member_api_docs

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:hidden_logo/src/wrapper.dart';

class HiddenLogoBase extends StatefulWidget {
  final Widget body;
  final LogoBuilder notchBuilder;
  final LogoBuilder dynamicIslandBuilder;
  final LogoVisibilityMode visibilityMode;
  final bool isVisible;
  final DeviceInfoPlugin? deviceInfoPlugin;

  const HiddenLogoBase({
    required this.body,
    required this.notchBuilder,
    required this.dynamicIslandBuilder,
    required this.visibilityMode,
    required this.isVisible,
    required this.deviceInfoPlugin,
    super.key,
  });

  @override
  State<HiddenLogoBase> createState() => _HiddenLogoBaseState();
}

class _HiddenLogoBaseState extends State<HiddenLogoBase>
    with WidgetsBindingObserver {
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
          future: (widget.deviceInfoPlugin ?? DeviceInfoPlugin()).deviceInfo,
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
                    widget.isVisible &&
                    (widget.visibilityMode == LogoVisibilityMode.always
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
