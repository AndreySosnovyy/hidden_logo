import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/device_info_service.dart';

void main() {
  const logoKey = ValueKey('logo');

  Future<void> pumpLogo(WidgetTester tester, String identifier) async {
    DeviceInfoService.reset();
    DeviceInfoService.setMockMachineIdentifier(identifier);
    Widget logo(BuildContext context, BoxConstraints constraints) => SizedBox(
          key: logoKey,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(),
        builder: (context, child) => HiddenLogo(
          body: child!,
          notchBuilder: logo,
          dynamicIslandBuilder: logo,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    DeviceInfoService.reset();
  });

  for (final fixture in [
    (
      'iPhone19,2',
      const Size(1206, 2622),
      const Size(1206, 2622),
      const Size(93, 34),
      15.3
    ),
    (
      'iPhone19,2',
      const Size(960, 2079),
      const Size(1206, 2622),
      const Size(74.029850746269, 27.064676616915),
      12.179104477612
    ),
    (
      'iPhone19,3',
      const Size(1320, 2868),
      const Size(1320, 2868),
      const Size(93, 34),
      15.3
    ),
    (
      'iPhone19,3',
      const Size(1125, 2436),
      const Size(1320, 2868),
      const Size(79.261363636364, 28.977272727273),
      13.039772727273
    ),
    (
      'iPhone19,7',
      const Size(1320, 2868),
      const Size(1320, 2868),
      const Size(93, 34),
      15.3
    ),
    (
      'iPhone19,7',
      const Size(1125, 2436),
      const Size(1320, 2868),
      const Size(79.261363636364, 28.977272727273),
      13.039772727273
    ),
    (
      'iPhone18,1',
      const Size(1206, 2622),
      const Size(1206, 2622),
      const Size(120, 34.7),
      15.0
    ),
    (
      'iPhone18,1',
      const Size(1125, 2436),
      const Size(1206, 2622),
      const Size(111.940298507463, 32.369402985075),
      13.992537313433
    ),
    (
      'iPhone18,1',
      const Size(960, 2079),
      const Size(1206, 2622),
      const Size(95.522388059701, 27.621890547264),
      11.940298507463
    ),
    (
      'iPhone15,2',
      const Size(1125, 2436),
      const Size(1179, 2556),
      const Size(114.503816793893, 33.110687022901),
      11.736641221374
    ),
    (
      'iPhone14,5',
      const Size(1125, 2436),
      const Size(1170, 2532),
      const Size(155.7692307692, 31.7307692308),
      0.0
    ),
    (
      'iPhone18,1',
      const Size(1206, 2622),
      Size.zero,
      const Size(120, 34.7),
      15.0
    ),
    (
      'iPhone13,1',
      const Size(1125, 2436),
      const Size(1080, 2340),
      const Size(226, 33.3),
      0.0,
    ),
    (
      'iPhone13,1',
      const Size(960, 2079),
      const Size(1080, 2340),
      const Size(192.8533333333, 28.416),
      0.0,
    ),
    (
      'iPhone14,4',
      const Size(960, 2079),
      const Size(1080, 2340),
      const Size(149.3333333333, 31.9146666667),
      0.0,
    ),
  ]) {
    testWidgets('${fixture.$1} fits its hardware barrier at ${fixture.$2}',
        (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = fixture.$2;
      tester.view.display.size = fixture.$3;
      addTearDown(tester.view.reset);
      addTearDown(tester.view.display.reset);
      await pumpLogo(tester, fixture.$1);
      final size = tester.getSize(find.byKey(logoKey));
      expect(size.width, closeTo(fixture.$4.width, 0.0001));
      expect(size.height, closeTo(fixture.$4.height, 0.0001));
      expect(
        tester.getTopLeft(find.byKey(logoKey)).dy,
        closeTo(fixture.$5, 0.0001),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('does not mistake a MediaQuery override for Display Zoom',
      (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.display.size = const Size(1206, 2622);
    addTearDown(tester.view.reset);
    addTearDown(tester.view.display.reset);
    DeviceInfoService.setMockMachineIdentifier('iPhone18,1');
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(size: const Size(200, 500)),
          child: HiddenLogo(
            body: child!,
            notchBuilder: (_, __) => const SizedBox.shrink(),
            dynamicIslandBuilder: (_, constraints) => SizedBox(
              key: logoKey,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(logoKey)), const Size(120, 34.7));
    expect(tester.getTopLeft(find.byKey(logoKey)).dy, 15);
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('repositions the logo when the view metrics change',
      (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.display.size = const Size(1206, 2622);
    addTearDown(tester.view.reset);
    addTearDown(tester.view.display.reset);
    await pumpLogo(tester, 'iPhone18,1');
    expect(tester.getSize(find.byKey(logoKey)), const Size(120, 34.7));

    tester.view.physicalSize = const Size(1125, 2436);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(logoKey)).width,
      closeTo(111.940298507463, 0.0001),
    );
    expect(
      tester.getTopLeft(find.byKey(logoKey)).dy,
      closeTo(13.992537313433, 0.0001),
    );

    tester.view.physicalSize = const Size(2436, 1125);
    await tester.pumpAndSettle();
    expect(find.byKey(logoKey), findsNothing);
    tester.view.physicalSize = const Size(1206, 2622);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(logoKey)), const Size(120, 34.7));
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });
}
