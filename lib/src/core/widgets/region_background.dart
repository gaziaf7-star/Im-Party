import 'package:general/src/core/index.dart';

/// A core-layer, panel-driven background descriptor for a UI region
/// (`regions.{body,nav}` in the colors API). Kept in the core layer (free of any
/// feature import) so [ColorManager] can hold it and both nav bars can read it.
///
/// [type] is one of `color` | `gradient` | `image`:
///  - `color`    -> a single solid fill ([colors] first entry).
///  - `gradient` -> a LinearGradient over ALL [colors] (any count), drawn along
///                  [direction] and optionally [reverse]d.
///  - `image`    -> a cover-fitted network image at [image].
///
/// [direction] mirrors the panel/back enum exactly: `vertical` | `horizontal` |
/// `diagonal_down` | `diagonal_up` | `radial` (default `vertical`). [reverse]
/// swaps the gradient start/end so the saved axis renders faithfully.
class RegionBackgroundData {
  final String type;
  final List<String> colors;
  final String image;
  final String direction;
  final bool reverse;

  const RegionBackgroundData({
    this.type = '',
    this.colors = const [],
    this.image = '',
    this.direction = 'vertical',
    this.reverse = false,
  });

  /// True when this descriptor carries enough to render its [type]; an empty
  /// descriptor signals the caller to use its fallback (legacy gradient).
  bool get isRenderable {
    switch (type) {
      case 'color':
      case 'gradient':
        return colors.isNotEmpty;
      case 'image':
        return image.trim().isNotEmpty;
      default:
        return false;
    }
  }

  /// Compact cache form: `type|image|c1,c2,...|direction|reverse` — round-trips
  /// through Hive so the region (and its saved direction/reverse) applies on cold
  /// start before the colors response returns.
  String encode() =>
      '$type|$image|${colors.join(',')}|$direction|${reverse ? '1' : '0'}';

  /// Parses [encode]'s output. Returns null for a null/blank cache entry so the
  /// caller keeps its fallback. Backward-compatible with the legacy 3-part form
  /// (`type|image|colors`): the two new parts default to vertical/forward so old
  /// Hive entries keep decoding instead of being invalidated on upgrade.
  static RegionBackgroundData? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length < 3) return null;
    final colors = parts[2]
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    return RegionBackgroundData(
      type: parts[0],
      image: parts[1],
      colors: colors,
      direction: parts.length > 3 ? parts[3] : 'vertical',
      reverse: parts.length > 4 && parts[4] == '1',
    );
  }
}

/// A core-layer, panel-driven per-color gradient token (`{key}_grad` in the
/// colors API). Kept in the core layer (free of any feature import) so
/// [ColorManager] can hold the parsed token for each panel color and expose a
/// gradient getter built from it.
///
/// [type] is `solid` | `gradient` (mirrors the back enum; there is no image
/// variant). A `solid` token carries a single color equal to the flat hex; a
/// `gradient` token carries 2+ [colors] drawn along [direction] with optional
/// [reverse]. [direction] is one of `vertical` | `horizontal` | `diagonal_down`
/// | `diagonal_up` | `radial` (default `vertical`).
class ColorTokenData {
  final String type;
  final List<String> colors;
  final String direction;
  final bool reverse;

  const ColorTokenData({
    this.type = 'solid',
    this.colors = const [],
    this.direction = 'vertical',
    this.reverse = false,
  });

  /// True when this token should render as a multi-stop gradient (type
  /// `gradient` with at least 2 colors). Otherwise callers use the solid color.
  bool get isGradient => type == 'gradient' && colors.length >= 2;

  /// Compact cache form: `type|c1,c2,...|direction|reverse` — round-trips through
  /// Hive so the token (and its saved direction/reverse) applies on cold start
  /// before the colors response returns.
  String encode() =>
      '$type|${colors.join(',')}|$direction|${reverse ? '1' : '0'}';

  /// Parses [encode]'s output. Returns null for a null/blank cache entry so the
  /// caller keeps the flat color as the only source.
  static ColorTokenData? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length < 2) return null;
    final colors = parts[1]
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    return ColorTokenData(
      type: parts[0],
      colors: colors,
      direction: parts.length > 2 ? parts[2] : 'vertical',
      reverse: parts.length > 3 && parts[3] == '1',
    );
  }
}

/// Renders a panel-driven background region behind [child], fanning out by the
/// descriptor's [RegionBackgroundData.type]:
///  - `color`    -> a solid first-color fill.
///  - `gradient` -> a top->bottom [LinearGradient] over ALL colors (any count
///                  >= 2, evenly spaced). A single color degrades to a solid.
///  - `image`    -> a cover-fitted cached network image via [CacheImageWidget].
///
/// On a null/empty/invalid descriptor — or a color list that parses to nothing —
/// it renders [fallback] instead, so the surface is NEVER left blank.
class RegionBackground extends StatelessWidget {
  final RegionBackgroundData? descriptor;

  /// Built when [descriptor] is absent or not renderable (e.g. the legacy
  /// single-color derived gradient). Must paint a full background itself.
  final WidgetBuilder fallback;

  final Widget? child;

  const RegionBackground({
    required this.descriptor,
    required this.fallback,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final region = descriptor;
    if (region == null || !region.isRenderable) return _fallback(context);

    switch (region.type) {
      case 'color':
        return _solid(context, region.colors.first);
      case 'gradient':
        return _gradient(context, region);
      case 'image':
        return _image(context, region.image);
      default:
        return _fallback(context);
    }
  }

  /// The caller's fallback background WITH [child] painted on top, so dropping to
  /// the fallback never loses the nav content. The background is stretched to the
  /// (externally-sized) box via [Positioned.fill] while [child] keeps its own
  /// intrinsic layout — never force-expanded — so a BottomNavigationBar lays out
  /// exactly as it did before this wrapper existed.
  Widget _fallback(BuildContext context) {
    final bg = fallback(context);
    if (child == null) return bg;
    return Stack(
      children: [
        Positioned.fill(child: bg),
        child!,
      ],
    );
  }

  Widget _solid(BuildContext context, String hex) {
    final color = Methods.safeHexColor(hex);
    if (color == null) return _fallback(context);
    return Container(color: color, child: child);
  }

  Widget _gradient(BuildContext context, RegionBackgroundData region) {
    final colors = region.colors
        .map(Methods.safeHexColor)
        .whereType<Color>()
        .toList(growable: false);
    if (colors.isEmpty) return _fallback(context);
    if (colors.length == 1) return Container(color: colors.first, child: child);
    // Draw along the panel-saved direction/reverse (the round-trip fix) — a
    // horizontal/diagonal/radial gradient renders on that axis instead of the
    // old hardcoded top->bottom.
    return Container(
      decoration: BoxDecoration(
        gradient: ColorManager.buildRegionGradient(
          colors,
          region.direction,
          region.reverse,
        ),
      ),
      child: child,
    );
  }

  Widget _image(BuildContext context, String url) {
    // The fallback paints UNDER the image so a loading/failed cover never leaves
    // a blank band — the legacy gradient shows through until/if the image draws.
    // The cover image draws nothing on error (isStopLoadingAndError:false). The
    // background + image are stretched to the externally-sized box while [child]
    // keeps its intrinsic layout (never force-expanded).
    return Stack(
      children: [
        Positioned.fill(child: fallback(context)),
        Positioned.fill(
          child: CacheImageWidget(
            url: url,
            boxFit: BoxFit.cover,
            isStopLoadingAndError: false,
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
