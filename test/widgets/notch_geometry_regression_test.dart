import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/device_info_service.dart';

void main() {
  // Independent measurements from Apple's CoreSimulator framebuffer PDFs:
  // 12/12 Pro: C97EA923-E28B-451F-9811-98D8F88F27C2, bottom 95.997 px;
  // 12 Pro Max: FD5FF41B-8FF7-4AFC-8F61-A8EC5F8E72FA, bottom 96.001 px;
  // 12 mini: B189ED7C-CF48-4E4D-B70B-1BD1F1C1C007, bottom 103.052 px.
  // The exposed rows below are in each mask's standard render pixel grid.
  // These fixtures require neither Apple tools nor the PDFs when running tests.
  const fixtures = [
    (
      identifier: 'iPhone13,2',
      standardRenderSize: Size(1170, 2532),
      displaySize: Size(1170, 2532),
      zoomRenderSize: Size(1125, 2436),
      exposedRow: 96,
    ),
    (
      identifier: 'iPhone13,3',
      standardRenderSize: Size(1170, 2532),
      displaySize: Size(1170, 2532),
      zoomRenderSize: Size(1125, 2436),
      exposedRow: 96,
    ),
    (
      identifier: 'iPhone13,4',
      standardRenderSize: Size(1284, 2778),
      displaySize: Size(1284, 2778),
      zoomRenderSize: Size(1125, 2436),
      exposedRow: 96,
    ),
    (
      identifier: 'iPhone13,1',
      standardRenderSize: Size(1125, 2436),
      displaySize: Size(1080, 2340),
      zoomRenderSize: Size(960, 2079),
      exposedRow: 103,
    ),
  ];

  for (final fixture in fixtures) {
    for (final zoomed in [false, true]) {
      testWidgets(
          '${fixture.identifier} keeps a max-height rounded logo inside the '
          'notch (${zoomed ? 'zoomed' : 'standard'})', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        DeviceInfoService.setMockMachineIdentifier(fixture.identifier);
        final renderSize =
            zoomed ? fixture.zoomRenderSize : fixture.standardRenderSize;
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = renderSize;
        tester.view.display.size = fixture.displaySize;
        addTearDown(() {
          debugDefaultTargetPlatformOverride = null;
          DeviceInfoService.reset();
          tester.view.reset();
          tester.view.display.reset();
        });

        const captureKey = ValueKey('notch capture');
        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: HiddenLogo(
              body: const ColoredBox(color: Colors.white),
              notchBuilder: (_, constraints) => Container(
                // Stay within the notch's flat middle so this test isolates
                // its bottom edge from the caller's corner-radius choice.
                width: 100,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  color: const Color(0xffff00ff),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dynamicIslandBuilder: (_, __) => const SizedBox.shrink(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(captureKey),
        );
        await tester.runAsync(() async {
          // Map both UI sizes onto the independently measured mask grid,
          // including the mini's standard render grid before downsampling.
          final image = await boundary.toImage(
            pixelRatio: 3 * fixture.standardRenderSize.width / renderSize.width,
          );
          try {
            final pixels =
                (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
            List<int> pixel(int x, int y) => List.generate(
                  4,
                  (channel) => pixels.getUint8(
                    (y * image.width + x) * 4 + channel,
                  ),
                );
            final centerX = image.width ~/ 2;
            // Guard against hiding the logo entirely as a false-positive fix.
            expect(pixel(centerX, 60), [255, 0, 255, 255]);
            for (var y = fixture.exposedRow; y < fixture.exposedRow + 8; y++) {
              for (var x = centerX - 25; x <= centerX + 25; x++) {
                expect(
                  pixel(x, y),
                  [255, 255, 255, 255],
                  reason: 'Logo paint escaped the physical notch at ($x, $y)',
                );
              }
            }
          } finally {
            image.dispose();
          }
        });
        await tester.pumpWidget(const SizedBox.shrink());
        debugDefaultTargetPlatformOverride = null;
      });
    }
  }
}
