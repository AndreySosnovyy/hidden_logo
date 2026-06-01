import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/device_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DeviceInfoService.reset();
  });

  tearDown(() {
    DeviceInfoService.reset();
  });

  group('DeviceInfoService mock value', () {
    test('setMockMachineIdentifier sets cached value', () async {
      DeviceInfoService.setMockMachineIdentifier('iPhone15,2');
      final result = await DeviceInfoService.getMachineIdentifier();
      expect(result, 'iPhone15,2');
    });

    test('reset clears cached value', () async {
      DeviceInfoService.setMockMachineIdentifier('iPhone15,2');
      expect(await DeviceInfoService.getMachineIdentifier(), 'iPhone15,2');

      DeviceInfoService.reset();
      DeviceInfoService.setMockMachineIdentifier('iPhone10,6');
      expect(await DeviceInfoService.getMachineIdentifier(), 'iPhone10,6');
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

  group('DeviceInfoService platform channel', () {
    const channel = MethodChannel('hidden_logo');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      messenger.setMockMethodCallHandler(channel, null);
    });

    test('returns identifier from channel on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getMachineIdentifier');
        return 'iPhone15,2';
      });

      expect(await DeviceInfoService.getMachineIdentifier(), 'iPhone15,2');
    });

    test('returns null without invoking channel on non-iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      var invoked = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        invoked = true;
        return 'iPhone15,2';
      });

      expect(await DeviceInfoService.getMachineIdentifier(), isNull);
      expect(invoked, isFalse);
    });

    test('returns null on PlatformException and allows retry', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      var calls = 0;
      var shouldThrow = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        if (shouldThrow) {
          throw PlatformException(code: 'error');
        }
        return 'iPhone15,2';
      });

      // First call fails and must not cache the failure permanently.
      expect(await DeviceInfoService.getMachineIdentifier(), isNull);

      // A subsequent call must retry the channel rather than return cached null.
      shouldThrow = false;
      expect(await DeviceInfoService.getMachineIdentifier(), 'iPhone15,2');

      // The channel must actually be invoked twice (no cached failure).
      expect(calls, 2);
    });

    test('returns null on MissingPluginException and allows retry', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      var shouldThrow = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (shouldThrow) {
          throw MissingPluginException();
        }
        return 'iPhone15,2';
      });

      expect(await DeviceInfoService.getMachineIdentifier(), isNull);

      shouldThrow = false;
      expect(await DeviceInfoService.getMachineIdentifier(), 'iPhone15,2');
    });
  });
}
