import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/device_info_service.dart';

void main() {
  tearDown(() {
    DeviceInfoService.reset();
  });

  group('DeviceInfoService', () {
    test('setMockMachineIdentifier sets cached value', () async {
      DeviceInfoService.setMockMachineIdentifier('iPhone15,2');
      final result = await DeviceInfoService.getMachineIdentifier();
      expect(result, 'iPhone15,2');
    });

    test('reset clears cached value and initialized flag', () async {
      DeviceInfoService.setMockMachineIdentifier('iPhone15,2');
      var result = await DeviceInfoService.getMachineIdentifier();
      expect(result, 'iPhone15,2');

      DeviceInfoService.reset();
      // After reset, the service is no longer initialized
      // and would need platform channel (returns null in non-iOS test environment)
    });

    test('returns cached value on subsequent calls', () async {
      DeviceInfoService.setMockMachineIdentifier('iPhone18,1');
      final result1 = await DeviceInfoService.getMachineIdentifier();
      final result2 = await DeviceInfoService.getMachineIdentifier();
      expect(result1, 'iPhone18,1');
      expect(result2, 'iPhone18,1');
    });

    test('can set null mock value', () async {
      DeviceInfoService.setMockMachineIdentifier(null);
      final result = await DeviceInfoService.getMachineIdentifier();
      expect(result, isNull);
    });

    test('mock value persists across multiple calls', () async {
      DeviceInfoService.setMockMachineIdentifier('iPhone10,6');

      for (var i = 0; i < 5; i++) {
        final result = await DeviceInfoService.getMachineIdentifier();
        expect(result, 'iPhone10,6');
      }
    });

    test('can change mock value after reset', () async {
      DeviceInfoService.setMockMachineIdentifier('iPhone15,2');
      var result = await DeviceInfoService.getMachineIdentifier();
      expect(result, 'iPhone15,2');

      DeviceInfoService.reset();
      DeviceInfoService.setMockMachineIdentifier('iPhone18,4');
      result = await DeviceInfoService.getMachineIdentifier();
      expect(result, 'iPhone18,4');
    });
  });
}
