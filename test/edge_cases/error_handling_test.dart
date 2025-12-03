import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';

void main() {
  group('Error State Handling Tests', () {
    group('Machine Identifier Parsing Errors', () {
      test('Should handle null machine identifier', () {
        final parser = HiddenLogoParser(machineIdentifier: null);

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
        expect(parser.logoConstraints.maxHeight, equals(0));
        expect(parser.logoConstraints.maxWidth, equals(0));
      });

      test('Should throw assertion error for empty machine identifier', () {
        expect(
          () => HiddenLogoParser(machineIdentifier: ''),
          throwsAssertionError,
        );
      });

      test('Should handle very short machine identifier', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iP');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });
    });

    group('Invalid Device Code Scenarios', () {
      test('Should handle device code with unexpected format', () {
        final parser = HiddenLogoParser(
          machineIdentifier: 'iPhone-invalid-format',
        );

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle device code with special characters', () {
        final parser = HiddenLogoParser(machineIdentifier: r'iPhone@#$%');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle future unknown device codes gracefully', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone99,99');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
        expect(parser.logoConstraints.maxHeight, equals(0));
        expect(parser.logoConstraints.maxWidth, equals(0));
        expect(parser.dynamicIslandTopMargin, equals(0));
      });

      test('Should handle non-iPhone devices gracefully', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPad14,1');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle Mac identifier gracefully', () {
        final parser = HiddenLogoParser(machineIdentifier: 'MacBookPro18,1');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should throw assertion error for device code with whitespace', () {
        expect(
          () => HiddenLogoParser(machineIdentifier: 'iPhone 15,2'),
          throwsAssertionError,
        );
      });

      test(
        'Should throw assertion error for device code with leading whitespace',
        () {
          expect(
            () => HiddenLogoParser(machineIdentifier: ' iPhone15,2'),
            throwsAssertionError,
          );
        },
      );

      test('Should handle device code with dot instead of comma', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone15.2');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle device code with only prefix', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });
    });

    group('Simulator Identifiers', () {
      test('Should handle x86_64 simulator identifier', () {
        final parser = HiddenLogoParser(machineIdentifier: 'x86_64');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle arm64 simulator identifier', () {
        final parser = HiddenLogoParser(machineIdentifier: 'arm64');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle i386 simulator identifier', () {
        final parser = HiddenLogoParser(machineIdentifier: 'i386');

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });
    });

    group('Valid Device Parsing', () {
      test('Should correctly parse valid iPhone identifier', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone15,2');

        expect(parser.currentIPhone, DeviceModel.iPhone14Pro);
        expect(parser.isTargetIPhone, isTrue);
        expect(parser.logoConstraints.maxHeight, greaterThan(0));
        expect(parser.logoConstraints.maxWidth, greaterThan(0));
      });

      test('Should correctly parse oldest supported iPhone', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone10,6');

        expect(parser.currentIPhone, DeviceModel.iPhoneX);
        expect(parser.isTargetIPhone, isTrue);
      });

      test('Should correctly parse newest supported iPhone', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone18,4');

        expect(parser.currentIPhone, DeviceModel.iPhoneAir);
        expect(parser.isTargetIPhone, isTrue);
      });
    });
  });
}
