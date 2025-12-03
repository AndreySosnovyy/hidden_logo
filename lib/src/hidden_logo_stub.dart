/// Stub implementation for platforms without native hidden logo support.
///
/// This class provides a no-op implementation for Android, Linux, macOS,
/// and Windows platforms. The hidden logo functionality is iOS-specific
/// (using iPhone notch or Dynamic Island), so these platforms simply
/// return null for device identification.
class HiddenLogoStub {
  /// Registers the stub plugin with Flutter's plugin system.
  ///
  /// This is a no-op since hidden logo functionality is iOS-specific.
  /// The device info service handles non-iOS platforms by returning null
  /// immediately without attempting native method calls.
  static void registerWith() {
    // No-op: Hidden logo only works on iOS devices with notch/Dynamic Island.
  }
}
