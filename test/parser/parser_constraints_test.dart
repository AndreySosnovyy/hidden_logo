import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

import '../parsing_utils.dart';

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
            IPhoneParsingUtil.buildMockDeviceInfoDataMap(
                'iPhone${IPhoneParsingUtil.iPhoneToCode(iPhone)}'));
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
    const bc370x1220 = BoxConstraints(maxHeight: 37.0, maxWidth: 122.0);
    testConstraintsParsing(DeviceModel.iPhone16Pro, bc370x1220);
    testConstraintsParsing(DeviceModel.iPhone16ProMax, bc370x1220);

    test('Should return 0x0 BoxConstrains if unable to parse iPhone', () {
      when(() => parser.currentIPhone).thenReturn(null);
      expect(parser.logoConstraints,
          const BoxConstraints(maxHeight: 0, maxWidth: 0));
    });
  });
}
