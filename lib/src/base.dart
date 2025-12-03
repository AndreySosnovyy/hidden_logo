// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:hidden_logo/src/device_info_service.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:hidden_logo/src/wrapper.dart';

class HiddenLogoBase extends StatefulWidget {
  const HiddenLogoBase({
    required this.body,
    required this.notchBuilder,
    required this.dynamicIslandBuilder,
    this.visibilityMode = LogoVisibilityMode.always,
    this.isVisible = true,
    super.key,
  });

  final Widget body;
  final LogoBuilder notchBuilder;
  final LogoBuilder dynamicIslandBuilder;
  final LogoVisibilityMode visibilityMode;
  final bool isVisible;

  @override
  State<HiddenLogoBase> createState() => _HiddenLogoBaseState();
}

class _HiddenLogoBaseState extends State<HiddenLogoBase>
    with WidgetsBindingObserver {
  late bool _isForeground;
  late final Future<String?> _machineIdFuture;
  HiddenLogoParser? _parser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _machineIdFuture = DeviceInfoService.getMachineIdentifier();
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
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) return widget.body;
        return FutureBuilder<String?>(
          future: _machineIdFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return widget.body;
            }
            _parser ??= HiddenLogoParser(machineIdentifier: snapshot.data);
            final parser = _parser!;
            final constraints = parser.logoConstraints;
            return Stack(
              children: [
                widget.body,
                if (parser.isTargetDevice &&
                    widget.isVisible &&
                    (widget.visibilityMode == LogoVisibilityMode.always ||
                        !_isForeground) &&
                    constraints.maxHeight > 0 &&
                    constraints.maxWidth > 0)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: parser.dynamicIslandTopMargin,
                      ),
                      child:
                          parser.iPhonesLogoType == LogoType.notch
                              ? widget.notchBuilder(context, constraints)
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
