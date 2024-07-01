import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';

/// Possible locations of the brand logo hidden behind
/// iPhone's hardware barriers
enum LogoType { notch, dynamicIsland }

///  Target iPhones: the ones with notch or dynamic island only
enum _DeviceModel {
  iPhoneX,
  iPhoneXr,
  iPhoneXs,
  iPhoneXsMax,
  iPhone11,
  iPhone11Pro,
  iPhone11ProMax,
  iPhone12,
  iPhone12Mini,
  iPhone12Pro,
  iPhone12ProMax,
  iPhone13,
  iPhone13Mini,
  iPhone13Pro,
  iPhone13ProMax,
  iPhone14,
  iPhone14Plus,
  iPhone14Pro,
  iPhone14ProMax,
  iPhone15,
  iPhone15Plus,
  iPhone15Pro,
  iPhone15ProMax,
}

class IosHiddenLogoUtil {
  const IosHiddenLogoUtil({required this.deviceInfo});

  final BaseDeviceInfo deviceInfo;

  String get _deviceName => deviceInfo.data['utsname']['machine'];

  bool get _isTargetIPhone => _currentIPhone != null;

  LogoType get logoType {
    assert(_isTargetIPhone);
    switch (_currentIPhone) {
      case _DeviceModel.iPhone14Pro:
      case _DeviceModel.iPhone14ProMax:
      case _DeviceModel.iPhone15:
      case _DeviceModel.iPhone15Plus:
      case _DeviceModel.iPhone15Pro:
      case _DeviceModel.iPhone15ProMax:
        return LogoType.dynamicIsland;
      default:
        return LogoType.notch;
    }
  }

  _DeviceModel? get _currentIPhone {
    final deviceName = _deviceName;
    if (deviceName.isEmpty) return null;
    final deviceCode = deviceName.substring('iPhone'.length);
    return switch (deviceCode) {
      '10,6' => _DeviceModel.iPhoneX,
      '11,2' => _DeviceModel.iPhoneXs,
      '11,4' || '11,6' => _DeviceModel.iPhoneXsMax,
      '11,8' => _DeviceModel.iPhoneXr,
      '12,1' => _DeviceModel.iPhone11,
      '12,3' => _DeviceModel.iPhone11Pro,
      '12,5' => _DeviceModel.iPhone11ProMax,
      '13,1' => _DeviceModel.iPhone12Mini,
      '13,2' => _DeviceModel.iPhone12,
      '13,3' => _DeviceModel.iPhone12Pro,
      '13,4' => _DeviceModel.iPhone12ProMax,
      '14,2' => _DeviceModel.iPhone13Pro,
      '14,3' => _DeviceModel.iPhone13ProMax,
      '14,4' => _DeviceModel.iPhone13Mini,
      '14,5' => _DeviceModel.iPhone13,
      '14,7' => _DeviceModel.iPhone14,
      '14,8' => _DeviceModel.iPhone14Plus,
      '15,2' => _DeviceModel.iPhone14Pro,
      '15,3' => _DeviceModel.iPhone14ProMax,
      '15,4' => _DeviceModel.iPhone15,
      '15,5' => _DeviceModel.iPhone15Plus,
      '16,1' => _DeviceModel.iPhone15Pro,
      '16,2' => _DeviceModel.iPhone15ProMax,
      _ => null,
    };
  }

  /// Returns true if device is an iPhone and it has notch or
  /// Dynamic Island on top
  bool get isTargetDevice {
    if (Platform.isIOS && _isTargetIPhone) return true;
    return false;
  }

  /// Returns notch size for old iPhones and Dynamic Island size for new ones
  BoxConstraints get logoConstraints {
    switch (_currentIPhone) {
      case _DeviceModel.iPhoneX:
      case _DeviceModel.iPhoneXs:
      case _DeviceModel.iPhoneXsMax:
      case _DeviceModel.iPhone11Pro:
      case _DeviceModel.iPhone11ProMax:
        return const BoxConstraints(maxHeight: 30.0, maxWidth: 209.0);

      case _DeviceModel.iPhone13Pro:
      case _DeviceModel.iPhone13ProMax:
      case _DeviceModel.iPhone14:
      case _DeviceModel.iPhone14Plus:
      case _DeviceModel.iPhone13:
        return const BoxConstraints(maxHeight: 33.0, maxWidth: 162.0);

      case _DeviceModel.iPhoneXr:
      case _DeviceModel.iPhone11:
        return const BoxConstraints(maxHeight: 33.0, maxWidth: 230.0);

      case _DeviceModel.iPhone12:
      case _DeviceModel.iPhone12Pro:
      case _DeviceModel.iPhone12ProMax:
        return const BoxConstraints(maxHeight: 32.2, maxWidth: 211.0);

      case _DeviceModel.iPhone12Mini:
        return const BoxConstraints(maxHeight: 34.7, maxWidth: 226.0);

      case _DeviceModel.iPhone13Mini:
        return const BoxConstraints(maxHeight: 37.4, maxWidth: 175.0);

      case _DeviceModel.iPhone14Pro:
      case _DeviceModel.iPhone14ProMax:
      case _DeviceModel.iPhone15:
      case _DeviceModel.iPhone15Plus:
      case _DeviceModel.iPhone15Pro:
      case _DeviceModel.iPhone15ProMax:
        return const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0);

      case null:
        return const BoxConstraints(maxHeight: 0, maxWidth: 0);
    }
  }

  /// Returns 0 for non dynamic island devices
  double get dynamicIslandTopMargin {
    switch (_currentIPhone) {
      case _DeviceModel.iPhone14Pro:
      case _DeviceModel.iPhone14ProMax:
      case _DeviceModel.iPhone15:
      case _DeviceModel.iPhone15Pro:
      case _DeviceModel.iPhone15Plus:
      case _DeviceModel.iPhone15ProMax:
        return 11.4;
      default:
        return 0.0;
    }
  }
}
