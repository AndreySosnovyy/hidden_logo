import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/device_info_service.dart';

void main() {
  tearDown(() {
    DeviceInfoService.reset();
    debugDefaultTargetPlatformOverride = null;
  });

  for (final fixture in [
    ('iPhone19,2', const Size(402, 874), const Offset(154.5, 15.3)),
    ('iPhone19,3', const Size(440, 956), const Offset(173.5, 15.3)),
    ('iPhone19,7', const Size(440, 956), const Offset(173.5, 15.3)),
  ]) {
    final identifier = fixture.$1;
    testWidgets('$identifier renders a capsule behind the Dynamic Island',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      DeviceInfoService.setMockMachineIdentifier(identifier);
      await tester.binding.setSurfaceSize(fixture.$2);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const logoKey = ValueKey('island-logo');
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(),
          builder: (context, child) => HiddenLogo(
            body: child!,
            notchBuilder: (_, __) => const Text('unexpected notch'),
            dynamicIslandBuilder: (_, constraints) => SizedBox(
              key: logoKey,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(logoKey), findsOneWidget);
      expect(tester.getSize(find.byKey(logoKey)), const Size(93, 34));
      expect(tester.getTopLeft(find.byKey(logoKey)), fixture.$3);
      expect(find.text('unexpected notch'), findsNothing);
      expect(
        find.ancestor(
          of: find.byKey(logoKey),
          matching: find.byType(ClipRRect),
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
