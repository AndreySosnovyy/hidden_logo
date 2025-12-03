import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';

void main() {
  group('Constraint Validation Tests', () {
    group('Constraint Boundary Testing', () {
      test('Should have consistent constraint properties', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone15,2');

        final constraints = parser.logoConstraints;

        // BoxConstraints should be well-formed
        expect(constraints.minWidth, lessThanOrEqualTo(constraints.maxWidth));
        expect(constraints.minHeight, lessThanOrEqualTo(constraints.maxHeight));
        expect(constraints.minWidth, greaterThanOrEqualTo(0));
        expect(constraints.minHeight, greaterThanOrEqualTo(0));
      });

      test('Should have different constraints for different device types', () {
        // Test notch device
        final notchParser = HiddenLogoParser(
          machineIdentifier: 'iPhone10,6',
        ); // iPhone X

        // Test Dynamic Island device
        final dynamicIslandParser = HiddenLogoParser(
          machineIdentifier: 'iPhone15,2',
        ); // iPhone 14 Pro

        final notchConstraints = notchParser.logoConstraints;
        final dynamicIslandConstraints = dynamicIslandParser.logoConstraints;

        // Constraints should be different
        expect(
          notchConstraints.maxWidth,
          isNot(equals(dynamicIslandConstraints.maxWidth)),
        );
        expect(
          notchConstraints.maxHeight,
          isNot(equals(dynamicIslandConstraints.maxHeight)),
        );
      });
    });

    group('Edge Cases for New Device Models', () {
      test('Should handle gracefully when new device models are added', () {
        // Simulate a future device code that doesn't exist yet
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone25,99');

        // Should return sensible defaults
        expect(parser.currentIPhone, isNull);
        expect(parser.logoConstraints.maxHeight, equals(0));
        expect(parser.logoConstraints.maxWidth, equals(0));
        expect(parser.dynamicIslandTopMargin, equals(0));
      });

      test('Should validate constraints are usable for widget rendering', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone15,2');

        final constraints = parser.logoConstraints;

        // Constraints should be usable for creating widgets
        expect(
          () => Container(constraints: constraints, child: const SizedBox()),
          returnsNormally,
        );

        // Constraints should be finite
        expect(constraints.maxWidth.isFinite, isTrue);
        expect(constraints.maxHeight.isFinite, isTrue);
        expect(constraints.maxWidth.isNaN, isFalse);
        expect(constraints.maxHeight.isNaN, isFalse);
      });
    });

    group('Constraint Consistency Tests', () {
      test('Should maintain consistent constraints across multiple calls', () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone15,2');

        final constraints1 = parser.logoConstraints;
        final constraints2 = parser.logoConstraints;
        final constraints3 = parser.logoConstraints;

        expect(constraints1, equals(constraints2));
        expect(constraints2, equals(constraints3));
      });

      test('Should have consistent logo type and constraints', () {
        final testCases = {
          'iPhone10,6': LogoType.notch,
          'iPhone15,2': LogoType.dynamicIsland,
          'iPhone17,1': LogoType.dynamicIsland,
        };

        testCases.forEach((deviceCode, expectedLogoType) {
          final parser = HiddenLogoParser(machineIdentifier: deviceCode);

          expect(parser.iPhonesLogoType, equals(expectedLogoType));

          if (expectedLogoType == LogoType.dynamicIsland) {
            expect(parser.dynamicIslandTopMargin, greaterThan(0));
          } else {
            expect(parser.dynamicIslandTopMargin, equals(0));
          }
        });
      });
    });
  });
}
