import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockBaseDeviceInfo extends Mock implements BaseDeviceInfo {}

void main() {
  group('Error State Handling Tests', () {
    late MockBaseDeviceInfo mockDeviceInfo;
    late HiddenLogoParser parser;

    setUp(() {
      mockDeviceInfo = MockBaseDeviceInfo();
      parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);
    });

    group('Device Info Parsing Errors', () {
      test('Should handle TypeError when data is null', () {
        when(() => mockDeviceInfo.data).thenThrow(TypeError());

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
        expect(parser.logoConstraints.maxHeight, equals(0));
        expect(parser.logoConstraints.maxWidth, equals(0));
      });

      test('Should handle NoSuchMethodError when data structure is unexpected', () {
        when(() => mockDeviceInfo.data).thenThrow(NoSuchMethodError.withInvocation(
          null, Invocation.getter(#data)));

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle RangeError when substring operation fails', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'iP'} // Too short for substring
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle generic Exception gracefully', () {
        when(() => mockDeviceInfo.data).thenThrow(Exception('Unexpected error'));

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
        expect(parser.logoConstraints.maxHeight, equals(0));
      });
    });

    group('Malformed Device Data Handling', () {
      test('Should handle null utsname field', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': null
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle missing utsname field', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'other_field': 'value'
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle null machine field', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': null}
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle missing machine field', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'other_field': 'value'}
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle non-string machine field', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 12345} // Integer instead of string
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle empty machine field', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': ''}
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });
    });

    group('Invalid Device Code Scenarios', () {
      test('Should handle device code with unexpected format', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'iPhone-invalid-format'}
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle device code with special characters', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'iPhone@#\$%'}
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle future unknown device codes gracefully', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'iPhone99,99'} // Future unknown device
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
        expect(parser.logoConstraints.maxHeight, equals(0));
        expect(parser.logoConstraints.maxWidth, equals(0));
        expect(parser.dynamicIslandTopMargin, equals(0));
      });

      test('Should handle non-iPhone devices gracefully', () {
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'iPad14,1'} // iPad device
        });

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });
    });

    group('Recovery from Failed Detection', () {
      test('Should maintain consistent state after multiple errors', () {
        // First call throws error
        when(() => mockDeviceInfo.data).thenThrow(TypeError());
        expect(parser.currentIPhone, isNull);

        // Second call returns valid data
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));

        // Parser should recover and work correctly
        expect(parser.currentIPhone, isNotNull);
        expect(parser.isTargetIPhone, isTrue);
        expect(parser.logoConstraints.maxHeight, greaterThan(0));
      });

      test('Should handle alternating valid and invalid data', () {
        // Start with valid data
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        expect(parser.currentIPhone, isNotNull);

        // Switch to invalid data
        when(() => mockDeviceInfo.data).thenReturn({});
        expect(parser.currentIPhone, isNull);

        // Switch back to valid data
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone10,6'));
        expect(parser.currentIPhone, isNotNull);
      });
    });
  });
}