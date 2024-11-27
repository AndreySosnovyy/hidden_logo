import 'package:hidden_logo/src/parser.dart';

class IPhoneParsingUtil {
  static Map<String, dynamic> buildMockDeviceInfoDataMap(dynamic code) => {
        'utsname': {'machine': code}
      };

  static String iPhoneToCode(DeviceModel iPhone) {
    switch (iPhone) {
      case DeviceModel.iPhoneX:
        return '10,6';
      case DeviceModel.iPhoneXs:
        return '11,2';
      case DeviceModel.iPhoneXsMax:
        return '11,4';
      case DeviceModel.iPhoneXr:
        return '11,8';
      case DeviceModel.iPhone11:
        return '12,1';
      case DeviceModel.iPhone11Pro:
        return '12,3';
      case DeviceModel.iPhone11ProMax:
        return '12,5';
      case DeviceModel.iPhone12Mini:
        return '13,1';
      case DeviceModel.iPhone12:
        return '13,2';
      case DeviceModel.iPhone12Pro:
        return '13,3';
      case DeviceModel.iPhone12ProMax:
        return '13,4';
      case DeviceModel.iPhone13Pro:
        return '14,2';
      case DeviceModel.iPhone13ProMax:
        return '14,3';
      case DeviceModel.iPhone13Mini:
        return '14,4';
      case DeviceModel.iPhone13:
        return '14,5';
      case DeviceModel.iPhone14:
        return '14,7';
      case DeviceModel.iPhone14Plus:
        return '14,8';
      case DeviceModel.iPhone14Pro:
        return '15,2';
      case DeviceModel.iPhone14ProMax:
        return '15,3';
      case DeviceModel.iPhone15:
        return '15,4';
      case DeviceModel.iPhone15Plus:
        return '15,5';
      case DeviceModel.iPhone15Pro:
        return '16,1';
      case DeviceModel.iPhone15ProMax:
        return '16,2';
      case DeviceModel.iPhone16:
        return '17,3';
      case DeviceModel.iPhone16Plus:
        return '17,4';
      case DeviceModel.iPhone16Pro:
        return '17,1';
      case DeviceModel.iPhone16ProMax:
        return '17,2';
      // Add new cases when new iPhones are released
    }
  }
}
