import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for retrieving iOS device machine identifier via platform channel.
class DeviceInfoService {
  static const _channel = MethodChannel('hidden_logo');

  static String? _cachedMachineId;
  static bool _initialized = false;

  /// Returns the iOS machine identifier (e.g., "iPhone15,2").
  ///
  /// Returns `null` on non-iOS platforms or if unable to retrieve the identifier.
  /// The result is cached after the first successful call.
  static Future<String?> getMachineIdentifier() async {
    if (_initialized) return _cachedMachineId;
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      _initialized = true;
      return null;
    }
    try {
      _cachedMachineId = await _channel.invokeMethod<String>(
        'getMachineIdentifier',
      );
    } on PlatformException {
      _cachedMachineId = null;
    } on MissingPluginException {
      _cachedMachineId = null;
    }
    _initialized = true;
    return _cachedMachineId;
  }

  /// Sets a mock machine identifier for testing purposes.
  @visibleForTesting
  static void setMockMachineIdentifier(String? value) {
    _cachedMachineId = value;
    _initialized = true;
  }

  /// Resets the cached value. Used for testing.
  @visibleForTesting
  static void reset() {
    _cachedMachineId = null;
    _initialized = false;
  }
}
