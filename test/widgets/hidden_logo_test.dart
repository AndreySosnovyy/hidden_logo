import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/base.dart';

class EmptyAppWithHiddenLogo extends StatelessWidget {
  const EmptyAppWithHiddenLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Scaffold(),
      builder: (context, child) {
        return HiddenLogo(
          notchBuilder: (_, __) => const SizedBox.shrink(),
          dynamicIslandBuilder: (_, __) => const SizedBox.shrink(),
          body: child!,
        );
      },
    );
  }
}

void main() {
  testWidgets('HiddenLogo should build a HiddenLogoBase widget', (
    tester,
  ) async {
    await tester.pumpWidget(const EmptyAppWithHiddenLogo());
    await tester.pumpAndSettle();
    expect(find.byType(HiddenLogoBase), findsOneWidget);
  });

  testWidgets('HiddenLogo parameters should be passed to HiddenLogoBase', (
    tester,
  ) async {
    await tester.pumpWidget(const EmptyAppWithHiddenLogo());
    await tester.pumpAndSettle();
    final wrapperFinder = find.byType(HiddenLogo);
    final baseFinder = find.byType(HiddenLogoBase);
    final wrapper = tester.widget<HiddenLogo>(wrapperFinder);
    final base = tester.widget<HiddenLogoBase>(baseFinder);
    expect(wrapper.visibilityMode, base.visibilityMode);
    expect(wrapper.isVisible, base.isVisible);
    expect(wrapper.notchBuilder, base.notchBuilder);
    expect(wrapper.dynamicIslandBuilder, base.dynamicIslandBuilder);
  });
}
