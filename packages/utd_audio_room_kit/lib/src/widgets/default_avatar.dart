import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/utd_room_theme.dart';

/// Default circular avatar for a seat occupant.
///
/// Loads [url] through a DISK-backed cache ([CachedNetworkImage]), so an
/// avatar is downloaded once per install, not once per app session — with
/// plain `Image.network` every room entry re-downloaded every occupant's
/// full-resolution image and seats showed initials for seconds. While loading
/// or on error it shows an initials fallback derived from [name] (falling
/// back to [fallbackId]). A custom `avatarBuilder` on `UTDAudioRoomConfig`
/// replaces this entirely.
///
/// Note: the decode size is capped to the displayed pixels, but the BYTES on
/// the wire are whatever the URL serves — pass CDN thumbnail URLs (e.g.
/// `?w=128`) for the biggest win.
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
    // devicePixelRatioOf (not MediaQuery.of): a full-MediaQuery dependency
    // would rebuild every avatar on each keyboard-inset animation frame.
    final cachePx =
        (size * MediaQuery.devicePixelRatioOf(context)).round();

    return ClipOval(
      child: CachedNetworkImage(
        // Keyed by occupant so a seat that changes hands gets a FRESH image
        // element (initials placeholder while the new avatar loads) —
        // useOldImageOnUrlChange would otherwise keep showing the previous
        // occupant's photo. Same-user rebuilds still reuse the element.
        key: ValueKey(fallbackId.isNotEmpty ? fallbackId : url),
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: cachePx,
        memCacheHeight: cachePx,
        // Never flash back to initials when the provider key changes (e.g. a
        // rebuild after a seat update) — keep showing the old image.
        useOldImageOnUrlChange: true,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}
