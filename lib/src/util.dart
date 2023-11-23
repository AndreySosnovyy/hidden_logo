// ignore_for_file: constant_identifier_names

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

/// Possible locations of the brand logo hidden behind
/// iPhone's hardware barriers
enum LogoType { notch, dynamicIsland }

///  Target iPhones: the ones with notch or dynamic island only
enum _IPhone {
  x,
  xr,
  xs,
  xsMax,
  _11,
  _11Pro,
  _11ProMax,
  _12,
  _12Mini,
  _12Pro,
  _12ProMax,
  _13,
  _13Mini,
  _13Pro,
  _13ProMax,
  _14,
  _14Plus,
  _14Pro,
  _14ProMax,
  _15,
  _15Plus,
  _15Pro,
  _15ProMax,
}

class IosHiddenLogoUtil {
  IosHiddenLogoUtil({required this.deviceInfo});

  final BaseDeviceInfo deviceInfo;

  String get _deviceName => deviceInfo.data['name'] ?? '';

  bool get _isTargetIPhone => _currentIPhone != null;

  LogoType get logoType {
    assert(_isTargetIPhone);
    return switch (_currentIPhone) {
      _IPhone.x => LogoType.notch,
      _IPhone.xr => LogoType.notch,
      _IPhone.xs => LogoType.notch,
      _IPhone.xsMax => LogoType.notch,
      _IPhone._11 => LogoType.notch,
      _IPhone._11Pro => LogoType.notch,
      _IPhone._11ProMax => LogoType.notch,
      _IPhone._12 => LogoType.notch,
      _IPhone._12Mini => LogoType.notch,
      _IPhone._12Pro => LogoType.notch,
      _IPhone._12ProMax => LogoType.notch,
      _IPhone._13 => LogoType.notch,
      _IPhone._13Mini => LogoType.notch,
      _IPhone._13Pro => LogoType.notch,
      _IPhone._13ProMax => LogoType.notch,
      _IPhone._14 => LogoType.notch,
      _IPhone._14Plus => LogoType.notch,
      _IPhone._14Pro => LogoType.dynamicIsland,
      _IPhone._14ProMax => LogoType.dynamicIsland,
      _IPhone._15 => LogoType.dynamicIsland,
      _IPhone._15Plus => LogoType.dynamicIsland,
      _IPhone._15Pro => LogoType.dynamicIsland,
      _IPhone._15ProMax => LogoType.dynamicIsland,
      _ => LogoType.notch,
    };
  }

  _IPhone? get _currentIPhone {
    final deviceName = _deviceName;
    if (deviceName.isEmpty) return null;
    if (!deviceName.contains('iPhone ')) return null;
    return switch (_deviceName.toLowerCase().substring('iPhone '.length)) {
      'x' => _IPhone.x,
      'xʀ' || 'xr' => _IPhone.xr,
      'xs' => _IPhone.xs,
      'xs max' => _IPhone.xsMax,
      '11' => _IPhone._11,
      '11 pro' => _IPhone._11Pro,
      '11 pro max' => _IPhone._11ProMax,
      '12' => _IPhone._12,
      '12 mini' => _IPhone._12Mini,
      '12 pro' => _IPhone._12Pro,
      '12 pro max' => _IPhone._12ProMax,
      '13' => _IPhone._13,
      '13 mini' => _IPhone._13Mini,
      '13 pro' => _IPhone._13Pro,
      '13 pro max' => _IPhone._13ProMax,
      '14' => _IPhone._14,
      '14 plus' => _IPhone._14Plus,
      '14 pro' => _IPhone._14Pro,
      '14 pro max' => _IPhone._14ProMax,
      '15' => _IPhone._15,
      '15 plus' => _IPhone._15Plus,
      '15 pro' => _IPhone._15Pro,
      '15 pro max' => _IPhone._15ProMax,
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
    return switch (_currentIPhone) {
      _IPhone.x => const BoxConstraints(maxHeight: 30.0, maxWidth: 209.0), //
      _IPhone.xr => const BoxConstraints(maxHeight: 33.0, maxWidth: 230.0), //
      _IPhone.xs => const BoxConstraints(maxHeight: 30.0, maxWidth: 209.0), //
      _IPhone.xsMax => const BoxConstraints(maxHeight: 30.0, maxWidth: 209.0), //
      _IPhone._11 => const BoxConstraints(maxHeight: 33.0, maxWidth: 230.0), //
      _IPhone._11Pro => const BoxConstraints(maxHeight: 30.0, maxWidth: 209.0), //
      _IPhone._11ProMax => const BoxConstraints(maxHeight: 30.0, maxWidth: 209.0), //
      _IPhone._12 => const BoxConstraints(maxHeight: 32.2, maxWidth: 211.0), //
      _IPhone._12Mini => const BoxConstraints(maxHeight: 34.7, maxWidth: 226.0), //
      _IPhone._12Pro => const BoxConstraints(maxHeight: 32.2, maxWidth: 211.0), //
      _IPhone._12ProMax => const BoxConstraints(maxHeight: 32.2, maxWidth: 211.0), //
      _IPhone._13 => const BoxConstraints(maxHeight: 33.0, maxWidth: 162.0), //
      _IPhone._13Mini => const BoxConstraints(maxHeight: 37.4, maxWidth: 175.0), //
      _IPhone._13Pro => const BoxConstraints(maxHeight: 33.0, maxWidth: 162.0), //
      _IPhone._13ProMax => const BoxConstraints(maxHeight: 33.0, maxWidth: 162.0), //
      _IPhone._14 => const BoxConstraints(maxHeight: 33.0, maxWidth: 162.0), //
      _IPhone._14Plus => const BoxConstraints(maxHeight: 33.0, maxWidth: 162.0), //
      _IPhone._14Pro => const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0), //
      _IPhone._14ProMax => const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0), //
      _IPhone._15 => const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0),
      _IPhone._15Plus => const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0),
      _IPhone._15Pro => const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0),
      _IPhone._15ProMax => const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0),
      _ => const BoxConstraints(maxHeight: 36.6, maxWidth: 125.0),
    };
  }

  /// Returns 0 for non dynamic island devices
  double get dynamicIslandTopMargin => switch (_currentIPhone) {
        _IPhone._14Pro => 11.4, //
        _IPhone._14ProMax => 11.4, //
        _IPhone._15 => 11.4,
        _IPhone._15Pro => 11.4,
        _IPhone._15Plus => 11.4,
        _IPhone._15ProMax => 11.4,
        _ => 0.0,
      };
}
