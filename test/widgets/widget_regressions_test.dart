import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/device_info_service.dart';

const _logoKey = ValueKey('regression logo');
const _channel = MethodChannel('hidden_logo');

Widget _wrap(
  Widget body, {
  Widget Function(BuildContext, BoxConstraints)? logo,
}) {
  Widget defaultLogo(BuildContext context, BoxConstraints constraints) =>
      const SizedBox(key: _logoKey, width: 300, height: 200);
  return HiddenLogo(
    body: body,
    notchBuilder: logo ?? defaultLogo,
    dynamicIslandBuilder: logo ?? defaultLogo,
  );
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var count = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => count++),
        child: SizedBox.expand(child: Center(child: Text('Count: $count'))),
      );
}

class _OverflowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      const Rect.fromLTWH(-1000, -1000, 2000, 2000),
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(_OverflowPainter oldDelegate) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    DeviceInfoService.reset();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    DeviceInfoService.reset();
    messenger.setMockMethodCallHandler(_channel, null);
  });

  void regressionTest(String description, WidgetTesterCallback callback) {
    testWidgets(description, (tester) async {
      try {
        await callback(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  Future<void> portrait(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    tester.view.display.size = const Size(400, 800);
    addTearDown(tester.view.reset);
    addTearDown(tester.view.display.reset);
  }

  regressionTest(
      'retains body state through lookup, rotation, and logo updates',
      (tester) async {
    await portrait(tester);
    final result = Completer<String>();
    messenger.setMockMethodCallHandler(_channel, (_) => result.future);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: _wrap(const _Counter()),
      ),
    );
    await tester.tap(find.text('Count: 0'));
    await tester.pump();
    final originalState = tester.state(find.byType(_Counter));
    result.complete('iPhone15,2');
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(_Counter)), same(originalState));
    expect(find.text('Count: 1'), findsOneWidget);
    expect(find.byKey(_logoKey), findsOneWidget);

    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expect(find.byKey(_logoKey), findsNothing);
    expect(tester.state(find.byType(_Counter)), same(originalState));
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    expect(find.byKey(_logoKey), findsOneWidget);
    expect(find.text('Count: 1'), findsOneWidget);
    expect(tester.state(find.byType(_Counter)), same(originalState));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HiddenLogo(
          body: const _Counter(),
          notchBuilder: (_, __) => const SizedBox.shrink(),
          dynamicIslandBuilder: (_, __) => const SizedBox.shrink(),
          isVisible: false,
        ),
      ),
    );
    expect(find.text('Count: 1'), findsOneWidget);
    expect(tester.state(find.byType(_Counter)), same(originalState));
  });

  regressionTest('outer MaterialApp wrapper preserves navigation after lookup',
      (tester) async {
    await portrait(tester);
    final result = Completer<String>();
    messenger.setMockMethodCallHandler(_channel, (_) => result.future);
    await tester.pumpWidget(
      _wrap(
        const MaterialApp(
          home: Scaffold(body: Text('Home route')),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final navigator = Navigator.of(tester.element(find.text('Home route')));
    unawaited(
      navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Second route')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    result.complete('iPhone15,2');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Second route'), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.text('Second route'))),
      same(navigator),
    );
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    expect(find.text('Second route'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home route'), findsOneWidget);
  });

  regressionTest('builders retain inherited theme and direction in app builder',
      (tester) async {
    await portrait(tester);
    DeviceInfoService.setMockMachineIdentifier('iPhone15,2');
    ThemeData? seenTheme;
    TextDirection? seenDirection;
    final theme = ThemeData(colorSchemeSeed: Colors.purple);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(),
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: _wrap(
            child!,
            logo: (context, constraints) {
              seenTheme = Theme.of(context);
              seenDirection = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(seenTheme!.colorScheme, theme.colorScheme);
    expect(seenDirection, TextDirection.rtl);
  });

  for (final fixture in [
    ('iPhone15,2', const Size(120, 34.7), 12.3),
    ('iPhone10,6', const Size(209, 30), 0.0),
  ]) {
    regressionTest(
        '${fixture.$1} constrains oversized logos and preserves offset',
        (tester) async {
      await portrait(tester);
      DeviceInfoService.setMockMachineIdentifier(fixture.$1);
      await tester.pumpWidget(_wrap(const SizedBox.expand()));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(_logoKey)), fixture.$2);
      expect(tester.getTopLeft(find.byKey(_logoKey)).dy, fixture.$3);
      expect(tester.getCenter(find.byKey(_logoKey)).dx, 200);
      expect(tester.takeException(), isNull);
    });
  }

  for (final identifier in ['iPhone15,2', 'iPhone10,6']) {
    regressionTest('$identifier clips painting outside the logo bounds',
        (tester) async {
      await portrait(tester);
      DeviceInfoService.setMockMachineIdentifier(identifier);
      const captureKey = ValueKey('capture');
      await tester.pumpWidget(
        RepaintBoundary(
          key: captureKey,
          child: ColoredBox(
            color: Colors.white,
            child: _wrap(
              const SizedBox.expand(),
              logo: (_, __) => CustomPaint(
                size: const Size(300, 200),
                painter: _OverflowPainter(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(captureKey),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final pixels =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        List<int> pixel(int x, int y) => List.generate(
              4,
              (channel) => pixels.getUint8((y * image.width + x) * 4 + channel),
            );
        // Red at the center; untouched white outside both permitted footprints.
        expect(pixel(200, 20), [244, 67, 54, 255]);
        expect(pixel(200, 60), [255, 255, 255, 255]);
        expect(pixel(20, 20), [255, 255, 255, 255]);
        if (identifier == 'iPhone15,2') {
          // The rectangular bounding box's corner is outside the rounded island.
          expect(pixel(140, 12), [255, 255, 255, 255]);
        }
        image.dispose();
      });
    });
  }

  regressionTest('undersized island logo is centered inside the full mask',
      (tester) async {
    await portrait(tester);
    DeviceInfoService.setMockMachineIdentifier('iPhone19,2');
    const captureKey = ValueKey('small logo capture');
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: ColoredBox(
          color: Colors.white,
          child: _wrap(
            const SizedBox.expand(),
            logo: (_, __) => CustomPaint(
              key: _logoKey,
              size: const Size(93, 10),
              painter: _OverflowPainter(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(_logoKey)), const Size(93, 10));
    expect(tester.getCenter(find.byKey(_logoKey)).dx, 200);
    expect(tester.getCenter(find.byKey(_logoKey)).dy, closeTo(32.3, 0.0001));
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final pixels =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      List<int> pixel(int x, int y) => List.generate(
            4,
            (channel) => pixels.getUint8((y * image.width + x) * 4 + channel),
          );
      // A short logo must not produce a shallow capsule at the mask's top.
      expect(pixel(159, 17), [255, 255, 255, 255]);
      expect(pixel(200, 32), [244, 67, 54, 255]);
      // Overflow paint is clipped by the full hardware-sized capsule, whose
      // lower center is inside the mask but below this 10-point child.
      expect(pixel(200, 45), [244, 67, 54, 255]);
      expect(pixel(200, 55), [255, 255, 255, 255]);
      image.dispose();
    });
  });

  for (final identifier in ['iPhone13,2', 'iPhone19,2']) {
    regressionTest('decorative logo skips keyboard focus on $identifier',
        (tester) async {
      await portrait(tester);
      DeviceInfoService.setMockMachineIdentifier(identifier);
      final bodyFocus = FocusNode();
      final logoFocus = FocusNode();
      addTearDown(bodyFocus.dispose);
      addTearDown(logoFocus.dispose);
      var bodyActivations = 0;
      var logoActivations = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: _wrap(
            Scaffold(
              body: Center(
                child: TextButton(
                  autofocus: true,
                  focusNode: bodyFocus,
                  onPressed: () => bodyActivations++,
                  child: const Text('Body action'),
                ),
              ),
            ),
            logo: (_, __) => TextButton(
              focusNode: logoFocus,
              onPressed: () => logoActivations++,
              child: const Text('Brand'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(bodyFocus.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(logoFocus.hasFocus, isFalse);
      expect(bodyFocus.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(bodyActivations, 1);
      expect(logoActivations, 0);

      // Decorative content must not steal focus through autofocus or a
      // builder-provided FocusNode either.
      logoFocus.requestFocus();
      await tester.pump();
      expect(logoFocus.hasFocus, isFalse);
      expect(bodyFocus.hasFocus, isTrue);
    });
  }

  regressionTest('decorative logo neither intercepts taps nor adds semantics',
      (tester) async {
    await portrait(tester);
    DeviceInfoService.setMockMachineIdentifier('iPhone15,2');
    final semantics = tester.ensureSemantics();

    var bodyTaps = 0;
    var logoTaps = 0;
    await tester.pumpWidget(
      _wrap(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => bodyTaps++,
          child: const SizedBox.expand(),
        ),
        logo: (_, __) => Semantics(
          label: 'Decorative branding',
          child: GestureDetector(
            onTap: () => logoTaps++,
            child: const SizedBox(key: _logoKey, width: 300, height: 200),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.byKey(_logoKey)));
    expect(bodyTaps, 1);
    expect(logoTaps, 0);
    expect(find.bySemanticsLabel('Decorative branding'), findsNothing);
    semantics.dispose();
  });

  regressionTest(
      'non-target body retains its size and state without logo calls',
      (tester) async {
    await portrait(tester);
    DeviceInfoService.setMockMachineIdentifier('iPad14,1');
    var logoCalls = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: _wrap(
            const SizedBox(width: 150, height: 200, child: _Counter()),
            logo: (_, __) {
              logoCalls++;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    final state = tester.state(find.byType(_Counter));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(_Counter)), const Size(150, 200));
    expect(tester.state(find.byType(_Counter)), same(state));
    expect(logoCalls, 0);
  });

  regressionTest('unknown future identifier remains a no-op across app changes',
      (tester) async {
    await portrait(tester);
    var channelCalls = 0;
    var logoCalls = 0;
    messenger.setMockMethodCallHandler(_channel, (_) async {
      channelCalls++;
      // Synthetic future identifier: deliberately not a real device mapping.
      return 'iPhone99,1';
    });
    await tester.pumpWidget(
      _wrap(
        const MaterialApp(home: Scaffold(body: _Counter())),
        logo: (_, __) {
          logoCalls++;
          return const SizedBox(key: _logoKey, width: 100, height: 30);
        },
      ),
    );
    await tester.pumpAndSettle();
    final counterState = tester.state(find.byType(_Counter));
    final navigator = Navigator.of(tester.element(find.byType(_Counter)));
    await tester.tap(find.text('Count: 0'));
    await tester.pump();
    unawaited(
      navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Unknown device route')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final size in [
      const Size(320, 640),
      const Size(430, 932),
      const Size(600, 900),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Unknown device route'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.text('Unknown device route'))),
        same(navigator),
      );
      expect(
        tester.state(find.byType(_Counter, skipOffstage: false)),
        same(counterState),
      );
      expect(find.byKey(_logoKey), findsNothing);
      expect(logoCalls, 0);
      expect(channelCalls, 1);
    }
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('Count: 1'), findsOneWidget);
    expect(tester.state(find.byType(_Counter)), same(counterState));
  });

  regressionTest('mounted widget recovers from a transient startup failure',
      (tester) async {
    await portrait(tester);
    var calls = 0;
    messenger.setMockMethodCallHandler(_channel, (_) async {
      if (++calls == 1) throw PlatformException(code: 'not-ready');
      return 'iPhone15,2';
    });
    await tester.pumpWidget(_wrap(const SizedBox.expand()));
    await tester.pump();
    expect(find.byKey(_logoKey), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byKey(_logoKey), findsOneWidget);
  });

  regressionTest('retries are bounded and resume can recover the same widget',
      (tester) async {
    await portrait(tester);
    var calls = 0;
    var available = false;
    messenger.setMockMethodCallHandler(_channel, (_) async {
      calls++;
      if (!available) throw MissingPluginException();
      return 'iPhone15,2';
    });
    await tester.pumpWidget(_wrap(const SizedBox.expand()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 30));
    expect(calls, 3);
    available = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(calls, 4);
    expect(find.byKey(_logoKey), findsOneWidget);
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    regressionTest('$platform permanent null does not retry even on resume',
        (tester) async {
      await portrait(tester);
      debugDefaultTargetPlatformOverride = platform;
      var calls = 0;
      messenger.setMockMethodCallHandler(_channel, (_) async {
        calls++;
        return null;
      });
      await tester.pumpWidget(_wrap(const SizedBox.expand()));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 30));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(calls, platform == TargetPlatform.iOS ? 1 : 0);
      expect(find.byKey(_logoKey), findsNothing);
    });
  }

  regressionTest('disposal during lookup ignores its eventual result',
      (tester) async {
    await portrait(tester);
    final result = Completer<String>();
    messenger.setMockMethodCallHandler(_channel, (_) => result.future);
    await tester.pumpWidget(_wrap(const SizedBox.expand()));
    await tester.pumpWidget(const SizedBox.shrink());
    result.complete('iPhone15,2');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  regressionTest('disposal cancels a scheduled retry', (tester) async {
    await portrait(tester);
    var calls = 0;
    messenger.setMockMethodCallHandler(_channel, (_) async {
      calls++;
      throw PlatformException(code: 'not-ready');
    });
    await tester.pumpWidget(_wrap(const SizedBox.expand()));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
}
