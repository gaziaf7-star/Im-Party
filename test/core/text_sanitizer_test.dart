// Unit tests for the C2 crash hardening: central text sanitization
// (lib/src/core/utils/text_sanitizer.dart, package `general`).
//
// The crash `Invalid argument(s): string is not well-formed UTF-16`
// (`_NativeParagraphBuilder.addText`) is caused ONLY by LONE (unpaired) UTF-16
// surrogate code units. `String.sanitizedForDisplay` therefore strips only
// those (plus render-breaking C0 controls / DEL and a single leading BOM) and
// MUST preserve everything that real content needs: ZWJ emoji sequences, the
// Arabic ZWNJ, zero-width space, variation selectors, and bidi marks/isolates.
// These tests pin that contract.
//
// Non-printable / bidi code points are built with `String.fromCharCodes` (never
// embedded as invisible literals) so the cases stay reviewable and exact.

import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/utils/text_sanitizer.dart';

void main() {
  group('String.sanitizedForDisplay', () {
    // ---- Clean content: untouched, same instance (zero-alloc fast path). ----

    test('leaves plain English untouched (identical instance)', () {
      const s = 'Hello world';
      expect(s.sanitizedForDisplay, same(s));
    });

    test('leaves plain Arabic untouched (identical instance)', () {
      const s = 'مرحبا بالعالم';
      expect(s.sanitizedForDisplay, same(s));
    });

    test('keeps a normal emoji intact (identical instance)', () {
      const s = 'hi 😀 there';
      expect(s.sanitizedForDisplay, same(s));
    });

    test('keeps a multi-codepoint emoji (flag) intact (identical instance)', () {
      const s = '🇪🇬'; // regional indicators, two surrogate pairs
      expect(s.sanitizedForDisplay, same(s));
    });

    test('empty string returns the same empty instance', () {
      const s = '';
      expect(s.sanitizedForDisplay, same(s));
    });

    // ---- PRESERVED: things the old sanitizer wrongly stripped. ----

    test('preserves a ZWJ family emoji sequence (U+200D kept)', () {
      // 👨 + ZWJ + 👩 + ZWJ + 👧 -> renders as one family glyph.
      final s = String.fromCharCodes([
        0xD83D, 0xDC68, // 👨
        0x200D, // ZWJ
        0xD83D, 0xDC69, // 👩
        0x200D, // ZWJ
        0xD83D, 0xDC67, // 👧
      ]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves a ZWJ profession emoji (woman technologist)', () {
      // 👩 + ZWJ + 💻
      final s = String.fromCharCodes([
        0xD83D, 0xDC69, // 👩
        0x200D, // ZWJ
        0xD83D, 0xDCBB, // 💻
      ]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves the rainbow flag (waving flag + ZWJ + rainbow)', () {
      // 🏳 (D83C DFF3) + VS16 + ZWJ + 🌈 (D83C DF08)
      final s = String.fromCharCodes([
        0xD83C, 0xDFF3, // 🏳
        0xFE0F, // VS16
        0x200D, // ZWJ
        0xD83C, 0xDF08, // 🌈
      ]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves U+FE0F variation selector (colour emoji presentation)', () {
      // ❤ (U+2764) + VS16 -> red heart in colour.
      final s = String.fromCharCodes([0x2764, 0xFE0F]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves U+FE0E variation selector (text presentation)', () {
      final s = String.fromCharCodes([0x2764, 0xFE0E]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves Arabic ZWNJ (U+200C is typographically required)', () {
      // می‌خواهم (Persian) uses ZWNJ between می and خواهم.
      final s = 'می${String.fromCharCode(0x200C)}خواهم';
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves zero-width space (U+200B)', () {
      final s = String.fromCharCodes([0x61, 0x200B, 0x62]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves bare ZWJ between non-emoji (still valid UTF-16)', () {
      final s = String.fromCharCodes([0x61, 0x200D, 0x62]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves bidi marks LRM / RLM (U+200E, U+200F)', () {
      // Arabic + number ordering relies on these.
      final s = String.fromCharCodes(
          [0x627, 0x200F, 0x31, 0x32, 0x33, 0x200E, 0x627]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves bidi overrides and isolates (U+202A–202E, U+2066–2069)', () {
      final s = String.fromCharCodes([
        0x61,
        0x202A, 0x202B, 0x202C, 0x202D, 0x202E,
        0x62,
        0x2066, 0x2067, 0x2068, 0x2069,
        0x63,
      ]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves line/paragraph separators (U+2028, U+2029)', () {
      final s = String.fromCharCodes([0x61, 0x2028, 0x62, 0x2029, 0x63]);
      expect(s.sanitizedForDisplay, same(s));
    });

    test('preserves a mid-string BOM / zero-width no-break space (U+FEFF)', () {
      final s = String.fromCharCodes([0x61, 0xFEFF, 0x62]);
      expect(s.sanitizedForDisplay, same(s));
    });

    // ---- STRIPPED: lone surrogates (the actual crash cause). ----

    test('strips a lone high surrogate', () {
      final s = String.fromCharCodes([0x48, 0xD83D, 0x49]); // H + lone hi + I
      expect(s.sanitizedForDisplay, 'HI');
    });

    test('strips a lone low surrogate', () {
      final s = String.fromCharCodes([0x48, 0xDE00, 0x49]); // H + lone lo + I
      expect(s.sanitizedForDisplay, 'HI');
    });

    test('keeps a valid surrogate pair but drops a trailing lone one', () {
      // 😀 (D83D DE00) followed by a lone high surrogate.
      final s = String.fromCharCodes([0xD83D, 0xDE00, 0xD83D]);
      expect(s.sanitizedForDisplay, '😀');
    });

    test('keeps a ZWJ sequence but drops a lone surrogate around it', () {
      // lone hi + 👨 + ZWJ + 👩 + lone lo  ->  👨‍👩 with both lones removed.
      final s = String.fromCharCodes([
        0xD83D, // lone high
        0xD83D, 0xDC68, // 👨
        0x200D, // ZWJ
        0xD83D, 0xDC69, // 👩
        0xDE00, // lone low
      ]);
      final expected = String.fromCharCodes([
        0xD83D, 0xDC68,
        0x200D,
        0xD83D, 0xDC69,
      ]);
      expect(s.sanitizedForDisplay, expected);
    });

    // ---- STRIPPED: render-breaking C0 controls / DEL and a leading BOM. ----

    test('strips C0 control chars but preserves newline/tab/carriage return',
        () {
      // a + NUL(0x00) + b + c, then \n \t \r kept verbatim.
      final s = String.fromCharCodes(
          [0x61, 0x00, 0x62, 0x63, 0x0A, 0x64, 0x09, 0x65, 0x0D, 0x66]);
      expect(s.sanitizedForDisplay, 'abc\nd\te\rf');
    });

    test('strips DEL (U+007F)', () {
      final s = String.fromCharCodes([0x61, 0x7F, 0x62]);
      expect(s.sanitizedForDisplay, 'ab');
    });

    test('drops a single leading BOM (U+FEFF) only', () {
      final s = String.fromCharCodes([0xFEFF, 0x6E, 0x61, 0x6D, 0x65]);
      expect(s.sanitizedForDisplay, 'name');
    });

    // ---- Mixed real content: hidden crash payload removed, content kept. ----

    test('mixed Arabic + emoji + bidi + lone surrogate: only lone is dropped',
        () {
      // 'أحمد' + RLM + ' 😀 Ali' + lone high surrogate at the end.
      final s = 'أحمد${String.fromCharCode(0x200F)} 😀 Ali'
          '${String.fromCharCode(0xD83D)}';
      final expected = 'أحمد${String.fromCharCode(0x200F)} 😀 Ali';
      expect(s.sanitizedForDisplay, expected);
    });
  });
}
