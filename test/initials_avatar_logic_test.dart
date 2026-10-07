// Pure-Dart unit tests for the placeholder avatar logic (Jo Live, package `general`).
//
// `InitialsAvatar` lives in lib/src/core/widgets/initials_avatar.dart and depends
// on Flutter widgets, so this file follows the project convention of
// crash_fix_helpers_test.dart: the testable helpers (initials extraction +
// deterministic color hash) are replicated here byte-for-byte, then locked.
// If production drifts, this replica must be updated in lockstep.

import 'package:characters/characters.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Replica of InitialsAvatar._initials (lib/src/core/widgets/initials_avatar.dart)
// ---------------------------------------------------------------------------
String initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  final first = parts.first.characters.isEmpty
      ? ''
      : parts.first.characters.first;
  if (parts.length >= 2) {
    final second = parts[1].characters.isEmpty
        ? ''
        : parts[1].characters.first;
    return (first + second).toUpperCase();
  }
  return first.toUpperCase();
}

// ---------------------------------------------------------------------------
// Replica of InitialsAvatar._palette + _backgroundFor.
// ---------------------------------------------------------------------------
const List<Color> palette = <Color>[
  Color(0xFF26A69A),
  Color(0xFFEF5350),
  Color(0xFF42A5F5),
  Color(0xFFAB47BC),
  Color(0xFFFFA726),
  Color(0xFF66BB6A),
  Color(0xFF7E57C2),
  Color(0xFFEC407A),
  Color(0xFF5C6BC0),
  Color(0xFFFF7043),
  Color(0xFF26C6DA),
  Color(0xFF8D6E63),
];

Color backgroundFor(String key) {
  if (key.isEmpty) return palette.first;
  var hash = 0;
  for (final code in key.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}

void main() {
  group('initialsOf — placeholder text', () {
    test('empty name -> "?"', () {
      expect(initialsOf(''), '?');
    });

    test('whitespace-only -> "?"', () {
      expect(initialsOf('   '), '?');
    });

    test('single first name -> upper-cased first letter', () {
      expect(initialsOf('ahmed'), 'A');
    });

    test('compound name -> first letter of first two parts', () {
      expect(initialsOf('Ahmed Mohamed'), 'AM');
    });

    test('extra inner whitespace collapses to a single split', () {
      expect(initialsOf('Ahmed   Mohamed'), 'AM');
    });

    test('lowercase compound is upper-cased', () {
      expect(initialsOf('ahmed mohamed ali'), 'AM');
    });

    test('arabic single name', () {
      // Arabic letters have no case, so toUpperCase is a no-op — the first
      // grapheme is what surfaces.
      expect(initialsOf('أحمد'), 'أ');
    });

    test('arabic compound name', () {
      expect(initialsOf('أحمد محمد'), 'أم');
    });

    test('emoji name -> the first emoji grapheme', () {
      // characters.first respects grapheme clusters, so a single emoji
      // survives intact.
      expect(initialsOf('🦁 LionKing'), '🦁L');
    });

    test('leading/trailing spaces are trimmed', () {
      expect(initialsOf('  Ahmed  '), 'A');
    });
  });

  group('backgroundFor — deterministic color hash', () {
    test('same input always returns the same color', () {
      expect(backgroundFor('Ahmed'), backgroundFor('Ahmed'));
      expect(backgroundFor('Test Group'), backgroundFor('Test Group'));
    });

    test('different inputs (with different hashes mod palette) differ', () {
      // We can't assert that ALL pairs differ (12-color palette ⇒ collisions
      // exist), but a handful of common names land on distinct buckets.
      final a = backgroundFor('Ahmed');
      final b = backgroundFor('Mohamed');
      final c = backgroundFor('Sara');
      expect({a, b, c}.length, greaterThan(1));
    });

    test('empty input falls back to palette[0]', () {
      expect(backgroundFor(''), palette.first);
    });

    test('every returned color is inside the palette', () {
      for (final name in const ['a', 'group', 'Ahmed', 'محمد', '🦁', 'X']) {
        expect(palette.contains(backgroundFor(name)), isTrue,
            reason: 'name "$name" returned an off-palette color');
      }
    });

    test('hash distribution is non-degenerate across the alphabet', () {
      // Hashing 26 single letters should hit more than one palette bucket.
      final buckets = <Color>{};
      for (var i = 0; i < 26; i++) {
        buckets.add(backgroundFor(String.fromCharCode(0x61 + i)));
      }
      expect(buckets.length, greaterThan(1));
    });
  });
}
