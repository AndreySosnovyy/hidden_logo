import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Internal lookup outcome distinguishing unsupported devices from channel errors.
class MachineIdentifierResult {
  /// A completed lookup, including a permanent unsupported/null result.
  const MachineIdentifierResult(this.identifier) : isTransientFailure = false;

  /// A channel failure that may succeed after plugin registration or resume.
  const MachineIdentifierResult.transientFailure()
      : identifier = null,
        isTransientFailure = true;

  /// The machine identifier returned by the platform.
  final String? identifier;

  /// Whether another lookup may recover this result.
  final bool isTransientFailure;
}

/// Service for retrieving iOS device machine identifier via platform channel.
class DeviceInfoService {
  static const _channel = MethodChannel('hidden_logo');

  static Future<MachineIdentifierResult>? _future;

  /// Returns the iOS machine identifier (e.g., "iPhone15,2").
  ///
  /// Returns `null` on non-iOS platforms or if unable to retrieve the identifier.
  /// Successful results (including null) are cached; channel failures may retry.
  static Future<String?> getMachineIdentifier() async {
    return (await getMachineIdentifierResult()).identifier;
  }

  /// Returns the lookup outcome so mounted widgets can retry transient errors.
  static Future<MachineIdentifierResult> getMachineIdentifierResult() {
    if (_future != null) return _future!;
    final future = _fetchMachineIdentifier();
    _future = future;
    future.then((result) {
      if (result.isTransientFailure && identical(_future, future)) {
        _future = null;
      }
    });
    return future;
  }

  static Future<MachineIdentifierResult> _fetchMachineIdentifier() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const MachineIdentifierResult(null);
    }
    try {
      return MachineIdentifierResult(
        await _channel.invokeMethod<String>('getMachineIdentifier'),
      );
    } on PlatformException {
      return const MachineIdentifierResult.transientFailure();
    } on MissingPluginException {
      return const MachineIdentifierResult.transientFailure();
    }
  }

  /// Sets a mock machine identifier for testing purposes.
  @visibleForTesting
  static void setMockMachineIdentifier(String? value) {
    _future = Future.value(MachineIdentifierResult(value));
  }

  /// Resets the cached value. Used for testing.
  @visibleForTesting
  static void reset() {
    _future = null;
  }
}
