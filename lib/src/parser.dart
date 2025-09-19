import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// {@template hidden_logo.LogoType}
/// Defines the type of hardware barrier where the logo can be positioned
/// on supported iPhone devices.
///
/// Different iPhone models have different hardware barriers at the top
/// of the screen that can hide logos during certain scenarios like
/// screenshots or when the app is minimized.
/// {@endtemplate}
enum LogoType {
  /// Hardware barrier found on iPhones from iPhone X to iPhone 16e.
  ///
  /// The notch is a black cutout at the top center of the screen that
  /// houses the front camera and sensors. Logos placed behind the notch
  /// area will be hidden from normal view but visible in screenshots
  /// and when the app is minimized.
  notch,

  /// Hardware barrier found on iPhones from iPhone 14 Pro onwards.
  ///
  /// The Dynamic Island is a pill-shaped interactive area at the top
  /// center of the screen. It's smaller than the notch and has rounded
  /// corners. Logos placed behind this area follow the same visibility
  /// rules as notch logos but are automatically clipped to rounded corners.
  dynamicIsland,
}

/// {@template hidden_logo.DeviceModel}
/// Enumeration of all iPhone models supported by the hidden_logo package.
///
/// This enum contains all iPhone models from iPhone X onwards that have
/// either a notch or Dynamic Island hardware barrier where logos can be
/// positioned. Each model has specific size constraints and positioning
/// requirements for optimal logo placement.
///
/// The supported models are categorized into two groups:
/// - **Notch devices**: iPhone X through iPhone 16e
/// - **Dynamic Island devices**: iPhone 14 Pro series through iPhone 17 series
///
/// See [LogoType] for the hardware barrier types.
/// {@endtemplate}
enum DeviceModel {
  /// iPhone X
  iPhoneX,

  /// iPhone XR
  iPhoneXr,

  /// iPhone XS
  iPhoneXs,

  /// iPhone XS Max
  iPhoneXsMax,

  /// iPhone 11
  iPhone11,

  /// iPhone 11 Pro
  iPhone11Pro,

  /// iPhone 11 Pro Max
  iPhone11ProMax,

  /// iPhone 12
  iPhone12,

  /// iPhone 12 Mini
  iPhone12Mini,

  /// iPhone 12 Pro
  iPhone12Pro,

  /// iPhone 12 Pro Max
  iPhone12ProMax,

  /// iPhone 13
  iPhone13,

  /// iPhone 13 Mini
  iPhone13Mini,

  /// iPhone 13 Pro
  iPhone13Pro,

  /// iPhone 13 Pro Max
  iPhone13ProMax,

  /// iPhone 14
  iPhone14,

  /// iPhone 14 Plus
  iPhone14Plus,

  /// iPhone 14 Pro
  iPhone14Pro,

  /// iPhone 14 Pro Max
  iPhone14ProMax,

  /// iPhone 15
  iPhone15,

  /// iPhone 15 Plus
  iPhone15Plus,

  /// iPhone 15 Pro
  iPhone15Pro,

  /// iPhone 15 Pro Max
  iPhone15ProMax,

  /// iPhone 16
  iPhone16,

  /// iPhone 16 Plus
  iPhone16Plus,

  /// iPhone 16 Pro
  iPhone16Pro,

  /// iPhone 16 Pro Max
  iPhone16ProMax,

  /// iPhone 16e
  iPhone16e,

  /// iPhone 17
  iPhone17,

  /// iPhone Air
  iPhoneAir,

  /// iPhone 17 Pro
  iPhone17Pro,

  /// iPhone 17 Pro Max
  iPhone17ProMax,
}

/// {@template hidden_logo.HiddenLogoParser}
/// Class that parses device information and provides information on how to
/// display child widget for HiddenLogo for current device.
/// {@endtemplate}
class HiddenLogoParser {
  /// Centralized mapping of device codes to iPhone models
  static const Map<String, DeviceModel> _deviceCodeMap = {
    '10,6': DeviceModel.iPhoneX,
    '11,2': DeviceModel.iPhoneXs,
    '11,4': DeviceModel.iPhoneXsMax,
    '11,6': DeviceModel.iPhoneXsMax,
    '11,8': DeviceModel.iPhoneXr,
    '12,1': DeviceModel.iPhone11,
    '12,3': DeviceModel.iPhone11Pro,
    '12,5': DeviceModel.iPhone11ProMax,
    '13,1': DeviceModel.iPhone12Mini,
    '13,2': DeviceModel.iPhone12,
    '13,3': DeviceModel.iPhone12Pro,
    '13,4': DeviceModel.iPhone12ProMax,
    '14,2': DeviceModel.iPhone13Pro,
    '14,3': DeviceModel.iPhone13ProMax,
    '14,4': DeviceModel.iPhone13Mini,
    '14,5': DeviceModel.iPhone13,
    '14,7': DeviceModel.iPhone14,
    '14,8': DeviceModel.iPhone14Plus,
    '15,2': DeviceModel.iPhone14Pro,
    '15,3': DeviceModel.iPhone14ProMax,
    '15,4': DeviceModel.iPhone15,
    '15,5': DeviceModel.iPhone15Plus,
    '16,1': DeviceModel.iPhone15Pro,
    '16,2': DeviceModel.iPhone15ProMax,
    '17,3': DeviceModel.iPhone16,
    '17,4': DeviceModel.iPhone16Plus,
    '17,1': DeviceModel.iPhone16Pro,
    '17,2': DeviceModel.iPhone16ProMax,
    '17,5': DeviceModel.iPhone16e,
    '18,1': DeviceModel.iPhone17Pro,
    '18,2': DeviceModel.iPhone17ProMax,
    '18,3': DeviceModel.iPhone17,
    '18,4': DeviceModel.iPhoneAir,
  };

  /// Returns the device code string for a given iPhone model.
  ///
  /// This method is primarily used for testing purposes to convert from
  /// a [DeviceModel] enum value back to its corresponding device code string.
  ///
  /// For example:
  /// ```dart
  /// final code = HiddenLogoParser.getDeviceCode(DeviceModel.iPhoneX);
  /// print(code); // "10,6"
  /// ```
  ///
  /// Returns `null` if the iPhone model is not found in the mapping.
  ///
  /// See also:
  /// * [currentIPhone] for the reverse operation (code to model)
  static String? getDeviceCode(DeviceModel iPhone) {
    try {
      return _deviceCodeMap.entries
          .firstWhere((entry) => entry.value == iPhone)
          .key;
    } catch (_) {
      return null;
    }
  }
  /// {@macro hidden_logo.HiddenLogoParser}
  HiddenLogoParser({
    BaseDeviceInfo? deviceInfo,
  }) {
    if (deviceInfo != null) {
      _deviceInfo = deviceInfo;
      _deviceInfoInitializationCompleter.complete();
    }
  }

  /// Information about current device provided by DeviceInfoPlugin
  late final BaseDeviceInfo _deviceInfo;
  final _deviceInfoInitializationCompleter = Completer<void>();

  /// Returns true if _deviceInfo property is initialized
  bool get isDeviceInfoSet => _deviceInfoInitializationCompleter.isCompleted;

  set deviceInfo(BaseDeviceInfo value) {
    if (_deviceInfoInitializationCompleter.isCompleted) {
      throw StateError(
          'HiddenLogoParser\'s _deviceInfo property is already initialized, set it only once!');
    }
    _deviceInfo = value;
    _deviceInfoInitializationCompleter.complete();
  }

  /// Whether the current device is a supported iPhone model.
  ///
  /// Returns `true` if the current device is one of the supported iPhone models
  /// that have either a notch or Dynamic Island. Returns `false` for all other
  /// devices including iPads, non-Apple devices, or unsupported iPhone models.
  ///
  /// This is a convenience getter that checks if [currentIPhone] is not null.
  bool get isTargetIPhone => currentIPhone != null;

  /// The hardware barrier type for the current iPhone.
  ///
  /// Returns [LogoType.notch] for iPhone models from iPhone X through iPhone 16e,
  /// and [LogoType.dynamicIsland] for iPhone 14 Pro series through iPhone 17 series.
  ///
  /// **Important**: This getter assumes the device is a target iPhone. It will
  /// throw an assertion error if called on a non-target device. Always check
  /// [isTargetIPhone] first.
  ///
  /// Example:
  /// ```dart
  /// if (parser.isTargetIPhone) {
  ///   final logoType = parser.iPhonesLogoType;
  ///   if (logoType == LogoType.dynamicIsland) {
  ///     // Handle Dynamic Island
  ///   }
  /// }
  /// ```
  LogoType get iPhonesLogoType {
    assert(isTargetIPhone);
    switch (currentIPhone) {
      case DeviceModel.iPhone14Pro:
      case DeviceModel.iPhone14ProMax:
      case DeviceModel.iPhone15:
      case DeviceModel.iPhone15Plus:
      case DeviceModel.iPhone15Pro:
      case DeviceModel.iPhone15ProMax:
      case DeviceModel.iPhone16:
      case DeviceModel.iPhone16Plus:
      case DeviceModel.iPhone16Pro:
      case DeviceModel.iPhone16ProMax:
      case DeviceModel.iPhone17:
      case DeviceModel.iPhoneAir:
      case DeviceModel.iPhone17Pro:
      case DeviceModel.iPhone17ProMax:
        return LogoType.dynamicIsland;
      default:
        return LogoType.notch;
    }
  }

  /// The specific iPhone model of the current device.
  ///
  /// Parses the device information to determine which iPhone model is currently
  /// running the app. Returns `null` for non-iPhone devices or unsupported models.
  ///
  /// The detection is based on the device's machine identifier (e.g., "iPhone10,6"
  /// for iPhone X). This method safely handles edge cases like non-iPhone devices
  /// or corrupted device information.
  ///
  /// Example usage:
  /// ```dart
  /// final model = parser.currentIPhone;
  /// if (model == DeviceModel.iPhoneX) {
  ///   // Handle iPhone X specific logic
  /// }
  /// ```
  ///
  /// **Note**: The device info must be initialized before calling this getter.
  /// Use [isDeviceInfoSet] to check initialization status.
  DeviceModel? get currentIPhone {
    if (!_deviceInfoInitializationCompleter.isCompleted) {
      throw StateError(
          'HiddenLogoParser\'s _deviceInfo property is not initialized, set it first!');
    }
    late final String deviceName;
    late final String deviceCode;
    try {
      deviceName = _deviceInfo.data['utsname']['machine'];
      if (!deviceName.startsWith('iPhone')) return null;
      deviceCode = deviceName.substring('iPhone'.length);
    } on Object {
      return null;
    }
    if (deviceName.isEmpty || deviceCode.isEmpty) return null;
    return _deviceCodeMap[deviceCode];
  }

  /// Whether the current device supports logo placement.
  ///
  /// Returns `true` only if the device meets all requirements for logo display:
  /// - Must be running on iOS platform
  /// - Must be a supported iPhone model with notch or Dynamic Island
  ///
  /// This combines platform detection with iPhone model validation to provide
  /// a single check for logo rendering eligibility.
  ///
  /// Example:
  /// ```dart
  /// if (parser.isTargetDevice) {
  ///   // Safe to display logo
  ///   final constraints = parser.logoConstraints;
  /// }
  /// ```
  bool get isTargetDevice {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS && isTargetIPhone) return true;
    return false;
  }

  /// The size constraints for logo placement on the current iPhone.
  ///
  /// Returns precise [BoxConstraints] that define the maximum dimensions
  /// available for logo rendering behind the hardware barrier. These constraints
  /// are carefully measured for each iPhone model to ensure logos fit perfectly
  /// within the available space.
  ///
  /// Different iPhone models have different constraint values:
  /// - **iPhone X series**: 30.0×209.0 or 33.0×230.0 depending on model
  /// - **iPhone 12 series**: 32.2×211.0 to 37.4×175.0 depending on model
  /// - **iPhone 13-16 series**: 33.0×162.0 for standard models
  /// - **Dynamic Island models**: 36.7×122.0 for all Dynamic Island devices
  ///
  /// Returns zero constraints (0×0) for unsupported devices, which should
  /// be validated before use.
  ///
  /// Example:
  /// ```dart
  /// final constraints = parser.logoConstraints;
  /// final maxWidth = constraints.maxWidth;  // e.g., 122.0 for iPhone 15 Pro
  /// final maxHeight = constraints.maxHeight; // e.g., 36.7 for iPhone 15 Pro
  /// ```
  BoxConstraints get logoConstraints {
    switch (currentIPhone) {
      case DeviceModel.iPhoneX:
      case DeviceModel.iPhoneXs:
      case DeviceModel.iPhoneXsMax:
      case DeviceModel.iPhone11Pro:
      case DeviceModel.iPhone11ProMax:
        return const BoxConstraints(maxHeight: 30.0, maxWidth: 209.0);

      case DeviceModel.iPhone13Pro:
      case DeviceModel.iPhone13ProMax:
      case DeviceModel.iPhone14:
      case DeviceModel.iPhone14Plus:
      case DeviceModel.iPhone13:
      case DeviceModel.iPhone16e:
        return const BoxConstraints(maxHeight: 33.0, maxWidth: 162.0);

      case DeviceModel.iPhoneXr:
      case DeviceModel.iPhone11:
        return const BoxConstraints(maxHeight: 33.0, maxWidth: 230.0);

      case DeviceModel.iPhone12:
      case DeviceModel.iPhone12Pro:
      case DeviceModel.iPhone12ProMax:
        return const BoxConstraints(maxHeight: 32.2, maxWidth: 211.0);

      case DeviceModel.iPhone12Mini:
        return const BoxConstraints(maxHeight: 34.7, maxWidth: 226.0);

      case DeviceModel.iPhone13Mini:
        return const BoxConstraints(maxHeight: 37.4, maxWidth: 175.0);

      case DeviceModel.iPhone14Pro:
      case DeviceModel.iPhone14ProMax:
      case DeviceModel.iPhone15:
      case DeviceModel.iPhone15Plus:
      case DeviceModel.iPhone15Pro:
      case DeviceModel.iPhone15ProMax:
      case DeviceModel.iPhone16:
      case DeviceModel.iPhone16Plus:
      case DeviceModel.iPhone17:
      case DeviceModel.iPhoneAir:
      case DeviceModel.iPhone16Pro:
      case DeviceModel.iPhone16ProMax:
      case DeviceModel.iPhone17Pro:
      case DeviceModel.iPhone17ProMax:
        return const BoxConstraints(maxHeight: 36.7, maxWidth: 122.0);
      case null:
        return const BoxConstraints(maxHeight: 0, maxWidth: 0);
    }
  }

  /// The top margin for Dynamic Island logo positioning.
  ///
  /// Returns the vertical offset (in logical pixels) from the top of the screen
  /// where the Dynamic Island logo should be positioned. This ensures proper
  /// alignment with the Dynamic Island hardware barrier.
  ///
  /// Margin values by device generation:
  /// - **iPhone 14 Pro/15 series**: 11.3 pixels
  /// - **iPhone 16 Pro/17 series**: 14.0 pixels
  /// - **iPhone Air**: 20.0 pixels
  /// - **All notch devices**: 0.0 pixels (no margin needed)
  ///
  /// The margin accounts for differences in Dynamic Island positioning
  /// across iPhone generations.
  ///
  /// Example:
  /// ```dart
  /// final margin = parser.dynamicIslandTopMargin;
  /// // Use margin as top padding for Dynamic Island logos
  /// ```
  double get dynamicIslandTopMargin {
    switch (currentIPhone) {
      case DeviceModel.iPhone14Pro:
      case DeviceModel.iPhone14ProMax:
      case DeviceModel.iPhone15:
      case DeviceModel.iPhone15Pro:
      case DeviceModel.iPhone15Plus:
      case DeviceModel.iPhone15ProMax:
      case DeviceModel.iPhone16:
      case DeviceModel.iPhone16Plus:
        return 11.3;
      case DeviceModel.iPhone16Pro:
      case DeviceModel.iPhone16ProMax:
      case DeviceModel.iPhone17:
      case DeviceModel.iPhone17Pro:
      case DeviceModel.iPhone17ProMax:
        return 14.0;
      case DeviceModel.iPhoneAir:
        return 20.0;
      default:
        return 0.0;
    }
  }
}
