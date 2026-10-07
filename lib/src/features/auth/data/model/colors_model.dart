import 'package:general/src/core/utils/methods.dart';

import '../../domain/entities/colors_entity.dart';

class ColorsModel extends ColorsEntity {
  const ColorsModel({
    super.primaryColor,
    super.secondaryColor,
    super.background,
    super.bottomNav,
    super.textHeaderColor,
    super.buttonTextColor,
    super.textPrimaryColor,
    super.textSecondaryColor,
    super.iconColor,
    super.cardColor,
    super.navIcons,
    super.navRegion,
    super.bodyRegion,
    super.colorTokens,
  });

  // Safe default hexes mirror the hardcoded ColorManager defaults so that a
  // blank/missing backend value renders the correct brand color instead of an
  // empty string (which previously left the UI stale/white).
  static const String _defaultPrimaryColor = '#F0D060';
  static const String _defaultSecondaryColor = '#003FA6';
  static const String _defaultBottomNavColor = '#05060A';
  static const String _defaultActiveColor = '#F0D060';
  static const String _defaultInactiveColor = '#9C8A52';
  static const String _defaultTextHeaderColor = '#05060A';
  static const String _defaultButtonTextColor = '#14110A';
  static const String _defaultTextPrimaryColor = '#000000';
  static const String _defaultTextSecondaryColor = '#707070';
  // Icon tint default — the brand dark used for headers/background. NEVER white,
  // so a missing panel value renders visible (dark) icons on the light surfaces
  // instead of invisible white-on-white ones (owner rule: zero hardcoded white).
  static const String _defaultIconColor = '#05060A';
  // Card/surface default — the current card fill so a missing panel value keeps
  // the existing look (profile feature cards & info cards render white today).
  // The owner sets a darker surface from the panel for dark palettes.
  static const String _defaultCardColor = '#FFFFFF';

  factory ColorsModel.fromJson(Map<String, dynamic> json) {
    // Raw (empty-default) reads are kept ONLY to decide whether the backend
    // shipped real bottom-nav colors vs. SVGA nav icons. Do not feed these
    // raw values to the UI.
    final rawBottomColor =
        parseValue<String>(json['bottom_nav']?['bottom_color'], '');
    final rawActiveColor =
        parseValue<String>(json['bottom_nav']?['active_color'], '');
    final rawInactiveColor =
        parseValue<String>(json['bottom_nav']?['inactive_color'], '');

    final isAnyColorValid =
        (rawBottomColor.isNotEmpty &&
                rawBottomColor.toLowerCase() != '#000000') ||
            (rawActiveColor.isNotEmpty &&
                rawActiveColor.toLowerCase() != '#000000') ||
            (rawInactiveColor.isNotEmpty &&
                rawInactiveColor.toLowerCase() != '#000000');

    return ColorsModel(
      primaryColor:
          parseValue<String>(json['primary_color'], _defaultPrimaryColor),
      secondaryColor: parseValue<String>(
          json['secondary_color'], _defaultSecondaryColor),
      background: json['background'] is Map<String, dynamic>
          ? BackgroundDataModel.fromJson(json['background'])
          : null,
      bottomNav: isAnyColorValid
          ? BottomNavColorsModel(
              bottomColor: rawBottomColor.isNotEmpty
                  ? rawBottomColor
                  : _defaultBottomNavColor,
              activeColor: rawActiveColor.isNotEmpty
                  ? rawActiveColor
                  : _defaultActiveColor,
              inactiveColor: rawInactiveColor.isNotEmpty
                  ? rawInactiveColor
                  : _defaultInactiveColor,
            )
          : null,
      textHeaderColor: parseValue<String>(
          json['text_header_color'], _defaultTextHeaderColor),
      buttonTextColor: parseValue<String>(
          json['button_text_color'], _defaultButtonTextColor),
      textPrimaryColor: parseValue<String>(
          json['text_primary_color'], _defaultTextPrimaryColor),
      textSecondaryColor: parseValue<String>(
          json['text_secondary_color'], _defaultTextSecondaryColor),
      iconColor: parseValue<String>(json['icon_color'], _defaultIconColor),
      cardColor: parseValue<String>(json['card_color'], _defaultCardColor),
      navIcons: _parseNavIcons(json['nav_icons']),
      navRegion: RegionModel.fromJson(
          json['regions'] is Map ? json['regions']['nav'] : null),
      bodyRegion: RegionModel.fromJson(
          json['regions'] is Map ? json['regions']['body'] : null),
      colorTokens: _parseColorTokens(json),
    );
  }

  /// The flat color keys whose `{key}_grad` ColorToken siblings the app reads.
  /// Mirrors the keys dual-emitted by the backend (ColorController::appCollor).
  static const List<String> _colorTokenKeys = [
    'app_primary_color',
    'text_header_color',
    'button_text_color',
    'text_primary_color',
    'text_secondary_color',
    'icon_color',
    'card_color',
  ];

  /// Parse every `{key}_grad` ColorToken present in the payload, keyed by the
  /// flat color key (without the `_grad` suffix). Missing keys are skipped so the
  /// flat hex stays the only source for that color (back-compat with older
  /// backends that don't emit the siblings).
  static Map<String, ColorTokenModel> _parseColorTokens(
      Map<String, dynamic> json) {
    final tokens = <String, ColorTokenModel>{};
    for (final key in _colorTokenKeys) {
      final token = ColorTokenModel.fromJson(json['${key}_grad']);
      if (token != null) tokens[key] = token;
    }
    return tokens;
  }

  /// Parse the ordered `nav_icons` array of {active, inactive} URL objects.
  /// Tolerates a missing/old-shape payload (the previous flat list of URLs):
  /// a bare string element becomes the icon's active URL with no inactive.
  static List<NavIconModel> _parseNavIcons(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map<NavIconModel>((e) {
      if (e is Map) {
        return NavIconModel(
          active: parseValue<String>(e['active'], ''),
          inactive: parseValue<String>(e['inactive'], ''),
        );
      }
      return NavIconModel(active: parseValue<String>(e, ''));
    }).toList();
  }
}

class NavIconModel extends NavIconEntity {
  const NavIconModel({super.active, super.inactive});

  factory NavIconModel.fromJson(Map<String, dynamic> json) => NavIconModel(
        active: parseValue<String>(json['active'], ''),
        inactive: parseValue<String>(json['inactive'], ''),
      );
}

class BackgroundDataModel extends BackgroundDataEntity {
  const BackgroundDataModel({
    super.value,
    super.type,
  });

  factory BackgroundDataModel.fromJson(Map<String, dynamic> json) =>
      BackgroundDataModel(
        value: parseValue<String>(json['value'], ''),
        type: parseValue<String>(json['type'], ''),
      );
}

class RegionModel extends RegionEntity {
  const RegionModel({
    super.type,
    super.colors,
    super.image,
    super.direction,
    super.reverse,
  });

  /// Parses a `regions.{body,nav}` block. Tolerates a missing/non-map payload
  /// (returns null so the caller falls back) and a `colors` field shipped as
  /// either a JSON list or a comma-separated string. Blank hex entries are
  /// dropped so a half-filled gradient never renders a transparent band.
  ///
  /// `direction`/`reverse` are read and clamped to the exact panel/back enum so
  /// the gradient renders along the SAME axis the owner saved (the round-trip
  /// bug): the backend always emits both for a gradient (ColorController), and
  /// older payloads that omit them fall back to vertical/forward.
  static RegionModel? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    return RegionModel(
      type: parseValue<String>(raw['type'], '').trim().toLowerCase(),
      colors: parseColorList(raw['colors']),
      image: parseValue<String>(raw['image'], '').trim(),
      direction: clampDirection(raw['direction']),
      reverse: coerceBool(raw['reverse']),
    );
  }
}

class ColorTokenModel extends ColorTokenEntity {
  const ColorTokenModel({
    super.type,
    super.colors,
    super.direction,
    super.reverse,
  });

  /// Parses a `{key}_grad` ColorToken object. Returns null for a missing /
  /// non-map payload so the caller keeps the flat hex as the only source.
  ///
  /// `type` is normalized to `solid` | `gradient` (anything else -> `solid`).
  /// `direction`/`reverse` are clamped to the exact panel/back enum so a gradient
  /// token renders along the axis the owner saved.
  static ColorTokenModel? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final type =
        parseValue<String>(raw['type'], 'solid').trim().toLowerCase();
    return ColorTokenModel(
      type: type == 'gradient' ? 'gradient' : 'solid',
      colors: parseColorList(raw['colors']),
      direction: clampDirection(raw['direction']),
      reverse: coerceBool(raw['reverse']),
    );
  }
}

/// Allowed gradient directions — mirrors the backend enum
/// (ColorController::GRADIENT_DIRECTIONS / SettingsController) exactly so the
/// persisted JSON and the app can never drift. `vertical` is the safe default.
const List<String> kGradientDirections = [
  'vertical',
  'horizontal',
  'diagonal_down',
  'diagonal_up',
  'radial',
];

/// Clamp a stored direction to [kGradientDirections], defaulting to `vertical`
/// (mirrors ColorController::clampDirection).
String clampDirection(dynamic value) {
  final dir = '${value ?? ''}'.trim().toLowerCase();
  return kGradientDirections.contains(dir) ? dir : 'vertical';
}

/// Coerce a stored reverse flag to a real bool — accepts the backend's real
/// JSON bool plus the panel's `1`/`'1'`/`'true'` shapes
/// (mirrors ColorController::boolFlag).
bool coerceBool(dynamic value) {
  return value == true ||
      value == 1 ||
      value == '1' ||
      '$value'.trim().toLowerCase() == 'true';
}

/// Parse a `colors` field shipped as either a JSON list or a comma-separated
/// string. Blank entries are dropped so a half-filled gradient never renders a
/// transparent band.
List<String> parseColorList(dynamic raw) {
  final Iterable<dynamic> items;
  if (raw is List) {
    items = raw;
  } else if (raw is String) {
    items = raw.split(',');
  } else {
    return const [];
  }
  return items
      .map((e) => '$e'.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

class BottomNavColorsModel extends BottomNavColorsEntity {
  const BottomNavColorsModel({
    super.bottomColor,
    super.activeColor,
    super.inactiveColor,
  });

  factory BottomNavColorsModel.fromJson(Map<String, dynamic> json) =>
      BottomNavColorsModel(
        bottomColor: parseValue<String>(
            json['bottom_color'], ColorsModel._defaultBottomNavColor),
        activeColor: parseValue<String>(
            json['active_color'], ColorsModel._defaultActiveColor),
        inactiveColor: parseValue<String>(
            json['inactive_color'], ColorsModel._defaultInactiveColor),
      );
}
