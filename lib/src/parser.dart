import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Possible locations of the brand logo hidden behind
/// iPhone's hardware barriers
enum LogoType {
  /// Hardware barrier for iPhones from iPhone X to iPhone 16e
  notch,

  /// Hardware barrier for iPhones from iPhone 14 Pro onwards
  dynamicIsland,
}

/// Target iPhones: the ones with notch or dynamic island only
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

  /// Gets device code for a given iPhone model (used primarily for testing)
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

  /// Returns true if current device is one of target iPhones
  bool get isTargetIPhone => currentIPhone != null;

  /// Returns type of current iPhone's hardware barrier or null for non target devices
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

  /// Returns current iPhone model or null for non target device
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

  /// Returns true if device is an iPhone and it has notch or Dynamic Island on top
  bool get isTargetDevice {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS && isTargetIPhone) return true;
    return false;
  }

  /// Returns notch size for old iPhones and Dynamic Island size for new ones
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

  /// Returns 0 for non dynamic island devices
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
