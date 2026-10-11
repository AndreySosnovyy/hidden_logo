// ignore_for_file: public_member_api_docs

import 'dart:async';

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
  Timer? _retryTimer;
  bool _lookupInFlight = false;
  bool _needsRetry = false;
  int _lookupAttempts = 0;
  HiddenLogoParser? _parser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _isForeground =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _lookupMachineIdentifier();
  }

  Future<void> _lookupMachineIdentifier() async {
    if (_lookupInFlight) return;
    _lookupInFlight = true;
    _lookupAttempts++;
    final result = await DeviceInfoService.getMachineIdentifierResult();
    if (!mounted) return;
    _lookupInFlight = false;
    _needsRetry = result.isTransientFailure;
    if (_needsRetry) {
      // Retry early registration failures twice, then wait for a resume event.
      // Unsupported platforms and successful null results never start a timer.
      if (_lookupAttempts < 3) {
        _retryTimer = Timer(
          Duration(milliseconds: 200 * _lookupAttempts),
          _lookupMachineIdentifier,
        );
      }
      return;
    }
    setState(() {
      _parser = HiddenLogoParser(machineIdentifier: result.identifier);
    });
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
    if (_isForeground && !wasForeground && _needsRetry) {
      _retryTimer?.cancel();
      _lookupAttempts = 0;
      _lookupMachineIdentifier();
    }
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
        final parser = _parser;
        final showLogo = orientation == Orientation.portrait &&
            parser != null &&
            parser.isTargetDevice &&
            widget.isVisible &&
            (widget.visibilityMode == LogoVisibilityMode.always ||
                !_isForeground);
        Widget? overlay;
        if (showLogo) {
          final logoScale = _logoScale(context, parser);
          final constraints = parser.logoConstraints * logoScale;
          if (constraints.maxHeight > 0 && constraints.maxWidth > 0) {
            final isNotch = parser.iPhonesLogoType == LogoType.notch;
            final logo = isNotch
                ? widget.notchBuilder(context, constraints)
                : widget.dynamicIslandBuilder(context, constraints);
            overlay = Positioned(
              top: parser.dynamicIslandTopMargin * logoScale,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: ExcludeFocus(
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: ConstrainedBox(
                        constraints: constraints,
                        child: isNotch
                            ? ClipRect(child: logo)
                            : ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100.0),
                                ),
                                // The hardware mask has a fixed shape even when
                                // a builder returns a smaller widget. Center that
                                // widget inside the full capsule before clipping.
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  child: Center(child: logo),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
        // Keep the body in the same element slot while lookup, orientation,
        // and visibility change. A positioned overlay cannot size the body.
        return Stack(
          alignment: Alignment.topLeft,
          fit: StackFit.passthrough,
          children: [widget.body, if (overlay != null) overlay],
        );
      },
    );
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
