import 'package:hidden_logo/src/parser.dart';

class TestUtils {
  static Map<String, dynamic> buildMockDeviceInfoDataMap(dynamic code) => {
        'utsname': {'machine': code}
      };

  static String iPhoneToCode(DeviceModel iPhone, {bool withPrefix = false}) {
    late final String code;
    switch (iPhone) {
      case DeviceModel.iPhoneX:
        code = '10,6';
        break;
      case DeviceModel.iPhoneXs:
        code = '11,2';
        break;
      case DeviceModel.iPhoneXsMax:
        code = '11,4';
        break;
      case DeviceModel.iPhoneXr:
        code = '11,8';
        break;
      case DeviceModel.iPhone11:
        code = '12,1';
        break;
      case DeviceModel.iPhone11Pro:
        code = '12,3';
        break;
      case DeviceModel.iPhone11ProMax:
        code = '12,5';
        break;
      case DeviceModel.iPhone12Mini:
        code = '13,1';
        break;
      case DeviceModel.iPhone12:
        code = '13,2';
        break;
      case DeviceModel.iPhone12Pro:
        code = '13,3';
        break;
      case DeviceModel.iPhone12ProMax:
        code = '13,4';
        break;
      case DeviceModel.iPhone13Pro:
        code = '14,2';
        break;
      case DeviceModel.iPhone13ProMax:
        code = '14,3';
        break;
      case DeviceModel.iPhone13Mini:
        code = '14,4';
        break;
      case DeviceModel.iPhone13:
        code = '14,5';
        break;
      case DeviceModel.iPhone14:
        code = '14,7';
        break;
      case DeviceModel.iPhone14Plus:
        code = '14,8';
        break;
      case DeviceModel.iPhone14Pro:
        code = '15,2';
        break;
      case DeviceModel.iPhone14ProMax:
        code = '15,3';
        break;
      case DeviceModel.iPhone15:
        code = '15,4';
        break;
      case DeviceModel.iPhone15Plus:
        code = '15,5';
        break;
      case DeviceModel.iPhone15Pro:
        code = '16,1';
        break;
      case DeviceModel.iPhone15ProMax:
        code = '16,2';
        break;
      case DeviceModel.iPhone16:
        code = '17,3';
        break;
      case DeviceModel.iPhone16Plus:
        code = '17,4';
        break;
      case DeviceModel.iPhone16Pro:
        code = '17,1';
        break;
      case DeviceModel.iPhone16ProMax:
        code = '17,2';
        break;
      // Add new cases when new iPhones are released
    }
    return '${withPrefix ? 'iPhone' : ''}$code';
  }

  static final _iPhonesWithNotch = [
    DeviceModel.iPhoneX,
    DeviceModel.iPhoneXs,
    DeviceModel.iPhoneXsMax,
    DeviceModel.iPhoneXr,
    DeviceModel.iPhone11,
    DeviceModel.iPhone11Pro,
    DeviceModel.iPhone11ProMax,
    DeviceModel.iPhone12Mini,
    DeviceModel.iPhone12,
    DeviceModel.iPhone12Pro,
    DeviceModel.iPhone12ProMax,
    DeviceModel.iPhone13Pro,
    DeviceModel.iPhone13ProMax,
    DeviceModel.iPhone13Mini,
    DeviceModel.iPhone13,
    DeviceModel.iPhone14,
    DeviceModel.iPhone14Plus,
  ];

  static final _iPhonesWithDynamicIsland = [
    DeviceModel.iPhone14Pro,
    DeviceModel.iPhone14ProMax,
    DeviceModel.iPhone15,
    DeviceModel.iPhone15Plus,
    DeviceModel.iPhone15Pro,
    DeviceModel.iPhone15ProMax,
    DeviceModel.iPhone16,
    DeviceModel.iPhone16Plus,
    DeviceModel.iPhone16Pro,
    DeviceModel.iPhone16ProMax,
  ];

  static DeviceModel getRandomIPhone({LogoType? logoType}) {
    final List<DeviceModel> listToChooseFrom;
    switch (logoType) {
      case LogoType.notch:
        listToChooseFrom = [..._iPhonesWithNotch];
        break;
      case LogoType.dynamicIsland:
        listToChooseFrom = [..._iPhonesWithDynamicIsland];
        break;
      default:
        listToChooseFrom = [..._iPhonesWithNotch, ..._iPhonesWithDynamicIsland];
    }
    return (listToChooseFrom..shuffle()).first;
  }
}
