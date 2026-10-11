import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';

import '../utils.dart';

void main() {
  group('Get logo constraints from parser', () {
    void testConstraintsParsing(
      DeviceModel iPhone,
      BoxConstraints expectedConstraints,
    ) {
      test(
          'When device is ${iPhone.name}, '
          'constraints should be $expectedConstraints', () {
        final machineId = TestUtils.getMachineIdentifier(iPhone);
        final parser = HiddenLogoParser(machineIdentifier: machineId);
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
    testConstraintsParsing(DeviceModel.iPhone17e, bc330x1620);
    const bc330x2300 = BoxConstraints(maxHeight: 33.0, maxWidth: 230.0);
    testConstraintsParsing(DeviceModel.iPhoneXr, bc330x2300);
    testConstraintsParsing(DeviceModel.iPhone11, bc330x2300);
    const bc310x2110 = BoxConstraints(maxHeight: 31.0, maxWidth: 211.0);
    testConstraintsParsing(DeviceModel.iPhone12, bc310x2110);
    testConstraintsParsing(DeviceModel.iPhone12Pro, bc310x2110);
    testConstraintsParsing(DeviceModel.iPhone12ProMax, bc310x2110);
    const bc333x2260 = BoxConstraints(maxHeight: 33.3, maxWidth: 226.0);
    testConstraintsParsing(DeviceModel.iPhone12Mini, bc333x2260);
    const bc347x1750 = BoxConstraints(maxHeight: 37.4, maxWidth: 175.0);
    testConstraintsParsing(DeviceModel.iPhone13Mini, bc347x1750);
    const bc347x1200 = BoxConstraints(maxHeight: 34.7, maxWidth: 120.0);
    testConstraintsParsing(DeviceModel.iPhone14Pro, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone14ProMax, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone15, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone15Plus, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone15Pro, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone15ProMax, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone16, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone16Plus, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone16Pro, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone16ProMax, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone17, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhoneAir, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone17Pro, bc347x1200);
    testConstraintsParsing(DeviceModel.iPhone17ProMax, bc347x1200);
    testConstraintsParsing(
      DeviceModel.iPhone18Pro,
      const BoxConstraints(maxHeight: 34.0, maxWidth: 93.0),
    );
    testConstraintsParsing(
      DeviceModel.iPhone18ProMax,
      const BoxConstraints(maxHeight: 34.0, maxWidth: 93.0),
    );

    test('Should return 0x0 BoxConstraints if unable to parse iPhone', () {
      final parser = HiddenLogoParser(machineIdentifier: null);
      expect(
        parser.logoConstraints,
        const BoxConstraints(maxHeight: 0, maxWidth: 0),
      );
    });
  });

  group('Get dynamic island logo top margin from parser', () {
    void testTopMarginParsing(DeviceModel iPhone, double expectedMargin) {
      test(
          'When device is ${iPhone.name}, '
          'top margin should be $expectedMargin', () {
        final machineId = TestUtils.getMachineIdentifier(iPhone);
        final parser = HiddenLogoParser(machineIdentifier: machineId);
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
    testTopMarginParsing(DeviceModel.iPhone17e, 0);
    testTopMarginParsing(DeviceModel.iPhone14Pro, 12.3);
    testTopMarginParsing(DeviceModel.iPhone14ProMax, 12.3);
    testTopMarginParsing(DeviceModel.iPhone15, 12.3);
    testTopMarginParsing(DeviceModel.iPhone15Pro, 12.3);
    testTopMarginParsing(DeviceModel.iPhone15Plus, 12.3);
    testTopMarginParsing(DeviceModel.iPhone15ProMax, 12.3);
    testTopMarginParsing(DeviceModel.iPhone16, 12.3);
    testTopMarginParsing(DeviceModel.iPhone16Plus, 12.3);
    testTopMarginParsing(DeviceModel.iPhone16Pro, 15.0);
    testTopMarginParsing(DeviceModel.iPhone16ProMax, 15.0);
    testTopMarginParsing(DeviceModel.iPhone17, 15.0);
    testTopMarginParsing(DeviceModel.iPhone17Pro, 15.0);
    testTopMarginParsing(DeviceModel.iPhone17ProMax, 15.0);
    testTopMarginParsing(DeviceModel.iPhone18Pro, 15.3);
    testTopMarginParsing(DeviceModel.iPhone18ProMax, 15.3);
    testTopMarginParsing(DeviceModel.iPhoneAir, 21.0);

    test('Should return 0 top margin if unable to parse iPhone', () {
      final parser = HiddenLogoParser(machineIdentifier: null);
      expect(parser.dynamicIslandTopMargin, 0);
    });
  });
}
