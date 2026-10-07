import 'package:general/src/core/index.dart';

class BackgroundImgWidget extends StatelessWidget {
  final Widget child;
  final String? img;
  final bool? resize;
  final double? bottom;

  /// Optional fixed background BAND gradient (e.g.
  /// [ColorManager.homeBackgroundGradient]) — its own left-to-right (or
  /// however it's authored) colour blend, painted across the top of the
  /// screen and faded vertically into plain white lower down by
  /// [_buildGradientBackground]. Null (the default) keeps every existing
  /// screen's look exactly as before — only a caller that explicitly opts in
  /// (currently just [HomePage]) gets this.
  final Gradient? backgroundGradient;

  const BackgroundImgWidget({
    required this.child,
    this.bottom,
    this.img,
    super.key,
    this.resize,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    // A caller that passed [backgroundGradient] (currently only HomePage)
    // wants THAT fixed gradient no matter what — checked BEFORE the
    // body-theme branch below. This was the actual bug: this app has the
    // admin panel's "body theme" turned on (IS_BODY_THEME_ENABLED_KEY),
    // which makes every screen take the _buildBodyTheme() branch instead —
    // a branch that never looked at backgroundGradient at all, painting the
    // global BodyThemeBackground (app.dart) behind a transparent Scaffold
    // instead. That is why the home gradient never appeared: the code that
    // would have painted it never ran.
    if (backgroundGradient != null) {
      return _buildGradientBackground(context);
    }

    final isBodyThemeEnabled = HiveManager().getData<bool>(
      KeysManager.USER_BOX,
      KeysManager.IS_BODY_THEME_ENABLED_KEY,
    ) ??
        false;
    if (isBodyThemeEnabled) {
      return _buildBodyTheme(context);
    }

    return _buildDefaultBackground(context);
  }

  Widget _buildBodyTheme(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resize ?? true,
      backgroundColor: ColorManager.transparent,
      body: child,
    );
  }

  /// Fixed-gradient path — bypasses the body-theme toggle entirely so the
  /// caller's gradient always shows.
  ///
  /// This used to still paint [_headerBackdrop] in a band across the top
  /// (copied from [_buildDefaultBackground] without thinking it through) —
  /// that band is the panel's OWN nav-region colour/gradient, painted on TOP
  /// of [backgroundGradient] for the first [GradientHelper.headerBandHeight]
  /// pixels. On a panel with a dark nav colour that band completely hid the
  /// fixed gradient's purple top, which is exactly the bug the owner
  /// reported: the screen was dark from the status bar down through the
  /// banner cards, then suddenly turned the fixed gradient's light colour
  /// right where the band's fixed height ran out. A caller that opts into
  /// [backgroundGradient] wants THAT gradient full-bleed, not the panel's
  /// header band on top of it — so this path no longer paints one at all.
  ///
  /// [backgroundGradient] is only the TOP BAND's own colour blend (e.g. the
  /// reference design's pink-purple -> blue -> blue-violet, left to right) —
  /// not a top-to-bottom fade by itself. This method paints that band across
  /// roughly the top half of the screen, then uses a [ShaderMask] to fade
  /// the whole band's alpha out vertically (`BlendMode.dstIn` against a
  /// black-to-transparent mask — the same technique [_headerBackdrop] below
  /// already uses for the panel-driven header, just with the fixed colours
  /// here instead) so it dissolves into the plain white [Scaffold]
  /// background beneath rather than ending in a hard edge.
  Widget _buildGradientBackground(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: resize ?? true,
      // The band below fades to fully transparent by the time it reaches
      // the bottom of its own box, so this white is what shows through from
      // there down — i.e. this IS the gradient's "settles into white" tail,
      // not a separate flat colour tacked on afterward.
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.55,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: backgroundGradient),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildDefaultBackground(BuildContext context) {
    final stack = Stack(
      children: [
        SizedBox(
          height: GradientHelper.headerBandHeight,
          width: ScreenUtil().screenWidth,
          child: _headerBackdrop(),
        ),
        child,
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: resize ?? true,
      backgroundColor: ColorManager.scaffoldBg,
      body: stack,
    );
  }

  /// The header band: the admin background IMAGE when one is set, otherwise the
  /// panel nav region.
  ///
  /// A hex stored under [KeysManager.BACKGROUND_KEY] is NOT the header fill —
  /// the header always comes from the nav region (or the derived single-colour
  /// gradient). The two branches that used to follow the `_isColor` test were
  /// byte-identical, so only the image case needs its own painter.
  Widget _headerBackdrop() {
    final background =
    HiveManager().getData(KeysManager.USER_BOX, KeysManager.BACKGROUND_KEY);
    if (background == null || background == "" || _isColor(background)) {
      return GradientHelper.buildHeaderBackdrop(ColorManager.navRegion);
    }
    return ShaderMask(
      shaderCallback: (bounds) =>
          GradientHelper.headerFadeMask().createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: ImageViewWidget(
        url: background,
        height: GradientHelper.headerBandHeight,
        width: ScreenUtil().screenWidth,
        boxFit: BoxFit.cover,
      ),
    );
  }

  bool _isColor(String value) {
    return RegExp(r'^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(value);
  }
}

class GradientHelper {
  /// Header backdrop: the brand colour fading out into the page.
  ///
  /// This used to end at [ColorManager.background], which is a HARDCODED
  /// near-black (0xFF05060A) that the colours bloc never assigns — it sets
  /// primary, header, nav, text, icon and card colours from the panel but not
  /// this one. So every palette, however light, produced a header that faded to
  /// black, and that dark band showed up under the home banner and in the
  /// margins beside it looking like a drop shadow.
  ///
  /// Fading to the lightened brand colour at zero alpha instead means the
  /// backdrop dissolves into whatever the page actually is — white normally,
  /// or the body-theme artwork when one is set — and never introduces a colour
  /// the palette did not ask for.
  static LinearGradient buildGradientFromHeaderColor(Color baseColor) {
    final fadeOut = _lighten(baseColor, 0.6).withValues(alpha: 0.0);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor,
        _lighten(baseColor, 0.3),
        _lighten(baseColor, 0.6),
        fadeOut,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// Height of the header band, in one place so the painter, its [SizedBox] and
  /// the body-theme overlay can never drift apart.
  static double get headerBandHeight => 220.h;

  /// The vertical alpha ramp that dissolves the header band into the page.
  ///
  /// Used as a [BlendMode.dstIn] mask rather than as extra transparent stops on
  /// the colour gradient itself. That separation is the whole point: the hue can
  /// then run along ANY axis the panel saved (the reference app varies its hue
  /// left→right) while the band still fades out top→bottom, which a single
  /// LinearGradient cannot express.
  ///
  /// The first stop keeps the top ~45% at full opacity so the header shows the
  /// panel's real colours instead of a washed-out version of them — the previous
  /// build faded from the very first pixel, which is why three distinct pastels
  /// still read as one near-white smear.
  static LinearGradient headerFadeMask() => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      ColorManager.black,
      ColorManager.black.withValues(alpha: 0.9),
      ColorManager.black.withValues(alpha: 0.35),
      ColorManager.transparent,
    ],
    stops: const [0.0, 0.45, 0.8, 1.0],
  );

  /// Header backdrop taken from the panel's NAV region, so the top of the app
  /// can span several hues along the axis the owner saved.
  ///
  /// [buildGradientFromHeaderColor] can only ever be one hue lightened in steps,
  /// because it derives everything from a single colour. The reference app's top
  /// area is a soft wash that changes hue ACROSS the screen, and the panel
  /// already ships exactly that shape as `regions.nav`.
  ///
  /// Falls back to the single-colour derived gradient when the panel shipped no
  /// usable multi-stop region, so the surface is never left blank.
  static Widget buildHeaderBackdrop(RegionBackgroundData? region) {
    final colors = _regionColors(region);
    if (colors.length < 2) {
      return Container(
        decoration: BoxDecoration(
          gradient: buildGradientFromHeaderColor(ColorManager.primary),
        ),
      );
    }
    return ShaderMask(
      shaderCallback: (bounds) => headerFadeMask().createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: Container(
        decoration: BoxDecoration(
          gradient: ColorManager.buildRegionGradient(
            colors,
            region!.direction,
            region.reverse,
          ),
        ),
      ),
    );
  }

  /// The region's parsed colours, or an empty list when it is absent, not a
  /// gradient, or carries nothing parseable.
  static List<Color> _regionColors(RegionBackgroundData? region) {
    if (region == null || region.type != 'gradient') return const [];
    return region.colors
        .map(Methods.safeHexColor)
        .whereType<Color>()
        .toList(growable: false);
  }

  /// Mirror of the header gradient for a bottom-anchored backdrop: starts as
  /// nothing and grows into the brand colour. Same reason for not starting at
  /// [ColorManager.background] — see buildGradientFromHeaderColor.
  static LinearGradient buildGradientFromBottomColor(Color baseColor) {
    final fadeOut = _lighten(baseColor, 0.4).withValues(alpha: 0.0);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fadeOut,
        _lighten(baseColor, 0.4),
        _lighten(baseColor, 0.3),
        baseColor,
      ],
      stops: const [0.0, 0.6, 1.0, 1.0],
    );
  }

  static LinearGradient buildGradientFromRightColor(Color baseColor) {
    return LinearGradient(
      colors: [
        ColorManager.primary,
        ColorManager.primary.withValues(alpha: 0.7),
        ColorManager.primary.withValues(alpha: 0.0),
      ],
      stops: const [
        0.0,
        0.6,
        1.0,
      ],
    );
  }

  static Color _lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }
}