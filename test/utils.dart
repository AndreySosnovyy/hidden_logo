import 'package:hidden_logo/src/parser.dart';

class TestUtils {
  /// Returns the machine identifier string for a given iPhone model.
  /// Example: DeviceModel.iPhoneX -> "iPhone10,6"
  static String getMachineIdentifier(DeviceModel iPhone) {
    final code = HiddenLogoParser.getIPhoneMachineIdentifier(iPhone);
    if (code == null) {
      throw ArgumentError('Device code not found for $iPhone');
    }
    return 'iPhone$code';
  }

  /// Returns just the code part without "iPhone" prefix.
  /// Example: DeviceModel.iPhoneX -> "10,6"
  static String iPhoneToCode(DeviceModel iPhone, {bool withPrefix = false}) {
    final code = HiddenLogoParser.getIPhoneMachineIdentifier(iPhone);
    if (code == null) {
      throw ArgumentError('Device code not found for $iPhone');
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
    DeviceModel.iPhone16e,
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
    DeviceModel.iPhone17,
    DeviceModel.iPhoneAir,
    DeviceModel.iPhone17Pro,
    DeviceModel.iPhone17ProMax,
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
