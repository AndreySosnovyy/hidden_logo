import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidden_logo/hidden_logo.dart';
import 'package:hidden_logo/src/device_info_service.dart';
import 'package:hidden_logo/src/parser.dart';

void main() {
  // These native-pixel interiors were independently measured from actual
  // simulator frames, not constructed from HiddenLogoParser's logo presets.
  // Dynamic Island stays opaque in --mask alpha screenshots; alpha-zero only
  // describes the static display corners. Fixtures therefore retain exact
  // opaque black rows and exclude the antialiased boundary of the runtime mask.
  final measurements = jsonDecode(
    File('test/fixtures/dynamic_island_masks.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final shapes = measurements['maskShapes'] as Map<String, dynamic>;
  final fixtures = (measurements['models'] as List<dynamic>)
      .map((value) => value as Map<String, dynamic>)
      .toList();

  test('measured fixtures cover every supported Dynamic Island model', () {
    final measuredModels = {
      for (final fixture in fixtures)
        for (final identifier in fixture['identifiers'] as List<dynamic>)
          HiddenLogoParser(machineIdentifier: identifier as String)
              .currentIPhone,
    };
    final supportedModels = DeviceModel.values.where((model) {
      final identifier = HiddenLogoParser.getIPhoneMachineIdentifier(model);
      return HiddenLogoParser(machineIdentifier: 'iPhone$identifier')
              .iPhonesLogoType ==
          LogoType.dynamicIsland;
    });
    expect(measuredModels, unorderedEquals(supportedModels));
  });

  Size size(dynamic values) {
    final coordinates = values as List<dynamic>;
    return Size(
      (coordinates[0] as num).toDouble(),
      (coordinates[1] as num).toDouble(),
    );
  }

  for (final fixture in fixtures) {
    final standardRenderSize = size(fixture['standardRenderSize']);
    final displaySize = size(fixture['displaySize']);
    final zoomRenderSize = size(fixture['syntheticZoomRenderSize']);
    final dpr = (fixture['devicePixelRatio'] as num).toDouble();
    final shape = shapes[fixture['maskShape']] as Map<String, dynamic>;
    final rows = (shape['rows'] as List<dynamic>)
        .map((value) => (value as List<dynamic>).cast<int>())
        .toList();
    final rowSpans = {
      for (final row in rows) row[0]: (left: row[1], right: row[2]),
    };
    final centerY = (rows.first[0] + rows.last[0]) ~/ 2;

    for (final identifier in (fixture['identifiers'] as List<dynamic>)) {
      for (final zoomed in [false, true]) {
        testWidgets(
          '$identifier paints within the measured Dynamic Island interior '
          '(${zoomed ? 'synthetic zoom' : 'standard'})',
          (tester) async {
            debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
            DeviceInfoService.setMockMachineIdentifier(identifier as String);
            final renderSize = zoomed ? zoomRenderSize : standardRenderSize;
            tester.view.devicePixelRatio = dpr;
            tester.view.physicalSize = renderSize;
            tester.view.display.size = displaySize;
            addTearDown(() {
              debugDefaultTargetPlatformOverride = null;
              DeviceInfoService.reset();
              tester.view.reset();
              tester.view.display.reset();
            });

            const captureKey = ValueKey('Dynamic Island raster capture');
            try {
              await tester.pumpWidget(
                RepaintBoundary(
                  key: captureKey,
                  child: HiddenLogo(
                    body: const ColoredBox(color: Colors.white),
                    notchBuilder: (_, __) => const SizedBox.shrink(),
                    dynamicIslandBuilder: (_, constraints) => SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: const ColoredBox(color: Color(0xffff00ff)),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              final boundary = tester.renderObject<RenderRepaintBoundary>(
                find.byKey(captureKey),
              );
              await tester.runAsync(() async {
                // Map synthetic zoom paint back to the independently captured
                // standard mask grid. This checks scaling math, not a physical
                // device's Display Zoom configuration or resampling pipeline.
                final image = await boundary.toImage(
                  pixelRatio: dpr * standardRenderSize.width / renderSize.width,
                );
                try {
                  expect(image.width, standardRenderSize.width.toInt());
                  final pixels = (await image.toByteData(
                    format: ui.ImageByteFormat.rawRgba,
                  ))!;
                  final centerX = image.width ~/ 2;
                  List<int> pixel(int x, int y) => List.generate(
                        4,
                        (channel) => pixels.getUint8(
                          (y * image.width + x) * 4 + channel,
                        ),
                      );
                  // A missing, invisible or tiny logo must not pass containment.
                  expect(pixel(centerX, centerY), [255, 0, 255, 255]);
                  var paintedPixels = 0;
                  var escapedPixels = 0;
                  String? firstEscape;
                  for (var y = 0; y < 220; y++) {
                    final span = rowSpans[y];
                    for (var x = centerX - 220; x < centerX + 220; x++) {
                      final offset = (y * image.width + x) * 4;
                      final red = pixels.getUint8(offset);
                      final green = pixels.getUint8(offset + 1);
                      final blue = pixels.getUint8(offset + 2);
                      // Include faint tinted antialiasing, which a bright-color
                      // threshold missed in the original maximum-height logos.
                      if (red <= green || blue <= green) continue;
                      paintedPixels++;
                      if (span == null ||
                          x < centerX + span.left ||
                          x >= centerX + span.right) {
                        escapedPixels++;
                        firstEscape ??= '($x, $y)';
                      }
                    }
                  }
                  expect(paintedPixels, greaterThan(15000));
                  expect(
                    escapedPixels,
                    0,
                    reason: 'Logo paint escaped the independently measured '
                        'opaque mask; first pixel $firstEscape',
                  );
                } finally {
                  image.dispose();
                }
              });
            } finally {
              await tester.pumpWidget(const SizedBox.shrink());
              debugDefaultTargetPlatformOverride = null;
            }
          },
        );
      }
    }
  }
}
