
import '../../../../../reels_viewer/reels_viewer.dart';
import 'package:equatable/equatable.dart';

class ColorsEntity extends Equatable {


  // New params
  final String? primaryColor;

  /// Admin-settable SECONDARY brand color (`secondary_color`). The panel has
  /// always emitted it and the app has always ignored it, so
  /// [ColorManager.secondaryColor] stayed frozen at the build-time navy while
  /// every other color followed the palette.
  final String? secondaryColor;
  final BackgroundDataEntity? background; // Nested object
  final BottomNavColorsEntity? bottomNav; // Nested object
  final String? textHeaderColor;
  final String? buttonTextColor;
  final String? textPrimaryColor;
  final String? textSecondaryColor;
  final String? iconColor;

  /// Admin-settable surface color for ELEVATED cards (the "more rooms" room
  /// cards, the profile feature grids/info cards). Distinct from [background]
  /// (the page fill) so the owner can set the card surface independently —
  /// fixing the white-vs-navy card mismatch reported on custom palettes.
  final String? cardColor;

  /// Ordered bottom-nav icon URLs from the admin panel, one per tab
  /// (Home, Explore/Games, Chat, Moment/World, Profile), each with an active
  /// (selected) and inactive (unselected) URL. Empty list when the backend
  /// shipped no icons; an individual URL is '' when that state is unset.
  final List<NavIconEntity> navIcons;

  /// Panel-driven background descriptor for the bottom-nav region
  /// (`regions.nav` in the colors API). Null when the panel shipped no region —
  /// the nav bar then falls back to the legacy single-color derived gradient.
  final RegionEntity? navRegion;

  /// Panel-driven background descriptor for the body region (`regions.body`).
  /// Parsed for model completeness; wired into the body later.
  final RegionEntity? bodyRegion;

  /// Per-color gradient tokens (`{key}_grad` siblings of the flat hexes above).
  /// Keyed by the flat color key — `app_primary_color`, `button_text_color`,
  /// `card_color`, `icon_color`, `text_primary_color`, `text_secondary_color`,
  /// `text_header_color`. A `solid` token carries a single color identical to
  /// the flat hex; a `gradient` token carries 2+ colors + direction + reverse.
  /// Absent keys leave the flat color as the only source (back-compat).
  final Map<String, ColorTokenEntity> colorTokens;

  const ColorsEntity({

    this.primaryColor,
    this.secondaryColor,
    this.background,
    this.bottomNav,
    this.textHeaderColor,
    this.buttonTextColor,
    this.textPrimaryColor,
    this.textSecondaryColor,
    this.iconColor,
    this.cardColor,
    this.navIcons = const [],
    this.navRegion,
    this.bodyRegion,
    this.colorTokens = const {},
  });

  @override
  List<Object?> get props => [

    primaryColor,
    secondaryColor,
    background,
    bottomNav,
    textHeaderColor,
    buttonTextColor,
    textPrimaryColor,
    textSecondaryColor,
    iconColor,
    cardColor,
    navIcons,
    navRegion,
    bodyRegion,
    colorTokens,
  ];
}

/// A per-color "ColorToken" (`{key}_grad`): either a `solid` single color or a
/// `gradient` of 2+ colors drawn along [direction] with optional [reverse].
///
/// [type] mirrors the back enum exactly: `solid` | `gradient` (NOTE: unlike
/// [RegionEntity] there is no `image` or `color` variant). [direction] is one of
/// `vertical` | `horizontal` | `diagonal_down` | `diagonal_up` | `radial`
/// (default `vertical`); [reverse] swaps the gradient start/end.
class ColorTokenEntity extends Equatable {
  final String type;
  final List<String> colors;
  final String direction;
  final bool reverse;

  const ColorTokenEntity({
    this.type = 'solid',
    this.colors = const [],
    this.direction = 'vertical',
    this.reverse = false,
  });

  /// True when this token should render as a multi-stop gradient (type
  /// `gradient` with at least 2 colors). Otherwise callers use the solid color.
  bool get isGradient => type == 'gradient' && colors.length >= 2;

  @override
  List<Object?> get props => [type, colors, direction, reverse];
}

/// A panel-driven background region descriptor (`regions.{body,nav}`).
///
/// [type] is one of `color` | `gradient` | `image`:
///  - `color`    -> a single solid fill ([colors] first entry).
///  - `gradient` -> a LinearGradient over ALL [colors] (any count), drawn along
///                  [direction] and optionally [reverse]d.
///  - `image`    -> a cover-fitted network image at [image].
/// Empty/invalid payloads leave the fields empty so callers fall back.
///
/// [direction] mirrors the panel/back enum exactly:
/// `vertical` | `horizontal` | `diagonal_down` | `diagonal_up` | `radial`
/// (default `vertical`). [reverse] swaps the gradient start/end.
class RegionEntity extends Equatable {
  final String type;
  final List<String> colors;
  final String image;
  final String direction;
  final bool reverse;

  const RegionEntity({
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

  @override
  List<Object?> get props => [type, colors, image, direction, reverse];
}

class NavIconEntity extends Equatable {
  final String active;
  final String inactive;

  const NavIconEntity({this.active = '', this.inactive = ''});

  @override
  List<Object?> get props => [active, inactive];
}

class BackgroundDataEntity extends Equatable {
  final String? value; // color or URL
  final String? type;  // "color" or "image"

  const BackgroundDataEntity({this.value, this.type});

  @override
  List<Object?> get props => [value, type];
}

class BottomNavColorsEntity extends Equatable {
  final String? bottomColor;
  final String? activeColor;
  final String? inactiveColor;

  const BottomNavColorsEntity({
    this.bottomColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  List<Object?> get props => [bottomColor, activeColor, inactiveColor];
}
