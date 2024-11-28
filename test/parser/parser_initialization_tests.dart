import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

class MockBaseDeviceInfo extends Mock implements BaseDeviceInfo {}

void main() {
  group('_deviceInfo property initialization tests', () {
    test(
        'Parser should throw an error of StateError type if deviceInfo is not set but was called',
        () {
      final parser = HiddenLogoParser();
      expect(() => parser.currentIPhone, throwsA(isA<StateError>()));
    });

    test('Parser should work if BaseDeviceInfo is provided via constructor',
        () {
      final mockBaseDeviceInfo = MockBaseDeviceInfo();
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      expect(parser.currentIPhone, anyOf([null, DeviceModel]));
    });

    test('Parser should work if BaseDeviceInfo is set via setter', () {
      final mockBaseDeviceInfo = MockBaseDeviceInfo();
      final parser = HiddenLogoParser();
      parser.deviceInfo = mockBaseDeviceInfo;
      expect(parser.currentIPhone, anyOf([null, DeviceModel]));
    });

    test('Parser should throw an error of StateError type if deviceInfo is '
        'set via constructor and then set via setter', () {
      final mockBaseDeviceInfo = MockBaseDeviceInfo();
      final parser = HiddenLogoParser(deviceInfo: mockBaseDeviceInfo);
      expect(() => parser.deviceInfo = mockBaseDeviceInfo,
          throwsA(isA<StateError>()));
    });

    test('Parser should throw an error of StateError type if deviceInfo is '
        'set via setter 2 times', () {
      final mockBaseDeviceInfo = MockBaseDeviceInfo();
      final parser = HiddenLogoParser();
      parser.deviceInfo = mockBaseDeviceInfo;
      expect(() => parser.deviceInfo = mockBaseDeviceInfo,
          throwsA(isA<StateError>()));
    });
  });
}
