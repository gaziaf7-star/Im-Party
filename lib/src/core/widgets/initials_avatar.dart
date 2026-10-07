import 'package:flutter/material.dart';
import 'package:general/src/core/constants/color_manager.dart';

/// Renders the first letter (or two for compound names) of a person/group name
/// on a deterministic background color. Used instead of the app logo whenever
/// a user/group has no picture, so the placeholder reads as theirs.
///
/// The background color is picked from a fixed palette by hashing the name, so
/// the same name always renders the same color across the app.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    required this.size,
    this.borderRadius,
    this.fontSize,
  });

  final String name;
  final double size;
  final BorderRadius? borderRadius;
  final double? fontSize;

  /// Deliberately fixed rather than panel-driven: the point is that one person
  /// keeps the same colour everywhere, which a palette that can change under
  /// them cannot give. It IS however held to the palette's rules — the previous
  /// list shipped a hot pink (0xFFEC407A) and an amber (0xFFFFA726, 0xFFFF7043)
  /// that landed on the owner's own profile header, and both are banned brand
  /// colours. These are cool/green hues in the Aurora range, all dark enough for
  /// the white [ColorManager.onDark] initials to stay legible.
  static const List<Color> _palette = <Color>[
    Color(0xFF0F9D8F),
    Color(0xFF0B8457),
    Color(0xFF1F6FB2),
    Color(0xFF4A55C7),
    Color(0xFF6D4AC4),
    Color(0xFF0E8AA8),
    Color(0xFF3D8B4A),
    Color(0xFF4E5D7E),
    Color(0xFF7A4FB5),
    Color(0xFF157A6E),
  ];

  String _initials() {
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

  Color _backgroundFor(String key) {
    if (key.isEmpty) return _palette.first;
    var hash = 0;
    for (final code in key.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials();
    final bg = _backgroundFor(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: ColorManager.onDark,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? (size * 0.42),
          height: 1,
        ),
      ),
    );
  }
}
