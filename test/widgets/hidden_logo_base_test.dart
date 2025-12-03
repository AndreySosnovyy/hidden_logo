import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/base.dart';
import 'package:hidden_logo/src/device_info_service.dart';
import 'package:hidden_logo/src/parser.dart';

import '../utils.dart';

class EmptyAppWithHiddenLogo extends StatefulWidget {
  const EmptyAppWithHiddenLogo({
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
          isVisible: widget.isVisible,
          visibilityMode: widget.visibilityMode,
          notchBuilder: (_, __) => SizedBox.shrink(key: widget.notchKey),
          dynamicIslandBuilder:
              (_, __) => SizedBox.shrink(key: widget.dynamicIslandKey),
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
  setUp(() {
    // Reset DeviceInfoService before each test
    DeviceInfoService.reset();
  });

  tearDown(() {
    DeviceInfoService.reset();
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> setOrientation(Orientation orientation) async =>
      await TestWidgetsFlutterBinding.ensureInitialized().setSurfaceSize(
        orientation == Orientation.landscape
            ? const Size(800, 600)
            : const Size(600, 800),
      );

  String getRandomMachineIdentifier({LogoType? logoType}) =>
      TestUtils.getMachineIdentifier(
        TestUtils.getRandomIPhone(logoType: logoType),
      );

  group('HiddenLogo visibility', () {
    testWidgets(
      'Notch logo should be displayed with default visibility parameters for '
      'iPhones with notch logo type',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const notchKey = ValueKey('notch');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.notch),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(notchKey: notchKey),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(notchKey), findsOneWidget);
      },
    );

    testWidgets('Notch logo should not be displayed if isVisible is false', (
      tester,
    ) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      DeviceInfoService.setMockMachineIdentifier(
        getRandomMachineIdentifier(logoType: LogoType.notch),
      );
      await tester.pumpWidget(
        const EmptyAppWithHiddenLogo(notchKey: notchKey, isVisible: false),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });

    testWidgets(
      'Notch should not be displayed while in foreground if visibilityMode '
      'is background only',
      (tester) async {
        await setOrientation(Orientation.portrait);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        const notchKey = ValueKey('notch');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.notch),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            notchKey: notchKey,
            visibilityMode: LogoVisibilityMode.onlyInBackground,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(notchKey), findsNothing);
      },
    );

    testWidgets(
      'Notch should be displayed while in background if visibilityMode is '
      'background only',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const notchKey = ValueKey('notch');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.notch),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            notchKey: notchKey,
            visibilityMode: LogoVisibilityMode.onlyInBackground,
          ),
        );
        await tester.pumpAndSettle();
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pumpAndSettle();
        expect(find.byKey(notchKey), findsOneWidget);
      },
    );

    testWidgets(
      'Notch should disappear if app goes foreground if visibilityMode is '
      'background only',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const notchKey = ValueKey('notch');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.notch),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            notchKey: notchKey,
            visibilityMode: LogoVisibilityMode.onlyInBackground,
          ),
        );
        await tester.pumpAndSettle();
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pumpAndSettle();
        expect(find.byKey(notchKey), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        expect(find.byKey(notchKey), findsNothing);
      },
    );

    testWidgets('Notch should not be displayed for non target devices', (
      tester,
    ) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      // Null simulates non target device
      DeviceInfoService.setMockMachineIdentifier(null);
      await tester.pumpWidget(const EmptyAppWithHiddenLogo(notchKey: notchKey));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });

    testWidgets('Notch logo should not be displayed in landscape orientation', (
      tester,
    ) async {
      await setOrientation(Orientation.landscape);
      const notchKey = ValueKey('notch');
      DeviceInfoService.setMockMachineIdentifier(
        getRandomMachineIdentifier(logoType: LogoType.notch),
      );
      await tester.pumpWidget(const EmptyAppWithHiddenLogo(notchKey: notchKey));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    });
  });

  testWidgets(
    'Notch logo should not be displayed after device rotates from portrait to landscape',
    (tester) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      DeviceInfoService.setMockMachineIdentifier(
        getRandomMachineIdentifier(logoType: LogoType.notch),
      );
      await tester.pumpWidget(const EmptyAppWithHiddenLogo(notchKey: notchKey));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsOneWidget);
      await setOrientation(Orientation.landscape);
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
    },
  );

  testWidgets(
    'Notch logo should be displayed after device rotates from landscape to portrait',
    (tester) async {
      await setOrientation(Orientation.landscape);
      const notchKey = ValueKey('notch');
      DeviceInfoService.setMockMachineIdentifier(
        getRandomMachineIdentifier(logoType: LogoType.notch),
      );
      await tester.pumpWidget(const EmptyAppWithHiddenLogo(notchKey: notchKey));
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsNothing);
      await setOrientation(Orientation.portrait);
      await tester.pumpAndSettle();
      expect(find.byKey(notchKey), findsOneWidget);
    },
  );

  group('Dynamic Island Logo visibility', () {
    testWidgets(
      'Dynamic Island logo should be displayed with default visibility parameters for '
      'iPhones with Dynamic Island logo type',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(dynamicIslandKey: dynamicIslandKey),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsOneWidget);
      },
    );

    testWidgets(
      'Dynamic Island logo should not be displayed if isVisible is false',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            dynamicIslandKey: dynamicIslandKey,
            isVisible: false,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsNothing);
      },
    );

    testWidgets(
      'Dynamic Island should not be displayed while in foreground if visibilityMode '
      'is background only',
      (tester) async {
        await setOrientation(Orientation.portrait);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            dynamicIslandKey: dynamicIslandKey,
            visibilityMode: LogoVisibilityMode.onlyInBackground,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsNothing);
      },
    );

    testWidgets(
      'Dynamic Island should be displayed while in background if visibilityMode is '
      'background only',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            dynamicIslandKey: dynamicIslandKey,
            visibilityMode: LogoVisibilityMode.onlyInBackground,
          ),
        );
        await tester.pumpAndSettle();
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsOneWidget);
      },
    );

    testWidgets(
      'Dynamic Island should disappear if app goes foreground if visibilityMode is '
      'background only',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            dynamicIslandKey: dynamicIslandKey,
            visibilityMode: LogoVisibilityMode.onlyInBackground,
          ),
        );
        await tester.pumpAndSettle();
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsNothing);
      },
    );

    testWidgets(
      'Dynamic Island should not be displayed for non target devices',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const dynamicIslandKey = ValueKey('dynamic_island');
        // Null simulates non target device
        DeviceInfoService.setMockMachineIdentifier(null);
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(dynamicIslandKey: dynamicIslandKey),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsNothing);
      },
    );

    testWidgets(
      'Dynamic Island logo should not be displayed in landscape orientation',
      (tester) async {
        await setOrientation(Orientation.landscape);
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(
          getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
        );
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(dynamicIslandKey: dynamicIslandKey),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsNothing);
      },
    );
  });

  testWidgets(
    'Dynamic Island logo should not be displayed after device rotates from portrait to landscape',
    (tester) async {
      await setOrientation(Orientation.portrait);
      const dynamicIslandKey = ValueKey('dynamic_island');
      DeviceInfoService.setMockMachineIdentifier(
        getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
      );
      await tester.pumpWidget(
        const EmptyAppWithHiddenLogo(dynamicIslandKey: dynamicIslandKey),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(dynamicIslandKey), findsOneWidget);
      await setOrientation(Orientation.landscape);
      await tester.pumpAndSettle();
      expect(find.byKey(dynamicIslandKey), findsNothing);
    },
  );

  testWidgets(
    'Dynamic Island logo should be displayed after device rotates from landscape to portrait',
    (tester) async {
      await setOrientation(Orientation.landscape);
      const dynamicIslandKey = ValueKey('dynamic_island');
      DeviceInfoService.setMockMachineIdentifier(
        getRandomMachineIdentifier(logoType: LogoType.dynamicIsland),
      );
      await tester.pumpWidget(
        const EmptyAppWithHiddenLogo(dynamicIslandKey: dynamicIslandKey),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(dynamicIslandKey), findsNothing);
      await setOrientation(Orientation.portrait);
      await tester.pumpAndSettle();
      expect(find.byKey(dynamicIslandKey), findsOneWidget);
    },
  );

  group('Mixed logo type behavior', () {
    testWidgets(
      'Should display only Dynamic Island logo for Dynamic Island devices',
      (tester) async {
        await setOrientation(Orientation.portrait);
        const notchKey = ValueKey('notch');
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(
          'iPhone15,2',
        ); // iPhone 14 Pro
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(
            notchKey: notchKey,
            dynamicIslandKey: dynamicIslandKey,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(dynamicIslandKey), findsOneWidget);
        expect(find.byKey(notchKey), findsNothing);
      },
    );

    testWidgets('Should display only notch logo for notch devices', (
      tester,
    ) async {
      await setOrientation(Orientation.portrait);
      const notchKey = ValueKey('notch');
      const dynamicIslandKey = ValueKey('dynamic_island');
      DeviceInfoService.setMockMachineIdentifier('iPhone10,6'); // iPhone X
      await tester.pumpWidget(
        const EmptyAppWithHiddenLogo(
          notchKey: notchKey,
          dynamicIslandKey: dynamicIslandKey,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(notchKey), findsOneWidget);
      expect(find.byKey(dynamicIslandKey), findsNothing);
    });
  });

  group('Dynamic Island specific features', () {
    testWidgets('Dynamic Island logo should respect top margin positioning', (
      tester,
    ) async {
      await setOrientation(Orientation.portrait);
      DeviceInfoService.setMockMachineIdentifier('iPhone15,2'); // iPhone 14 Pro
      await tester.pumpWidget(
        const EmptyAppWithHiddenLogo(
          dynamicIslandKey: ValueKey('dynamic_island'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify positioning with expected top margin (11.3 for iPhone 14 Pro)
      final parser = HiddenLogoParser(machineIdentifier: 'iPhone15,2');
      expect(parser.dynamicIslandTopMargin, equals(11.3));
    });

    testWidgets('Dynamic Island constraints should be smaller than notch', (
      tester,
    ) async {
      // Test Dynamic Island device
      final dynamicIslandParser = HiddenLogoParser(
        machineIdentifier: 'iPhone15,2',
      ); // iPhone 14 Pro
      final dynamicIslandConstraints = dynamicIslandParser.logoConstraints;

      // Test notch device
      final notchParser = HiddenLogoParser(
        machineIdentifier: 'iPhone10,6',
      ); // iPhone X
      final notchConstraints = notchParser.logoConstraints;

      // Dynamic Island should be smaller width than notch
      expect(
        dynamicIslandConstraints.maxWidth,
        lessThan(notchConstraints.maxWidth),
      );
      expect(
        dynamicIslandConstraints.maxHeight,
        greaterThan(notchConstraints.maxHeight),
      );
    });
  });

  group('Device-specific Dynamic Island tests', () {
    final dynamicIslandDevices = {
      'iPhone14Pro': 'iPhone15,2',
      'iPhone14ProMax': 'iPhone15,3',
      'iPhone15': 'iPhone15,4',
      'iPhone15Plus': 'iPhone15,5',
      'iPhone15Pro': 'iPhone16,1',
      'iPhone15ProMax': 'iPhone16,2',
      'iPhone16': 'iPhone17,3',
      'iPhone16Plus': 'iPhone17,4',
      'iPhone16Pro': 'iPhone17,1',
      'iPhone16ProMax': 'iPhone17,2',
      'iPhone17': 'iPhone18,3',
      'iPhoneAir': 'iPhone18,4',
      'iPhone17Pro': 'iPhone18,1',
      'iPhone17ProMax': 'iPhone18,2',
    };

    dynamicIslandDevices.forEach((deviceName, deviceCode) {
      testWidgets('$deviceName should display Dynamic Island logo', (
        tester,
      ) async {
        await setOrientation(Orientation.portrait);
        const dynamicIslandKey = ValueKey('dynamic_island');
        DeviceInfoService.setMockMachineIdentifier(deviceCode);
        await tester.pumpWidget(
          const EmptyAppWithHiddenLogo(dynamicIslandKey: dynamicIslandKey),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(dynamicIslandKey), findsOneWidget);
        final parser = HiddenLogoParser(machineIdentifier: deviceCode);
        expect(parser.iPhonesLogoType, equals(LogoType.dynamicIsland));
      });
    });
  });
}
