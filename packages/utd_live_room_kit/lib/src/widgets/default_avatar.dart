import 'package:flutter/material.dart';

import '../theme/utd_room_theme.dart';

/// Default circular avatar for a seat occupant.
///
/// Loads [url] via [Image.network]; while loading or on error it shows an
/// initials fallback derived from [name] (falling back to [fallbackId]). No
/// extra image-caching dependency is required — a custom `avatarBuilder` on
/// `UTDLiveRoomConfig` replaces this entirely.
class UTDDefaultAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final String fallbackId;
  final double size;
  final UTDRoomTheme theme;

  const UTDDefaultAvatar({
    super.key,
    required this.url,
    required this.name,
    required this.size,
    required this.theme,
    this.fallbackId = '',
  });

  String get _initial {
    final source = name.trim().isNotEmpty ? name.trim() : fallbackId.trim();
    if (source.isEmpty) return '?';
    return source.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    final placeholder = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[700],
      child: Text(
        _initial,
        style: TextStyle(
          color: theme.onSurface,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final hasUrl = url != null && url!.trim().isNotEmpty;
    if (!hasUrl) return placeholder;

    // Decode at the displayed pixel size (not the full source resolution) so a
    // grid of avatars doesn't hold large bitmaps in memory or burn decode time.
    final cachePx = (size * MediaQuery.of(context).devicePixelRatio).round();

    return ClipOval(
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: cachePx,
        cacheHeight: cachePx,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
      ),
    );
  }
}
