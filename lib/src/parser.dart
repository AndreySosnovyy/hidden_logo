import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';

/// Possible locations of the brand logo hidden behind
/// iPhone's hardware barriers
enum LogoType {
  /// Hardware barrier for iPhones from iPhone X to iPhone 14 Plus
  notch,

  /// Hardware barrier for iPhones from iPhone 14 Pro
  dynamicIsland,
}

///  Target iPhones: the ones with notch or dynamic island only
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
}

/// {@template hidden_logo.HiddenLogoParser}
/// Class that parses device information and provides information on how to
/// display child widget for HiddenLogo for current device.
/// {@endtemplate}
class HiddenLogoParser {
  /// {@macro hidden_logo.HiddenLogoParser}
  const HiddenLogoParser({required this.deviceInfo});

  /// Information about current device provided by DeviceInfoPlugin
  final BaseDeviceInfo deviceInfo;

  /// Returns true if current device is one of target iPhones
  bool get isTargetIPhone => currentIPhone != null;

  /// Returns type of current iPhone's hardware barrier
  LogoType get logoType {
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
        return LogoType.dynamicIsland;
      default:
        return LogoType.notch;
    }
  }

  /// Returns current iPhone model or null for non target device
  DeviceModel? get currentIPhone {
    final deviceName = deviceInfo.data['utsname']['machine'];
    if (deviceName.isEmpty) return null;
    final deviceCode = deviceName.substring('iPhone'.length);
    switch (deviceCode) {
      case '10,6':
        return DeviceModel.iPhoneX;
      case '11,2':
        return DeviceModel.iPhoneXs;
      case '11,4':
        return DeviceModel.iPhoneXsMax;
      case '11,6':
        return DeviceModel.iPhoneXsMax;
      case '11,8':
        return DeviceModel.iPhoneXr;
      case '12,1':
        return DeviceModel.iPhone11;
      case '12,3':
        return DeviceModel.iPhone11Pro;
      case '12,5':
        return DeviceModel.iPhone11ProMax;
      case '13,1':
        return DeviceModel.iPhone12Mini;
      case '13,2':
        return DeviceModel.iPhone12;
      case '13,3':
        return DeviceModel.iPhone12Pro;
      case '13,4':
        return DeviceModel.iPhone12ProMax;
      case '14,2':
        return DeviceModel.iPhone13Pro;
      case '14,3':
        return DeviceModel.iPhone13ProMax;
      case '14,4':
        return DeviceModel.iPhone13Mini;
      case '14,5':
        return DeviceModel.iPhone13;
      case '14,7':
        return DeviceModel.iPhone14;
      case '14,8':
        return DeviceModel.iPhone14Plus;
      case '15,2':
        return DeviceModel.iPhone14Pro;
      case '15,3':
        return DeviceModel.iPhone14ProMax;
      case '15,4':
        return DeviceModel.iPhone15;
      case '15,5':
        return DeviceModel.iPhone15Plus;
      case '16,1':
        return DeviceModel.iPhone15Pro;
      case '16,2':
        return DeviceModel.iPhone15ProMax;
      case '17,3':
        return DeviceModel.iPhone16;
      case '17,4':
        return DeviceModel.iPhone16Plus;
      case '17,1':
        return DeviceModel.iPhone16Pro;
      case '17,2':
        return DeviceModel.iPhone16ProMax;
      default:
        return null;
    }
  }

  /// Returns true if device is an iPhone and it has notch or
  /// Dynamic Island on top
  bool get isTargetDevice {
    if (Platform.isIOS && isTargetIPhone) return true;
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
        return const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0);
      case DeviceModel.iPhone16Pro:
      case DeviceModel.iPhone16ProMax:
        return const BoxConstraints(maxHeight: 37.2, maxWidth: 125.6);
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
        return 11.4;
      case DeviceModel.iPhone16Pro:
      case DeviceModel.iPhone16ProMax:
        return 13.8;
      default:
        return 0.0;
    }
  }
}
