import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/src/parser.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockBaseDeviceInfo extends Mock implements BaseDeviceInfo {}

void main() {
  group('Platform Detection Edge Cases', () {
    group('Non-iOS Platform Behavior', () {
      testWidgets('Should not display logo on Android platform', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        // Even with valid iPhone data, should not be target device on Android
        expect(parser.isTargetDevice, isFalse);
        expect(parser.currentIPhone, isNotNull); // Parser still works
        expect(parser.isTargetIPhone, isTrue); // Device detection works

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('Should not display logo on web platform', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux; // Simulate web

        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        expect(parser.isTargetDevice, isFalse);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('Should not display logo on desktop platforms', (tester) async {
        final platforms = [
          TargetPlatform.windows,
          TargetPlatform.macOS,
          TargetPlatform.linux,
        ];

        for (final platform in platforms) {
          debugDefaultTargetPlatformOverride = platform;

          final mockDeviceInfo = MockBaseDeviceInfo();
          when(() => mockDeviceInfo.data).thenReturn(
              TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
          final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

          expect(parser.isTargetDevice, isFalse,
              reason: 'Should not be target device on $platform');
        }

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('Should only work on iOS platform', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        expect(parser.isTargetDevice, isTrue);
        expect(parser.isTargetIPhone, isTrue);

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('iOS Simulator vs Real Device', () {
      test('Should handle simulator device codes', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        // Simulator typically returns 'x86_64' or 'arm64' instead of iPhone codes
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'x86_64'}
        });
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should handle arm64 simulator', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'arm64'}
        });
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        expect(parser.currentIPhone, isNull);
        expect(parser.isTargetIPhone, isFalse);
      });

      test('Should work with real device iPhone codes', () {
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn({
          'utsname': {'machine': 'iPhone15,2'}
        });
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        expect(parser.currentIPhone, isNotNull);
        expect(parser.isTargetIPhone, isTrue);
      });
    });

    group('Unknown Platform Handling', () {
      test('Should handle null target platform gracefully', () {
        // This tests the case where TargetPlatform might be extended in future
        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        // Should still parse iPhone correctly regardless of platform detection issues
        expect(parser.currentIPhone, isNotNull);
        expect(parser.isTargetIPhone, isTrue);
      });
    });

    group('Platform Override Scenarios', () {
      testWidgets('Should respect platform override in tests', (tester) async {
        // Start with non-iOS
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final mockDeviceInfo = MockBaseDeviceInfo();
        when(() => mockDeviceInfo.data).thenReturn(
            TestUtils.buildMockDeviceInfoDataMap('iPhone15,2'));
        final parser = HiddenLogoParser(deviceInfo: mockDeviceInfo);

        expect(parser.isTargetDevice, isFalse);

        // Override to iOS
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        expect(parser.isTargetDevice, isTrue);

        // Clean up
        debugDefaultTargetPlatformOverride = null;
      });
    });
  });
}