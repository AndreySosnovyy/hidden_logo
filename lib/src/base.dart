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
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _isForeground =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _machineIdFuture = DeviceInfoService.getMachineIdentifier();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasForeground = _isForeground;
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
    // The logo's visibility depends on foreground state only in
    // onlyInBackground mode. Avoid rebuilding the whole subtree otherwise.
    if (_isForeground != wasForeground &&
        widget.visibilityMode == LogoVisibilityMode.onlyInBackground) {
      setState(() {});
    }
  }

  @override
  void didChangeMetrics() {
    // Display Zoom changes the view's rendering size while the display keeps
    // its native pixel dimensions. Recompute both the logo size and its offset.
    setState(() {});
  }

  double _logoScale(BuildContext context, HiddenLogoParser parser) {
    final view = View.of(context);
    final displayWidth = view.display.size.shortestSide;
    final viewWidth = view.physicalSize.shortestSide;
    if (!displayWidth.isFinite || displayWidth <= 0) return 1.0;
    // Mini models render their standard 375-point UI at 3x, then downsample
    // to a 1080-pixel display. Compare with that standard render width instead
    // of the native display width so Zoom does not leave the logo too large.
    final standardWidth = parser.currentIPhone == DeviceModel.iPhone12Mini ||
            parser.currentIPhone == DeviceModel.iPhone13Mini
        ? 375.0 * view.devicePixelRatio
        : displayWidth;
    final scale = viewWidth / standardWidth;
    if (!scale.isFinite || scale <= 0 || scale > 1) return 1.0;
    return scale;
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
            final logoScale = _logoScale(context, parser);
            final constraints = parser.logoConstraints * logoScale;
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
                        top: parser.dynamicIslandTopMargin * logoScale,
                      ),
                      child: parser.iPhonesLogoType == LogoType.notch
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
