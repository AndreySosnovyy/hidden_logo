import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/base.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

class MockHiddenLogoParser extends Mock implements HiddenLogoParser {}

class EmptyAppWithHiddenLogo extends StatelessWidget {
  const EmptyAppWithHiddenLogo({
    this.parser,
    this.deviceInfoPlugin,
    this.isVisible = true,
    this.dynamicIslandKey,
    this.notchKey,
    super.key,
  });

  final Key? notchKey;
  final Key? dynamicIslandKey;
  final bool isVisible;
  final HiddenLogoParser? parser;
  final DeviceInfoPlugin? deviceInfoPlugin;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HiddenLogoBase(
        deviceInfoPlugin: deviceInfoPlugin ?? DeviceInfoPlugin(),
        parser: parser ?? MockHiddenLogoParser(),
        isVisible: isVisible,
        notchBuilder: (_, __) => SizedBox.shrink(key: notchKey),
        dynamicIslandBuilder: (_, __) => SizedBox.shrink(key: dynamicIslandKey),
        body: const Scaffold(),
      ),
    );
  }
}

void main() {
  group('HiddenLogo visibility', () {
    testWidgets('Notch should be displayed if isShown is true', (tester) async {
      final mockParser = MockHiddenLogoParser();
      const notchKey = ValueKey('notch');
      when(() => mockParser.currentIPhone).thenReturn(DeviceModel.iPhoneX);
      await tester.pumpWidget(EmptyAppWithHiddenLogo(
        parser: mockParser,
        notchKey: notchKey,
      ));
      final notchFinder = find.byKey(notchKey);
      expect(notchFinder, findsOneWidget);
    });
    testWidgets(
        'Notch should not be displayed if isShown is false', (tester) async {});
  });

  group('Test HiddenLogo is the same as HiddenLogoBase', () {});
}
