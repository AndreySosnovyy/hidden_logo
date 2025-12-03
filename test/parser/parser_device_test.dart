import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';

import '../utils.dart';

void main() {
  group('Handle cases when unable to fetch valid iPhone\'s code', () {
    test('Should return null if machine identifier is null', () {
      final parser = HiddenLogoParser(machineIdentifier: null);
      expect(parser.currentIPhone, null);
    });

    test('Should return null if code is in unexpected format (no prefix)', () {
      final parser = HiddenLogoParser(machineIdentifier: '10,6');
      expect(parser.currentIPhone, null);
    });

    test('Should throw assertion error if code is empty', () {
      expect(
        () => HiddenLogoParser(machineIdentifier: ''),
        throwsAssertionError,
      );
    });

    test('Should return null if code is unknown', () {
      final parser = HiddenLogoParser(machineIdentifier: 'iPhone52,9');
      expect(parser.currentIPhone, null);
    });

    test('Should return null if code has dot instead of comma', () {
      final parser = HiddenLogoParser(machineIdentifier: 'iPhone10.6');
      expect(parser.currentIPhone, null);
    });

    test('Should return null if code is not full', () {
      final parser = HiddenLogoParser(machineIdentifier: 'iPhone11');
      expect(parser.currentIPhone, null);
    });

    test('Should throw assertion error if code has a whitespace', () {
      expect(
        () => HiddenLogoParser(machineIdentifier: 'iPhone 10,6'),
        throwsAssertionError,
      );
    });

    test('Should throw assertion error if code has trailing whitespace', () {
      expect(
        () => HiddenLogoParser(machineIdentifier: 'iPhone15,2 '),
        throwsAssertionError,
      );
    });

    test('Should throw assertion error if code has leading whitespace', () {
      expect(
        () => HiddenLogoParser(machineIdentifier: ' iPhone15,2'),
        throwsAssertionError,
      );
    });

    test('Should return null for simulator identifiers', () {
      final parserX86 = HiddenLogoParser(machineIdentifier: 'x86_64');
      expect(parserX86.currentIPhone, null);

      final parserArm = HiddenLogoParser(machineIdentifier: 'arm64');
      expect(parserArm.currentIPhone, null);
    });
  });

  group('Get iPhones from codes provided by DeviceInfo', () {
    void testCodeParsing(String deviceCode, DeviceModel expectedIphone) {
      test('Should return ${expectedIphone.name} when code is $deviceCode', () {
        final parser = HiddenLogoParser(machineIdentifier: deviceCode);
        expect(parser.currentIPhone, expectedIphone);
      });
    }

    testCodeParsing('iPhone10,6', DeviceModel.iPhoneX);
    testCodeParsing('iPhone11,2', DeviceModel.iPhoneXs);
    testCodeParsing('iPhone11,4', DeviceModel.iPhoneXsMax);
    testCodeParsing('iPhone11,6', DeviceModel.iPhoneXsMax);
    testCodeParsing('iPhone11,8', DeviceModel.iPhoneXr);
    testCodeParsing('iPhone12,1', DeviceModel.iPhone11);
    testCodeParsing('iPhone12,3', DeviceModel.iPhone11Pro);
    testCodeParsing('iPhone12,5', DeviceModel.iPhone11ProMax);
    testCodeParsing('iPhone13,1', DeviceModel.iPhone12Mini);
    testCodeParsing('iPhone13,2', DeviceModel.iPhone12);
    testCodeParsing('iPhone13,3', DeviceModel.iPhone12Pro);
    testCodeParsing('iPhone13,4', DeviceModel.iPhone12ProMax);
    testCodeParsing('iPhone14,2', DeviceModel.iPhone13Pro);
    testCodeParsing('iPhone14,3', DeviceModel.iPhone13ProMax);
    testCodeParsing('iPhone14,4', DeviceModel.iPhone13Mini);
    testCodeParsing('iPhone14,5', DeviceModel.iPhone13);
    testCodeParsing('iPhone14,7', DeviceModel.iPhone14);
    testCodeParsing('iPhone14,8', DeviceModel.iPhone14Plus);
    testCodeParsing('iPhone15,2', DeviceModel.iPhone14Pro);
    testCodeParsing('iPhone15,3', DeviceModel.iPhone14ProMax);
    testCodeParsing('iPhone15,4', DeviceModel.iPhone15);
    testCodeParsing('iPhone15,5', DeviceModel.iPhone15Plus);
    testCodeParsing('iPhone16,1', DeviceModel.iPhone15Pro);
    testCodeParsing('iPhone16,2', DeviceModel.iPhone15ProMax);
    testCodeParsing('iPhone17,3', DeviceModel.iPhone16);
    testCodeParsing('iPhone17,4', DeviceModel.iPhone16Plus);
    testCodeParsing('iPhone17,1', DeviceModel.iPhone16Pro);
    testCodeParsing('iPhone17,2', DeviceModel.iPhone16ProMax);
    testCodeParsing('iPhone17,5', DeviceModel.iPhone16e);
    testCodeParsing('iPhone18,1', DeviceModel.iPhone17Pro);
    testCodeParsing('iPhone18,2', DeviceModel.iPhone17ProMax);
    testCodeParsing('iPhone18,3', DeviceModel.iPhone17);
    testCodeParsing('iPhone18,4', DeviceModel.iPhoneAir);
  });

  group('Logo types for iPhones', () {
    void testLogoTypeParsing(DeviceModel iPhone, LogoType expectedLogoType) {
      test(
        'Should return ${expectedLogoType.name} when iPhone is ${iPhone.name}',
        () {
          final machineId = TestUtils.getMachineIdentifier(iPhone);
          final parser = HiddenLogoParser(machineIdentifier: machineId);
          expect(parser.iPhonesLogoType, expectedLogoType);
        },
      );
    }

    testLogoTypeParsing(DeviceModel.iPhoneX, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhoneXr, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhoneXs, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhoneXsMax, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone11, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone11Pro, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone11ProMax, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone12Mini, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone12, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone12Pro, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone12ProMax, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone13Pro, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone13ProMax, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone13Mini, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone13, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone14, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone14Plus, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone16e, LogoType.notch);
    testLogoTypeParsing(DeviceModel.iPhone14Pro, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone14ProMax, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone15, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone15Plus, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone15Pro, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone15ProMax, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone16, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone16Plus, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone16Pro, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone16ProMax, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone17, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhoneAir, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone17Pro, LogoType.dynamicIsland);
    testLogoTypeParsing(DeviceModel.iPhone17ProMax, LogoType.dynamicIsland);

    test('Should throw assertion error when device is not supported', () {
      final parser = HiddenLogoParser(machineIdentifier: null);
      expect(() => parser.iPhonesLogoType, throwsAssertionError);
    });
  });

  group('getIPhoneMachineIdentifier static method', () {
    test('Should return correct code for known device', () {
      final code = HiddenLogoParser.getIPhoneMachineIdentifier(
        DeviceModel.iPhoneX,
      );
      expect(code, '10,6');
    });

    test('Should return code that can be used to get device back', () {
      for (final device in DeviceModel.values) {
        final code = HiddenLogoParser.getIPhoneMachineIdentifier(device);
        expect(code, isNotNull, reason: '$device should have a code');

        final parser = HiddenLogoParser(machineIdentifier: 'iPhone$code');
        expect(
          parser.currentIPhone,
          device,
          reason: 'Code $code should map back to $device',
        );
      }
    });
  });
}
