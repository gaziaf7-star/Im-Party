/// Central sanitization for user-generated text before it reaches Flutter's
/// native text-layout engine.
///
/// The crash this guards against — `Invalid argument(s): string is not
/// well-formed UTF-16` inside `_NativeParagraphBuilder.addText` — is caused
/// ONLY by LONE (unpaired) UTF-16 surrogate code units. A Dart `String` is a
/// sequence of UTF-16 code units; an astral code point (most emoji, including
/// every glyph of a ZWJ family/profession/flag sequence) is stored as a
/// high+low surrogate PAIR. A pair is valid and must be preserved; a surrogate
/// that is missing its partner is malformed UTF-16 and aborts native layout.
///
/// Therefore [sanitizedForDisplay] is intentionally MINIMAL: it strips only
/// unpaired surrogates (and the genuinely render-breaking C0 control bytes /
/// DEL, which are never legitimate in display text), and leaves everything else
/// exactly as written. In particular it preserves, because they are required
/// for correct rendering and do NOT cause the crash:
///
///   * U+200D ZERO WIDTH JOINER — joins the parts of family / profession /
///     rainbow-flag emoji; dropping it shatters the sequence into loose glyphs.
///   * U+200C ZERO WIDTH NON-JOINER — typographically required in Arabic /
///     Persian (e.g. correct presentation forms, plural suffixes).
///   * U+200B ZERO WIDTH SPACE — legitimate soft-break opportunity.
///   * U+FE0E / U+FE0F VARIATION SELECTORS — select text vs. colour emoji
///     presentation; dropping U+FE0F makes emoji render monochrome.
///   * Bidi marks / overrides / isolates (U+200E, U+200F, U+202A–U+202E,
///     U+2066–U+2069) — needed to order mixed Arabic + Latin / numbers.
///   * Valid surrogate PAIRS — every multi-code-unit emoji and astral glyph.
///
/// A single leading BOM (U+FEFF) is dropped because it is byte-order noise that
/// can render as a stray glyph at the very start; BOMs elsewhere are left alone
/// (mid-string U+FEFF is a zero-width no-break joiner and harmless).
///
/// It is dependency-free (pure Dart) so it runs anywhere and is unit-testable
/// without the Flutter binding.
extension TextSanitizer on String {
  /// A copy of this string safe to hand to a [Text] / [TextSpan].
  ///
  /// Returns the original instance unchanged when nothing needed stripping, so
  /// the common (clean) case allocates nothing.
  String get sanitizedForDisplay {
    if (isEmpty) return this;

    final units = codeUnits;
    final out = StringBuffer();
    var changed = false;

    for (var i = 0; i < units.length; i++) {
      final unit = units[i];

      // High surrogate (U+D800–U+DBFF): valid only when immediately followed
      // by a low surrogate (U+DC00–U+DFFF). Keep the pair, drop a lone one.
      if (unit >= 0xD800 && unit <= 0xDBFF) {
        if (i + 1 < units.length &&
            units[i + 1] >= 0xDC00 &&
            units[i + 1] <= 0xDFFF) {
          out
            ..writeCharCode(unit)
            ..writeCharCode(units[i + 1]);
          i++; // consumed the low surrogate too
        } else {
          changed = true; // lone high surrogate -> drop
        }
        continue;
      }

      // Lone low surrogate (any low surrogate reaching here has no preceding
      // high surrogate, since valid pairs are consumed above) -> drop.
      if (unit >= 0xDC00 && unit <= 0xDFFF) {
        changed = true;
        continue;
      }

      // A single leading BOM (U+FEFF) is byte-order noise; drop it only at the
      // very start. Elsewhere U+FEFF is a harmless zero-width no-break space.
      if (unit == 0xFEFF && i == 0) {
        changed = true;
        continue;
      }

      // C0 control bytes (U+0000–U+001F) except tab/newline/carriage-return,
      // plus DEL (U+007F): never legitimate in display text and they break the
      // paragraph layout. Everything else — zero-width joiners, ZWNJ, variation
      // selectors, bidi marks/overrides/isolates — is preserved verbatim.
      if (unit < 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D) {
        changed = true;
        continue;
      }
      if (unit == 0x7F) {
        changed = true;
        continue;
      }

      out.writeCharCode(unit);
    }

    return changed ? out.toString() : this;
  }
}
