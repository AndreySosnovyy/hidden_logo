import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for retrieving iOS device machine identifier via platform channel.
class DeviceInfoService {
  static const _channel = MethodChannel('hidden_logo');

  static Future<String?>? _future;

  /// Returns the iOS machine identifier (e.g., "iPhone15,2").
  ///
  /// Returns `null` on non-iOS platforms or if unable to retrieve the identifier.
  /// The result is cached after the first call.
  static Future<String?> getMachineIdentifier() {
    return _future ??= _fetchMachineIdentifier();
  }

  static Future<String?> _fetchMachineIdentifier() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    try {
      return await _channel.invokeMethod<String>('getMachineIdentifier');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Sets a mock machine identifier for testing purposes.
  @visibleForTesting
  static void setMockMachineIdentifier(String? value) {
    _future = Future<String?>.value(value);
  }

  /// Resets the cached value. Used for testing.
  @visibleForTesting
  static void reset() {
    _future = null;
  }
}
