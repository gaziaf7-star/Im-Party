import 'package:general/src/features/auth/domain/entities/colors_entity.dart';
import 'package:general/src/features/auth/domain/use_cases/fetch_colors_uc.dart';
import 'package:general/src/core/index.dart';

part 'colors_event.dart';
part 'colors_state.dart';

class ColorsBloc extends Bloc<ColorsEvent, ColorsState> {
  final FetchColorsUc _fetchColorsUc;

  ColorsBloc(this._fetchColorsUc) : super(const ColorsState()) {
    on<FetchColorsEvent>(_fetchColorsEvent);
  }

  void _fetchColorsEvent(
    FetchColorsEvent event,
    Emitter<ColorsState> emit,
  ) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await _fetchColorsUc(forceRefresh: event.forceRefresh);

    await result.fold(
      (left) async {
        emit(
          state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) async {
        emit(
          state.copyWith(
            reqState: RequestState.loaded,
            message: right.message,
            colors: right.data,
          ),
        );
        await handleColors();
      },
    );
  }

  /// Awaitable fetch+apply used by the cold-start config flow so the FIRST
  /// launch after a panel color change applies the new colors into
  /// [ColorManager] BEFORE the splash navigates — otherwise the fresh tree
  /// builds against the old cached colors and only picks up the new ones on a
  /// later launch (the multi enter/exit bug). Returns once colors are applied.
  ///
  /// [forceRefresh] bypasses the dio HTTP cache so the GET hits the server and
  /// overwrites the stale cached entry. The config flow passes `true` only when
  /// app-check signalled a panel color change (isColorUpdated); when unchanged
  /// the colors are served from cache and this fetch is never called.
  Future<void> fetchAndApplyColors({bool forceRefresh = false}) async {
    final result = await _fetchColorsUc(forceRefresh: forceRefresh);
    await result.fold(
      (left) async {
        // Surface the fetch failure instead of swallowing it. The cached colors
        // (already applied at the top of the config flow) remain the visible
        // fallback, but the error is logged + emitted so it is never hidden
        // (owner rule: no silent fallback masking problems).
        final message = NetworkExceptions.getErrorMessage(left);
        Methods.printLog(
          '❌ fetchAndApplyColors failed: $message — keeping cached colors',
          name: 'ColorsBloc',
        );
        emit(
          state.copyWith(
            reqState: RequestState.error,
            message: message,
          ),
        );
      },
      (right) async {
        emit(
          state.copyWith(
            reqState: RequestState.loaded,
            message: right.message,
            colors: right.data,
          ),
        );
        await handleColors();
      },
    );
  }

  Future<void> handleColors() async {
    if (state.colors == null) {
      return;
    }

    if (state.colors?.bottomNav == null) {
      ConstantsManager.isSvgaNavBar = true;
    } else {
      ConstantsManager.isSvgaNavBar = false;
    }

    await HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.BOTTOM_NAV_ICONS_KEY,
      ConstantsManager.isSvgaNavBar,
    );

    final background = state.colors?.background?.value;
    final backgroundType = state.colors?.background?.type;

    if ((background ?? "").isNotEmpty) {
      await HiveManager().saveData(
        KeysManager.USER_BOX,
        KeysManager.BACKGROUND_KEY,
        background,
      );
      await HiveManager().saveData(
        KeysManager.USER_BOX,
        KeysManager.BACKGROUND_TYPE_KEY,
        backgroundType,
      );
    }

    // Apply all colors

    await Methods.applyColorIfValid(
      colorValue: state.colors?.bottomNav?.bottomColor,
      applyColor: (color) {
        ColorManager.bottomNavColor = color;
      },
      hiveKey: KeysManager.BOTTOM_NAV_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.bottomNav?.activeColor,
      applyColor: (color) {
        ColorManager.bottomNavActiveColor = color;
      },
      hiveKey: KeysManager.ACTIVE_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.bottomNav?.inactiveColor,
      applyColor: (color) {
        ColorManager.bottomNavInactiveColor = color;
      },
      hiveKey: KeysManager.INACTIVE_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.textHeaderColor,
      applyColor: (color) {
        ColorManager.headerColor = color;
      },
      hiveKey: KeysManager.HEADER_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.buttonTextColor,
      applyColor: (color) {
        ColorManager.buttonTextColor = color;
      },
      hiveKey: KeysManager.BUTTON_TEXT_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.textPrimaryColor,
      applyColor: (color) {
        ColorManager.primaryText = color;
      },
      hiveKey: KeysManager.TEXT_PRIMARY_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.textSecondaryColor,
      applyColor: (color) {
        ColorManager.secondaryText = color;
      },
      hiveKey: KeysManager.TEXT_SECONDARY_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.iconColor,
      applyColor: (color) {
        ColorManager.iconColor = color;
      },
      hiveKey: KeysManager.ICON_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.cardColor,
      applyColor: (color) {
        ColorManager.surfaceCardColor = color;
      },
      hiveKey: KeysManager.CARD_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.primaryColor,
      applyColor: (color) {
        ColorManager.primary = color;
      },
      hiveKey: KeysManager.PRIMARY_COLOR_KEY,
    );
    await Methods.applyColorIfValid(
      colorValue: state.colors?.secondaryColor,
      applyColor: (color) {
        ColorManager.secondaryColor = color;
      },
      hiveKey: KeysManager.SECONDARY_COLOR_KEY,
    );
    // `background.value` is a hex OR an image URL; applyColorIfValid no-ops on
    // the URL form. Without this, ColorManager.background stayed frozen at the
    // build-time near-black (#05060A) on every palette — the reason the header
    // fade and bodyBackgroundGradient kept reintroducing a dark edge the owner
    // never asked for.
    await Methods.applyColorIfValid(
      colorValue: background,
      applyColor: (color) {
        ColorManager.background = color;
      },
      hiveKey: KeysManager.BACKGROUND_COLOR_KEY,
    );

    // Bottom-nav icons from the panel: 5 tabs × {active, inactive} URLs. Apply
    // them to ColorManager (consumed by both nav bars) and cache the raw URL
    // list so a cold start renders the custom icons before this fetch returns.
    final navIcons = state.colors?.navIcons ?? const [];
    ColorManager.navIcons = navIcons
        .map((e) => NavIconUrls(active: e.active, inactive: e.inactive))
        .toList(growable: false);
    await HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.NAV_ICON_URLS_KEY,
      navIcons.map((e) => '${e.active}|${e.inactive}').toList(growable: false),
    );

    // Panel-driven region backgrounds (regions.nav / regions.body). Apply to
    // ColorManager (consumed by both nav bars) and cache the compact form so a
    // cold start renders the custom region before this fetch returns. A null /
    // empty region leaves the static null so the nav bars fall back to the
    // legacy single-color gradient (existing clients unchanged).
    await _applyRegion(
      region: state.colors?.navRegion,
      apply: (data) => ColorManager.navRegion = data,
      hiveKey: KeysManager.NAV_REGION_KEY,
    );
    await _applyRegion(
      region: state.colors?.bodyRegion,
      apply: (data) => ColorManager.bodyRegion = data,
      hiveKey: KeysManager.BODY_REGION_KEY,
    );

    // Per-color {key}_grad gradient tokens. A `gradient` token feeds the
    // ColorManager gradient getters; a `solid`/absent token clears the static so
    // the matching flat color stays the solid fallback (panel turning a gradient
    // OFF reverts cleanly — no stale gradient lingers).
    await _applyColorTokens();

    Methods().saveCurrentUtcTimeToCache(TypesCache.color);

    // Signal any already-mounted widgets that read ColorManager statics to
    // rebuild with the freshly fetched colors (e.g. a mid-session refetch
    // triggered from the layout). On cold start the tree is built AFTER this
    // completes, so the new values are already in place.
    ConstantsManager.colorsNotifier.value++;
  }

  /// Maps a parsed [RegionEntity] to the core [RegionBackgroundData], applies it
  /// to [ColorManager] and caches its compact form. A null / non-renderable
  /// region clears both the static and the cache so a panel that turns the
  /// region OFF reverts to the legacy gradient (no stale region lingers).
  Future<void> _applyRegion({
    required RegionEntity? region,
    required void Function(RegionBackgroundData?) apply,
    required String hiveKey,
  }) async {
    final renderable = region != null && _isRenderableRegion(region);
    if (renderable) {
      final data = RegionBackgroundData(
        type: region.type,
        colors: region.colors,
        image: region.image,
        direction: region.direction,
        reverse: region.reverse,
      );
      apply(data);
      await HiveManager()
          .saveData(KeysManager.USER_BOX, hiveKey, data.encode());
    } else {
      apply(null);
      await HiveManager().deleteData(KeysManager.USER_BOX, hiveKey);
    }
  }

  bool _isRenderableRegion(RegionEntity region) {
    switch (region.type) {
      case 'color':
      case 'gradient':
        return region.colors.isNotEmpty;
      case 'image':
        return region.image.trim().isNotEmpty;
      default:
        return false;
    }
  }

  /// Apply every parsed `{key}_grad` token to its [ColorManager] static and
  /// cache the gradient ones in their compact form. Only a real multi-stop
  /// gradient is stored; a `solid`/absent token clears the static + cache so the
  /// matching flat color stays the solid fallback.
  Future<void> _applyColorTokens() async {
    final tokens = state.colors?.colorTokens ?? const {};
    await _applyColorToken(
      token: tokens['app_primary_color'],
      apply: (data) => ColorManager.primaryColorToken = data,
      hiveKey: KeysManager.PRIMARY_GRAD_KEY,
    );
    await _applyColorToken(
      token: tokens['text_header_color'],
      apply: (data) => ColorManager.headerColorToken = data,
      hiveKey: KeysManager.HEADER_GRAD_KEY,
    );
    await _applyColorToken(
      token: tokens['button_text_color'],
      apply: (data) => ColorManager.buttonTextColorToken = data,
      hiveKey: KeysManager.BUTTON_TEXT_GRAD_KEY,
    );
    await _applyColorToken(
      token: tokens['text_primary_color'],
      apply: (data) => ColorManager.textPrimaryColorToken = data,
      hiveKey: KeysManager.TEXT_PRIMARY_GRAD_KEY,
    );
    await _applyColorToken(
      token: tokens['text_secondary_color'],
      apply: (data) => ColorManager.textSecondaryColorToken = data,
      hiveKey: KeysManager.TEXT_SECONDARY_GRAD_KEY,
    );
    await _applyColorToken(
      token: tokens['icon_color'],
      apply: (data) => ColorManager.iconColorToken = data,
      hiveKey: KeysManager.ICON_GRAD_KEY,
    );
    await _applyColorToken(
      token: tokens['card_color'],
      apply: (data) => ColorManager.cardColorToken = data,
      hiveKey: KeysManager.CARD_GRAD_KEY,
    );
  }

  /// Maps a parsed [ColorTokenEntity] to the core [ColorTokenData], applies it to
  /// [ColorManager] and caches its compact form — but ONLY when it is a real
  /// multi-stop gradient. A solid/null token clears the static and cache so the
  /// flat color remains the source.
  Future<void> _applyColorToken({
    required ColorTokenEntity? token,
    required void Function(ColorTokenData?) apply,
    required String hiveKey,
  }) async {
    if (token != null && token.isGradient) {
      final data = ColorTokenData(
        type: token.type,
        colors: token.colors,
        direction: token.direction,
        reverse: token.reverse,
      );
      apply(data);
      await HiveManager()
          .saveData(KeysManager.USER_BOX, hiveKey, data.encode());
    } else {
      apply(null);
      await HiveManager().deleteData(KeysManager.USER_BOX, hiveKey);
    }
  }

  void applyCachedColors() {
    final colorKeys = {
      KeysManager.PRIMARY_COLOR_KEY: (Color c) => ColorManager.primary = c,
      KeysManager.SECONDARY_COLOR_KEY: (Color c) =>
          ColorManager.secondaryColor = c,
      KeysManager.BACKGROUND_COLOR_KEY: (Color c) =>
          ColorManager.background = c,
      KeysManager.BOTTOM_NAV_COLOR_KEY: (Color c) =>
          ColorManager.bottomNavColor = c,
      KeysManager.ACTIVE_COLOR_KEY: (Color c) =>
          ColorManager.bottomNavActiveColor = c,
      KeysManager.INACTIVE_COLOR_KEY: (Color c) =>
          ColorManager.bottomNavInactiveColor = c,
      KeysManager.HEADER_COLOR_KEY: (Color c) => ColorManager.headerColor = c,
      KeysManager.BUTTON_TEXT_COLOR_KEY: (Color c) =>
          ColorManager.buttonTextColor = c,
      KeysManager.TEXT_PRIMARY_COLOR_KEY: (Color c) =>
          ColorManager.primaryText = c,
      KeysManager.TEXT_SECONDARY_COLOR_KEY: (Color c) =>
          ColorManager.secondaryText = c,
      KeysManager.ICON_COLOR_KEY: (Color c) => ColorManager.iconColor = c,
      KeysManager.CARD_COLOR_KEY: (Color c) =>
          ColorManager.surfaceCardColor = c,
    };

    ConstantsManager.isSvgaNavBar = HiveManager().getData<bool>(
            KeysManager.USER_BOX, KeysManager.BOTTOM_NAV_ICONS_KEY) ??
        true;

    ColorManager.restoreCachedNavIcons();
    ColorManager.restoreCachedRegions();
    ColorManager.restoreCachedColorTokens();

    for (final entry in colorKeys.entries) {
      final hex =
          HiveManager().getData<String>(KeysManager.USER_BOX, entry.key);
      final color = Methods.safeHexColor(hex);
      if (color != null) {
        entry.value(color);
      }
    }
  }
}
