import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockBaseDeviceInfo extends Mock implements BaseDeviceInfo {}

void main() {
  group('Constraint Validation Tests', () {
    group('Invalid Constraint Scenarios', () {
      test('Should return zero constraints for null device', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn({});
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        final constraints = parser.logoConstraints;
        expect(constraints.maxHeight, equals(0));
        expect(constraints.maxWidth, equals(0));
        expect(constraints.minHeight, equals(0));
        expect(constraints.minWidth, equals(0));
      });

      test('Should return valid BoxConstraints for all known devices', () {
        final allDeviceCodes = [
          'iPhone10,6', // iPhone X
          'iPhone11,2', // iPhone Xs
          'iPhone15,2', // iPhone 14 Pro
          'iPhone16,1', // iPhone 15 Pro
          'iPhone17,1', // iPhone 16 Pro
          'iPhone18,1', // iPhone 17 Pro
        ];

        for (final deviceCode in allDeviceCodes) {
          final mockDeviceInfo = MockBaseDeviceInfo();
          when(() => mockDeviceInfo.data).thenReturn(
              TestUtils.buildMockDeviceInfoDataMap(deviceCode));
          final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

          final constraints = parser.logoConstraints;

          // All constraints should be positive and reasonable
          expect(constraints.maxHeight, greaterThan(0),
              reason: 'Height should be positive for $deviceCode');
          expect(constraints.maxWidth, greaterThan(0),
              reason: 'Width should be positive for $deviceCode');
          expect(constraints.maxHeight, lessThan(100),
              reason: 'Height should be reasonable for $deviceCode');
          expect(constraints.maxWidth, lessThan(500),
              reason: 'Width should be reasonable for $deviceCode');
        }
      });
    });

    group('Constraint Boundary Testing', () {
      test('Should have consistent constraint properties', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        final constraints = parser.logoConstraints;

        // BoxConstraints should be well-formed
        expect(constraints.minWidth, lessThanOrEqualTo(constraints.maxWidth));
        expect(constraints.minHeight, lessThanOrEqualTo(constraints.maxHeight));
        expect(constraints.minWidth, greaterThanOrEqualTo(0));
        expect(constraints.minHeight, greaterThanOrEqualTo(0));
      });

      test('Should have different constraints for different device types', () {
        // Test notch device
        final mockNotchDevice = MockBaseDeviceInfo();
        when(() => mockNotchDevice.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone10,6')); // iPhone X
        final notchParser = HiddenLogoParser(deviceInfo: mockNotchDevice);

        // Test Dynamic Island device
        final mockDynamicIslandDevice = MockBaseDeviceInfo();
        when(() => mockDynamicIslandDevice.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2')); // iPhone 14 Pro
        final dynamicIslandParser = HiddenLogoParser(deviceInfo: mockDynamicIslandDevice);

        final notchConstraints = notchParser.logoConstraints;
        final dynamicIslandConstraints = dynamicIslandParser.logoConstraints;

        // Constraints should be different
        expect(notchConstraints.maxWidth, isNot(equals(dynamicIslandConstraints.maxWidth)));
        expect(notchConstraints.maxHeight, isNot(equals(dynamicIslandConstraints.maxHeight)));
      });
    });

    group('Dynamic Island Top Margin Validation', () {
      test('Should return zero margin for notch devices', () {
        final notchDevices = ['iPhone10,6', 'iPhone11,2', 'iPhone12,1', 'iPhone13,1'];

        for (final deviceCode in notchDevices) {
          final mockDeviceInfo = MockBaseDeviceInfo();
          when(() => mockDeviceInfo.data).thenReturn(
              TestUtils.buildMockDeviceInfoDataMap(deviceCode));
          final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

          expect(parser.dynamicIslandTopMargin, equals(0),
              reason: 'Notch device $deviceCode should have zero top margin');
        }
      });

      test('Should return positive margin for Dynamic Island devices', () {
        final dynamicIslandDevices = ['iPhone15,2', 'iPhone16,1', 'iPhone17,1', 'iPhone18,4'];

        for (final deviceCode in dynamicIslandDevices) {
          final mockDeviceInfo = MockBaseDeviceInfo();
          when(() => mockDeviceInfo.data).thenReturn(
              TestUtils.buildMockDeviceInfoDataMap(deviceCode));
          final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

          expect(parser.dynamicIslandTopMargin, greaterThan(0),
              reason: 'Dynamic Island device $deviceCode should have positive top margin');
          expect(parser.dynamicIslandTopMargin, lessThan(50),
              reason: 'Top margin should be reasonable for $deviceCode');
        }
      });

      test('Should return zero margin for unknown devices', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn({});
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        expect(parser.dynamicIslandTopMargin, equals(0));
      });
    });

    group('Edge Cases for New Device Models', () {
      test('Should handle gracefully when new device models are added', () {
        // Simulate a future device code that doesn't exist yet
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'iPhone25,99'} // Future device
        });
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        // Should return sensible defaults
        expect(parser.currentIPhone, isNull);
        expect(parser.logoConstraints.maxHeight, equals(0));
        expect(parser.logoConstraints.maxWidth, equals(0));
        expect(parser.dynamicIslandTopMargin, equals(0));
      });

      test('Should validate constraints are usable for widget rendering', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        final constraints = parser.logoConstraints;

        // Constraints should be usable for creating widgets
        expect(() => Container(
          constraints: constraints,
          child: const SizedBox(),
        ), returnsNormally);

        // Constraints should be finite
        expect(constraints.maxWidth.isFinite, isTrue);
        expect(constraints.maxHeight.isFinite, isTrue);
        expect(constraints.maxWidth.isNaN, isFalse);
        expect(constraints.maxHeight.isNaN, isFalse);
      });
    });

    group('Constraint Consistency Tests', () {
      test('Should maintain consistent constraints across multiple calls', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

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
          final mockDeviceInfo = MockBaseDeviceInfo();
          when(() => mockDeviceInfo.data).thenReturn(
              TestUtils.buildMockDeviceInfoDataMap(deviceCode));
          final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

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