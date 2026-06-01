/// Stub implementation for platforms without native hidden logo support.
///
/// **Note:** This class is for internal use by Flutter's plugin system only.
/// Do not use this class directly in your code.
class HLStub {
  HLStub._();

  /// Registers the stub plugin with Flutter's plugin system.
  ///
  /// Accepts an optional registrar so the same stub satisfies both the
  /// Dart-only platform registration (called without arguments) and the web
  /// plugin registrant (called with a `Registrar`). The argument is ignored
  /// because the stub is a no-op on unsupported platforms.
  static void registerWith([Object? registrar]) {}
}
