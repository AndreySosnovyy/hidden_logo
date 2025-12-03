import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';

void main() {
  group('machineIdentifier property initialization tests', () {
    test(
      'Parser should throw StateError if machineIdentifier is not set but currentIPhone was called',
      () {
        final parser = HiddenLogoParser();
        expect(() => parser.currentIPhone, throwsA(isA<StateError>()));
      },
    );

    test(
      'Parser should work if machineIdentifier is provided via constructor',
      () {
        final parser = HiddenLogoParser(machineIdentifier: 'iPhone15,2');
        expect(parser.currentIPhone, DeviceModel.iPhone14Pro);
      },
    );

    test('Parser should work if machineIdentifier is set via setter', () {
      final parser = HiddenLogoParser();
      parser.machineIdentifier = 'iPhone15,2';
      expect(parser.currentIPhone, DeviceModel.iPhone14Pro);
    });

    test('Parser should throw StateError if machineIdentifier is '
        'set via constructor and then set via setter', () {
      final parser = HiddenLogoParser(machineIdentifier: 'iPhone15,2');
      expect(
        () => parser.machineIdentifier = 'iPhone10,6',
        throwsA(isA<StateError>()),
      );
    });

    test('Parser should throw StateError if machineIdentifier is '
        'set via setter 2 times', () {
      final parser = HiddenLogoParser();
      parser.machineIdentifier = 'iPhone15,2';
      expect(
        () => parser.machineIdentifier = 'iPhone10,6',
        throwsA(isA<StateError>()),
      );
    });

    test('isInitialized should return true when machineIdentifier is set', () {
      final parser = HiddenLogoParser();
      parser.machineIdentifier = 'iPhone15,2';
      expect(parser.isInitialized, true);
    });

    test(
      'isInitialized should return false when machineIdentifier is not set',
      () {
        final parser = HiddenLogoParser();
        expect(parser.isInitialized, false);
      },
    );

    test(
      'Parser should work with null machineIdentifier when using initialized factory',
      () {
        final parser = HiddenLogoParser.initialized(machineIdentifier: null);
        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      },
    );

    test('Parser with null in constructor should NOT be initialized', () {
      final parser = HiddenLogoParser(machineIdentifier: null);
      expect(parser.isInitialized, false);
    });
  });
}
