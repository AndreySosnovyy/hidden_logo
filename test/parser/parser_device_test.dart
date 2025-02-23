import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockBaseDeviceInfo extends Mock implements BaseDeviceInfo {}

void main() {
  final mockBaseDeviceInfo = MockBaseDeviceInfo();
  final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);

  group('Handle cases when unable to fetch valid iPhone\'s code', () {
    test('Should return null if data map is empty', () {
      when(() => mockBaseDeviceInfo.data).thenReturn({});
      expect(parser.currentIPhone, null);
    });
    test('Should return null if code is in unexpected format', () {
      when(() => mockBaseDeviceInfo.data)
          .thenReturn(TestUtils.buildMockDeviceInfoDataMap('10,6'));
      expect(parser.currentIPhone, null);
    });
    test('Should return null if code is empty', () {
      when(() => mockBaseDeviceInfo.data)
          .thenReturn(TestUtils.buildMockDeviceInfoDataMap(''));
      expect(parser.currentIPhone, null);
    });
    test('Should return null if code is unknown', () {
      when(() => mockBaseDeviceInfo.data)
          .thenReturn(TestUtils.buildMockDeviceInfoDataMap('iPhone52,9'));
      expect(parser.currentIPhone, null);
    });
    test('Should return null if code has dot instead of comma', () {
      when(() => mockBaseDeviceInfo.data)
          .thenReturn(TestUtils.buildMockDeviceInfoDataMap('iPhone10.6'));
      expect(parser.currentIPhone, null);
    });
    test('Should return null if code is not full', () {
      when(() => mockBaseDeviceInfo.data)
          .thenReturn(TestUtils.buildMockDeviceInfoDataMap('iPhone11'));
      expect(parser.currentIPhone, null);
    });
    test('Should return null if code has a whitespace', () {
      when(() => mockBaseDeviceInfo.data)
          .thenReturn(TestUtils.buildMockDeviceInfoDataMap('iPhone 10,6'));
      expect(parser.currentIPhone, null);
    });
    test('Should return null if code is not String', () {
      when(() => mockBaseDeviceInfo.data)
          .thenReturn(TestUtils.buildMockDeviceInfoDataMap(10.6));
      expect(parser.currentIPhone, null);
    });
  });

  group('Get iPhones from codes provided by DeviceInfo', () {
    void testCodeParsing(String deviceCode, DeviceModel expectedIphone) {
      test('Should return ${expectedIphone.name} when code is $deviceCode', () {
        when(() => mockBaseDeviceInfo.data)
            .thenReturn(TestUtils.buildMockDeviceInfoDataMap(deviceCode));
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
  });

  group('Logo types for iPhones', () {
    void testLogoTypeParsing(DeviceModel iPhone, LogoType expectedLogoType) {
      test(
          'Should return ${expectedLogoType.name} when iPhone is ${iPhone.name}',
          () {
        when(() => mockBaseDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap(
                'iPhone${TestUtils.iPhoneToCode(iPhone)}'));
        expect(parser.iPhonesLogoType, expectedLogoType);
      });
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

    test('Should return and assert error when device is not supported',
        () {
      when(() => mockBaseDeviceInfo.data).thenReturn({});
      expect(() => parser.iPhonesLogoType, throwsAssertionError);
    });
  });
}
