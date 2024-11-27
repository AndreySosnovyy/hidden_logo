import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';

class EmptyAppWithHiddenLogo extends StatelessWidget {
  const EmptyAppWithHiddenLogo({
    this.notchKey,
    this.dynamicIslandKey,
    this.isVisible = true,
    super.key,
  });

  final Key? notchKey;
  final Key? dynamicIslandKey;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HiddenLogo(
        isVisible: isVisible,
        notchBuilder: (_, __) => SizedBox.shrink(key: notchKey),
        dynamicIslandBuilder: (_, __) => SizedBox.shrink(key: dynamicIslandKey),
        body: const Scaffold(),
      ),
    );
  }
}

void main() {
  testWidgets('Wrapper should be displayed if isShown is true', (tester) async {
    const notchKey = ValueKey('notch');
    const dynamicIslandKey = ValueKey('dynamic_island');
    await tester.pumpWidget(const EmptyAppWithHiddenLogo(
      notchKey: notchKey,
      dynamicIslandKey: dynamicIslandKey,
    ));
    // final notchFinder = find.byKey(notchKey);
    // final dynamicIslandFinder = find.byKey(dynamicIslandKey);
    // expect(notchFinder, findsOneWidget);
  });
}
