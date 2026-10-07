// Pure-Dart unit tests for the admin-color crash hardening (Jo Live, package `general`).
//
// `Methods.safeHexColor` lives in lib/src/core/utils/methods.dart, which pulls in
// heavy plugin imports and is not loadable in a pure-Dart test. Following the
// convention of crash_fix_helpers_test.dart, we replicate the helper here
// byte-for-byte with the source and lock its behaviour. If the production logic
// drifts, this replica must be updated in lockstep — that is the point: this file
// documents and pins the exact "never crash on a bad admin color" rule.
//
// It also pins the BACKEND rule (App\Rules\HexColor) regex so the two layers of
// the defense-in-depth stay consistent: the backend rejects non-canonical input
// at the source (#RRGGBB / #RRGGBBAA), while the frontend is lenient on the bad
// data already stored (accepts a missing '#', stray spaces) — but never crashes.

import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Replica of Methods.safeHexColor (lib/src/core/utils/methods.dart ~1845).
// ---------------------------------------------------------------------------
Color? safeHexColor(String? hexColor) {
  if (hexColor == null) return null;
  var hex = hexColor.trim();
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 6) hex = 'ff$hex';
  if (hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  return value == null ? null : Color(value);
}

// ---------------------------------------------------------------------------
// Replica of the backend canonical rule App\Rules\HexColor::passes regex.
// ---------------------------------------------------------------------------
final RegExp _backendHexRule = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
bool backendAccepts(String? value) {
  if (value == null || value.isEmpty) return true; // nullable handled separately
  return _backendHexRule.hasMatch(value);
}

void main() {
  group('safeHexColor — valid inputs render the right Color', () {
    test('#RRGGBB -> opaque color', () {
      expect(safeHexColor('#1A2B3C'), const Color(0xff1a2b3c));
    });

    test('#RRGGBB white', () {
      expect(safeHexColor('#FFFFFF'), const Color(0xffffffff));
    });

    test('lowercase hex is accepted', () {
      expect(safeHexColor('#1a2b3c'), const Color(0xff1a2b3c));
    });

    test('missing # is tolerated (legacy stored data)', () {
      expect(safeHexColor('1A2B3C'), const Color(0xff1a2b3c));
    });

    test('surrounding spaces are trimmed', () {
      expect(safeHexColor('  #1A2B3C  '), const Color(0xff1a2b3c));
    });

    test('#AARRGGBB (8-digit, explicit alpha) is accepted', () {
      expect(safeHexColor('#801A2B3C'), const Color(0x801a2b3c));
    });
  });

  group('safeHexColor — bad inputs return null (caller falls back, no crash)', () {
    test('null -> null', () {
      expect(safeHexColor(null), isNull);
    });

    test('empty -> null', () {
      expect(safeHexColor(''), isNull);
    });

    test('named color "red" -> null (was a real crash source)', () {
      expect(safeHexColor('red'), isNull);
    });

    test('3-digit shorthand #FFF -> null', () {
      expect(safeHexColor('#FFF'), isNull);
    });

    test('non-hex characters #GGGGGG -> null (no throw)', () {
      expect(safeHexColor('#GGGGGG'), isNull);
    });

    test('5-digit #12345 -> null', () {
      expect(safeHexColor('#12345'), isNull);
    });

    test('7-digit #1234567 -> null', () {
      expect(safeHexColor('#1234567'), isNull);
    });

    test('the literal string "null" -> null', () {
      expect(safeHexColor('null'), isNull);
    });

    test('gradient/csv value -> null', () {
      expect(safeHexColor('#FFF,#000'), isNull);
    });
  });

  group('backend rule (App\\Rules\\HexColor) stays consistent', () {
    test('accepts canonical #RRGGBB', () {
      expect(backendAccepts('#1A2B3C'), isTrue);
    });

    test('accepts canonical #AARRGGBB', () {
      expect(backendAccepts('#801A2B3C'), isTrue);
    });

    test('empty passes (nullable field)', () {
      expect(backendAccepts(''), isTrue);
    });

    test('rejects missing # at the source (stricter than frontend)', () {
      expect(backendAccepts('1A2B3C'), isFalse);
      // ...while the frontend still survives the already-stored bad value:
      expect(safeHexColor('1A2B3C'), isNotNull);
    });

    test('rejects named colors / shorthand / junk', () {
      expect(backendAccepts('red'), isFalse);
      expect(backendAccepts('#FFF'), isFalse);
      expect(backendAccepts('#GGGGGG'), isFalse);
      expect(backendAccepts('#FFF,#000'), isFalse);
    });
  });
}
