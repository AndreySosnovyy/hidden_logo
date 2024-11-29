import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/base.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockHiddenLogoParser extends Mock implements HiddenLogoParser {}

class MockBaseDeviceInfo extends Mock implements BaseDeviceInfo {}

class MockDeviceInfoPlugin extends Mock implements DeviceInfoPlugin {}

class OrientatedBuilder extends StatelessWidget {
  const OrientatedBuilder({
    required this.orientation,
    required this.builder,
    super.key,
  });

  final Orientation orientation;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromView(View.of(context)).copyWith(
          size: orientation == Orientation.landscape
              ? const Size(800.0, 600.0)
              : const Size(600.0, 800.0)),
      child: Builder(builder: (context) => builder(context)),
    );
  }
}

class EmptyAppWithHiddenLogo extends StatefulWidget {
  const EmptyAppWithHiddenLogo({
    this.parser,
    this.deviceInfoPlugin,
    this.isVisible = true,
    this.visibilityMode = LogoVisibilityMode.always,
    this.dynamicIslandKey,
    this.notchKey,
    this.isIOS = true,
    super.key,
  });

  final Key? notchKey;
  final Key? dynamicIslandKey;
  final bool isVisible;
  final LogoVisibilityMode visibilityMode;
  final HiddenLogoParser? parser;
  final DeviceInfoPlugin? deviceInfoPlugin;
  final bool isIOS;

  @override
  State<EmptyAppWithHiddenLogo> createState() => _EmptyAppWithHiddenLogoState();
}

class _EmptyAppWithHiddenLogoState extends State<EmptyAppWithHiddenLogo> {
  @override
  void initState() {
    super.initState();
    if (!widget.isIOS) return;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Scaffold(),
      builder: (context, child) {
        return HiddenLogoBase(
          deviceInfoPlugin: widget.deviceInfoPlugin ?? DeviceInfoPlugin(),
          parser: widget.parser ?? MockHiddenLogoParser(),
          isVisible: widget.isVisible,
          visibilityMode: widget.visibilityMode,
          notchBuilder: (_, __) => SizedBox.shrink(key: widget.notchKey),
          dynamicIslandBuilder: (_, __) =>
              SizedBox.shrink(key: widget.dynamicIslandKey),
          body: child!,
        );
      },
    );
  }

  @override
  void dispose() {
    debugDefaultTargetPlatformOverride = null;
    super.dispose();
  }
}

void main() {
  final mockBaseDeviceInfo = MockBaseDeviceInfo();
  final mockDeviceInfoPlugin = MockDeviceInfoPlugin();

  when(() => mockDeviceInfoPlugin.deviceInfo)
      .thenAnswer((_) async => mockBaseDeviceInfo);

  Future<void> setOrientation(Orientation orientation) async =>
      await TestWidgetsFlutterBinding.ensureInitialized().setSurfaceSize(
          orientation == Orientation.landscape
              ? const Size(800, 600)
              : const Size(600, 800));

  Map<String, dynamic> buildRandomMockDeviceInfoDataMap({LogoType? logoType}) =>
      TestUtils.buildMockDeviceInfoDataMap(TestUtils.iPhoneToCode(
          TestUtils.getRandomIPhone(logoType: logoType),
          withPrefix: true));

  group('HiddenLogo visibility', () {
    testWidgets(
        'Notch logo should be displayed with default visibility parameters for '
        'iPhones with notch logo type', (tester) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      when(() => mockBaseDeviceInfo.data).thenReturn(
          buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        deviceInfoPlugin: mockDeviceInfoPlugin,
        parser: parser,
        notchKey: notchKey,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsOneWidget);
    });

    testWidgets('Notch logo should not be displayed if isVisible is false',
        (tester) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      when(() => mockBaseDeviceInfo.data).thenReturn(
          buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        deviceInfoPlugin: mockDeviceInfoPlugin,
        parser: parser,
        notchKey: notchKey,
        isVisible: false,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });

    testWidgets(
        'Notch should not be displayed while in foreground if visibilityMode '
        'is background only', (tester) async {
      await setOrientation(Orientation.portrait);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      const notchKey = ValueKey('notch');
      when(() => mockBaseDeviceInfo.data).thenReturn(
          buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        deviceInfoPlugin: mockDeviceInfoPlugin,
        parser: parser,
        notchKey: notchKey,
        visibilityMode: LogoVisibilityMode.onlyInBackground,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });

    testWidgets(
        'Notch should be displayed while in background if visibilityMode is '
        'background only', (tester) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      when(() => mockBaseDeviceInfo.data).thenReturn(
          buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        deviceInfoPlugin: mockDeviceInfoPlugin,
        parser: parser,
        notchKey: notchKey,
        visibilityMode: LogoVisibilityMode.onlyInBackground,
      ));
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsOneWidget);
    });

    testWidgets(
        'Notch should disappear if app goes foreground if visibilityMode is '
            'background only', (tester) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      when(() => mockBaseDeviceInfo.data).thenReturn(
          buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        deviceInfoPlugin: mockDeviceInfoPlugin,
        parser: parser,
        notchKey: notchKey,
        visibilityMode: LogoVisibilityMode.onlyInBackground,
      ));
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });

    testWidgets('Notch should not be displayed for non target devices',
        (tester) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      // Empty map simulates non target device
      when(() => mockBaseDeviceInfo.data).thenReturn({});
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        deviceInfoPlugin: mockDeviceInfoPlugin,
        parser: parser,
        notchKey: notchKey,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });

    testWidgets('Notch logo should not be displayed in landscape orientation',
        (tester) async {
      await setOrientation(Orientation.landscape);
      const notchKey = ValueKey('notch');
      when(() => mockBaseDeviceInfo.data).thenReturn(
          buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        deviceInfoPlugin: mockDeviceInfoPlugin,
        parser: parser,
        notchKey: notchKey,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });
  });

  testWidgets(
      'Notch logo should not be displayed after device rotates from portrait to landscape',
      (tester) async {
    await setOrientation(Orientation.portrait);
    const notchKey = ValueKey('notch');
    when(() => mockBaseDeviceInfo.data)
        .thenReturn(buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
    final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
    await tester.pumpWidget(EmptyAppWithHiddenLogo(
      deviceInfoPlugin: mockDeviceInfoPlugin,
      parser: parser,
      notchKey: notchKey,
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(notchKey), findsOneWidget);
    await setOrientation(Orientation.landscape);
    await tester.pumpAndSettle();
    expect(find.byKey(notchKey), findsNothing);
  });

  testWidgets(
      'Notch logo should be displayed after device rotates from landscape to portrait',
      (tester) async {
    await setOrientation(Orientation.landscape);
    const notchKey = ValueKey('notch');
    when(() => mockBaseDeviceInfo.data)
        .thenReturn(buildRandomMockDeviceInfoDataMap(logoType: LogoType.notch));
    final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
    await tester.pumpWidget(EmptyAppWithHiddenLogo(
      deviceInfoPlugin: mockDeviceInfoPlugin,
      parser: parser,
      notchKey: notchKey,
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(notchKey), findsNothing);
    await setOrientation(Orientation.portrait);
    await tester.pumpAndSettle();
    expect(find.byKey(notchKey), findsOneWidget);
  });

  // group('Test HiddenLogo is the same as HiddenLogoBase', () {});
}
