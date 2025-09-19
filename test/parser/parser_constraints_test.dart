import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockBaseDeviceInfo extends Mock implements BaseDeviceInfo {}

void main() {
  final mockBaseDeviceInfo = MockBaseDeviceInfo();
  final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);

  group('Get logo constraints from parser', () {
    void testConstraintsParsing(
      DeviceModel iPhone,
      BoxConstraints expectedConstraints,
    ) {
      test(
          'When device is ${iPhone.name}, '
          'constraints should be $expectedConstraints', () {
        when(() => mockBaseDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap(
                'iPhone${TestUtils.iPhoneToCode(iPhone)}'));
        expect(parser.logoConstraints, expectedConstraints);
      });
    }

    const bc300x2090 = BoxConstraints(maxHeight: 30.0, maxWidth: 209.0);
    testConstraintsParsing(DeviceModel.iPhoneX, bc300x2090);
    testConstraintsParsing(DeviceModel.iPhoneXs, bc300x2090);
    testConstraintsParsing(DeviceModel.iPhoneXsMax, bc300x2090);
    testConstraintsParsing(DeviceModel.iPhone11Pro, bc300x2090);
    testConstraintsParsing(DeviceModel.iPhone11ProMax, bc300x2090);
    const bc330x1620 = BoxConstraints(maxHeight: 33.0, maxWidth: 162.0);
    testConstraintsParsing(DeviceModel.iPhone13Pro, bc330x1620);
    testConstraintsParsing(DeviceModel.iPhone13ProMax, bc330x1620);
    testConstraintsParsing(DeviceModel.iPhone14, bc330x1620);
    testConstraintsParsing(DeviceModel.iPhone14Plus, bc330x1620);
    testConstraintsParsing(DeviceModel.iPhone13, bc330x1620);
    testConstraintsParsing(DeviceModel.iPhone16e, bc330x1620);
    const bc330x2300 = BoxConstraints(maxHeight: 33.0, maxWidth: 230.0);
    testConstraintsParsing(DeviceModel.iPhoneXr, bc330x2300);
    testConstraintsParsing(DeviceModel.iPhone11, bc330x2300);
    const bc322x2110 = BoxConstraints(maxHeight: 32.2, maxWidth: 211.0);
    testConstraintsParsing(DeviceModel.iPhone12, bc322x2110);
    testConstraintsParsing(DeviceModel.iPhone12Pro, bc322x2110);
    testConstraintsParsing(DeviceModel.iPhone12ProMax, bc322x2110);
    const bc347x2260 = BoxConstraints(maxHeight: 34.7, maxWidth: 226.0);
    testConstraintsParsing(DeviceModel.iPhone12Mini, bc347x2260);
    const bc347x1750 = BoxConstraints(maxHeight: 37.4, maxWidth: 175.0);
    testConstraintsParsing(DeviceModel.iPhone13Mini, bc347x1750);
    const bc367x1220 = BoxConstraints(maxHeight: 36.7, maxWidth: 122.0);
    testConstraintsParsing(DeviceModel.iPhone14Pro, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone14ProMax, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone15, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone15Plus, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone15Pro, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone15ProMax, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone16, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone16Plus, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone16Pro, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone16ProMax, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone17, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhoneAir, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone17Pro, bc367x1220);
    testConstraintsParsing(DeviceModel.iPhone17ProMax, bc367x1220);

    test('Should return 0x0 BoxConstrains if unable to parse iPhone', () {
      when(() => parser.currentIPhone).thenReturn(null);
      expect(parser.logoConstraints,
          const BoxConstraints(maxHeight: 0, maxWidth: 0));
    });
  });

  group('Get dynamic island logo top margin from parser', () {
    void testTopMarginParsing(
      DeviceModel iPhone,
      double expectedMargin,
    ) {
      test(
          'When device is ${iPhone.name}, '
          'top margin should be $expectedMargin', () {
        when(() => mockBaseDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap(
                'iPhone${TestUtils.iPhoneToCode(iPhone)}'));
        expect(parser.dynamicIslandTopMargin, expectedMargin);
      });
    }

    testTopMarginParsing(DeviceModel.iPhoneX, 0);
    testTopMarginParsing(DeviceModel.iPhoneXr, 0);
    testTopMarginParsing(DeviceModel.iPhoneXs, 0);
    testTopMarginParsing(DeviceModel.iPhoneXsMax, 0);
    testTopMarginParsing(DeviceModel.iPhone11, 0);
    testTopMarginParsing(DeviceModel.iPhone11Pro, 0);
    testTopMarginParsing(DeviceModel.iPhone11ProMax, 0);
    testTopMarginParsing(DeviceModel.iPhone12, 0);
    testTopMarginParsing(DeviceModel.iPhone12Mini, 0);
    testTopMarginParsing(DeviceModel.iPhone12Pro, 0);
    testTopMarginParsing(DeviceModel.iPhone12ProMax, 0);
    testTopMarginParsing(DeviceModel.iPhone13, 0);
    testTopMarginParsing(DeviceModel.iPhone13Mini, 0);
    testTopMarginParsing(DeviceModel.iPhone13Pro, 0);
    testTopMarginParsing(DeviceModel.iPhone13ProMax, 0);
    testTopMarginParsing(DeviceModel.iPhone14, 0);
    testTopMarginParsing(DeviceModel.iPhone14Plus, 0);
    testTopMarginParsing(DeviceModel.iPhone16e, 0);
    testTopMarginParsing(DeviceModel.iPhone14Pro, 11.3);
    testTopMarginParsing(DeviceModel.iPhone14ProMax, 11.3);
    testTopMarginParsing(DeviceModel.iPhone15, 11.3);
    testTopMarginParsing(DeviceModel.iPhone15Pro, 11.3);
    testTopMarginParsing(DeviceModel.iPhone15Plus, 11.3);
    testTopMarginParsing(DeviceModel.iPhone15ProMax, 11.3);
    testTopMarginParsing(DeviceModel.iPhone16, 11.3);
    testTopMarginParsing(DeviceModel.iPhone16Plus, 11.3);
    testTopMarginParsing(DeviceModel.iPhone16Pro, 14.0);
    testTopMarginParsing(DeviceModel.iPhone16ProMax, 14.0);
    testTopMarginParsing(DeviceModel.iPhone17, 14.0);
    testTopMarginParsing(DeviceModel.iPhone17Pro, 14.0);
    testTopMarginParsing(DeviceModel.iPhone17ProMax, 14.0);
    testTopMarginParsing(DeviceModel.iPhoneAir, 20.0);

    test('Should return 0 top margin if unable to parse iPhone', () {
      when(() => parser.currentIPhone).thenReturn(null);
      expect(parser.dynamicIslandTopMargin, 0);
    });
  });
}
