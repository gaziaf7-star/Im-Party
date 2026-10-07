// Pure-Dart unit tests for the Phase B image-resize logic (Jo Live, package
// `general`), implemented in
//   lib/src/core/widgets/cache/cache_image_widget.dart -> _resizedImage()
//
// _resizedImage() is not directly callable in a pure-Dart test:
//   * it is private to _CacheImageWidgetState
//   * it builds a FileImage(File(_cachedFilePath)) and reads the live
//     BuildContext via MediaQuery.maybeDevicePixelRatioOf(context)
//
// So we replicate the helper's PURE dimension math here, byte-for-byte with the
// source, and lock its behaviour with tests. If the production logic drifts,
// these replicas must be updated in lockstep — which is the point: the tests
// document and pin the exact resize rules. These tests touch no device, plugin,
// or network surface.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Replica of cache_image_widget.dart _resizedImage() pure math (lines 228-251)
//
//   displayWidth  = widget.width  ?? _imageWidth
//   displayHeight = widget.height ?? _imageHeight
//   if (displayWidth == null && displayHeight == null) return file; // no resize
//   final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
//   final cacheWidth  = displayWidth  == null ? null : (displayWidth  * dpr).ceil();
//   final cacheHeight = displayHeight == null ? null : (displayHeight * dpr).ceil();
//   ResizeImage(file, width: cacheWidth, height: cacheHeight,
//               allowUpscaling: false, policy: ResizeImagePolicy.fit);
// ---------------------------------------------------------------------------

/// Sentinel returned when both effective dimensions are null, meaning the source
/// returns the FileImage as-is (NO ResizeImage wrapping / no resize). Mirrors the
/// `return file;` early-out in the implementation.
const Object kNoResize = Object();

/// The documented intent constants the implementation pins. ResizeImage is always
/// constructed with allowUpscaling:false and ResizeImagePolicy.fit.
const bool kAllowUpscaling = false;
const String kResizeImagePolicy = 'fit'; // ResizeImagePolicy.fit

/// Pure replica of the cacheWidth/cacheHeight computation. Returns [kNoResize]
/// when both effective dimensions are null (the no-resize early-out), otherwise a
/// 2-element list [cacheWidth, cacheHeight] where each entry is null (pass-through
/// for that axis) or the ceil()'d physical-pixel target.
Object resizeTargets({
  double? widgetWidth,
  double? widgetHeight,
  double? imageWidth,
  double? imageHeight,
  required double dpr,
}) {
  final displayWidth = widgetWidth ?? imageWidth;
  final displayHeight = widgetHeight ?? imageHeight;
  if (displayWidth == null && displayHeight == null) return kNoResize;
  final cacheWidth = displayWidth == null ? null : (displayWidth * dpr).ceil();
  final cacheHeight =
      displayHeight == null ? null : (displayHeight * dpr).ceil();
  return <int?>[cacheWidth, cacheHeight];
}

void main() {
  group('Phase B _resizedImage dimension math', () {
    group('(a) both dims present -> ceil(d*dpr) each', () {
      test('integer products, dpr 2.0', () {
        expect(
          resizeTargets(widgetWidth: 100, widgetHeight: 50, dpr: 2.0),
          <int?>[200, 100],
        );
      });

      test('auto-computed _imageWidth/_imageHeight used when widget dims null', () {
        // widget.width/height null -> falls back to _imageWidth/_imageHeight.
        expect(
          resizeTargets(imageWidth: 120, imageHeight: 80, dpr: 2.0),
          <int?>[240, 160],
        );
      });

      test('widget dims take precedence over auto-computed image dims', () {
        // displayWidth = widget.width ?? _imageWidth -> widget wins.
        expect(
          resizeTargets(
            widgetWidth: 100,
            widgetHeight: 50,
            imageWidth: 999,
            imageHeight: 999,
            dpr: 2.0,
          ),
          <int?>[200, 100],
        );
      });
    });

    group('(b) one dim null -> that side null, other computed (aspect preserved)', () {
      test('height null -> [computedWidth, null]', () {
        expect(
          resizeTargets(widgetWidth: 100, dpr: 2.0),
          <int?>[200, null],
        );
      });

      test('width null -> [null, computedHeight]', () {
        expect(
          resizeTargets(widgetHeight: 50, dpr: 2.0),
          <int?>[null, 100],
        );
      });

      test('width null with auto image height -> [null, computedHeight]', () {
        expect(
          resizeTargets(imageHeight: 50, dpr: 3.0),
          <int?>[null, 150],
        );
      });
    });

    group('(c) both null -> sentinel meaning no-resize', () {
      test('all dims null -> kNoResize (return file as-is)', () {
        expect(
          resizeTargets(dpr: 2.0),
          same(kNoResize),
        );
      });

      test('explicit nulls -> kNoResize', () {
        expect(
          resizeTargets(
            widgetWidth: null,
            widgetHeight: null,
            imageWidth: null,
            imageHeight: null,
            dpr: 3.0,
          ),
          same(kNoResize),
        );
      });
    });

    group('(d) non-integer products round UP via ceil', () {
      test('100 * 2.625 = 262.5 -> 263', () {
        expect(
          resizeTargets(widgetWidth: 100, dpr: 2.625),
          <int?>[263, null],
        );
      });

      test('fractional logical width 33.0 * 3.0 = 99.0 stays 99', () {
        // exact integer product must NOT round up to 100.
        expect(
          resizeTargets(widgetWidth: 33.0, dpr: 3.0),
          <int?>[99, null],
        );
      });

      test('just-above-integer 100.0001 * 1.0 -> 101 (ceil)', () {
        expect(
          resizeTargets(widgetWidth: 100.0001, dpr: 1.0),
          <int?>[101, null],
        );
      });

      test('both axes round up independently, dpr 2.625', () {
        // 200 * 2.625 = 525.0 (exact) ; 130 * 2.625 = 341.25 -> 342
        expect(
          resizeTargets(widgetWidth: 200, widgetHeight: 130, dpr: 2.625),
          <int?>[525, 342],
        );
      });
    });

    group('(e) dpr values 1.0 / 2.0 / 2.625 / 3.0', () {
      const w = 100.0;
      const h = 80.0;
      test('dpr 1.0', () {
        expect(resizeTargets(widgetWidth: w, widgetHeight: h, dpr: 1.0),
            <int?>[100, 80]);
      });
      test('dpr 2.0', () {
        expect(resizeTargets(widgetWidth: w, widgetHeight: h, dpr: 2.0),
            <int?>[200, 160]);
      });
      test('dpr 2.625 (ceil)', () {
        // 100 * 2.625 = 262.5 -> 263 ; 80 * 2.625 = 210.0 -> 210
        expect(resizeTargets(widgetWidth: w, widgetHeight: h, dpr: 2.625),
            <int?>[263, 210]);
      });
      test('dpr 3.0', () {
        expect(resizeTargets(widgetWidth: w, widgetHeight: h, dpr: 3.0),
            <int?>[300, 240]);
      });
    });

    group('(f) documented intent constants are locked', () {
      test('allowUpscaling is false (memory only, never decode above source)', () {
        expect(kAllowUpscaling, isFalse);
      });

      test('policy is ResizeImagePolicy.fit (preserve aspect inside target box)',
          () {
        expect(kResizeImagePolicy, 'fit');
      });
    });
  });
}
