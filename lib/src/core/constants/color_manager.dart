import 'dart:math' as math;

import 'package:general/src/core/index.dart';

class ColorManager {
  const ColorManager._();

  // â”€â”€â”€ The one contrast rule â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // The owner picks the page colour from the panel. Shades the vendor designed
  // for their white theme (near-black titles, dark-grey subtitles) then land on
  // a near-black page and disappear. Rather than repaint hundreds of call
  // sites, every TEXT/ICON shade below is declared through [ink]/[inkMuted]:
  // the designed shade is kept while it still reads, and swapped for the
  // panel's own text colour when it does not. A light palette therefore renders
  // exactly as the vendor drew it; a dark one becomes readable everywhere at
  // once. Surface shades (cards, shimmer bases, tab backgrounds) are NOT routed
  // through this â€” they are meant to be dark.

  static double _relativeLuminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  /// WCAG contrast ratio between [a] and [b]: 1.0 when identical, 21.0 for
  /// black on white.
  static double contrastRatio(Color a, Color b) {
    final la = _relativeLuminance(a);
    final lb = _relativeLuminance(b);
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// The colour the page is actually painted with â€” the first renderable stop
  /// of the panel body region, else the flat [background]. This is what text
  /// has to survive against.
  static Color get pageColor {
    final region = bodyRegion;
    if (region != null && region.isRenderable && region.type != 'image') {
      for (final hex in region.colors) {
        final parsed = Methods.safeHexColor(hex);
        if (parsed != null) return parsed;
      }
    }
    return background;
  }

  /// Resolved ink, keyed by the shade that was asked for.
  ///
  /// Every token below is a getter, so a long list rebuilding at 60fps asks the
  /// same handful of questions thousands of times a second. The answer only
  /// changes when the PALETTE changes, so it is computed once per palette and
  /// the whole cache is dropped when the page colour moves.
  static final Map<int, Color> _inkCache = {};
  static int? _inkCacheKey;

  static void _syncInkCache() {
    final key = Object.hash(pageColor.toARGB32(), textPrimary.toARGB32(),
        secondaryText.toARGB32());
    if (_inkCacheKey == key) return;
    _inkCacheKey = key;
    _inkCache.clear();
  }

  /// A BODY-TEXT shade: [designed] while it clears AA (4.5:1) on the page,
  /// otherwise the panel's [textPrimary].
  static Color ink(Color designed) {
    _syncInkCache();
    return _inkCache.putIfAbsent(
      designed.toARGB32(),
          () => contrastRatio(designed, pageColor) >= 4.5 ? designed : textPrimary,
    );
  }

  /// A SUBTITLE shade. Allowed nearer the background (AA large-text, 3:1) and
  /// falls back to [secondaryText] so the hierarchy survives the swap â€” or, if
  /// the panel's own secondary is unreadable too, to a dimmed [textPrimary].
  static Color inkMuted(Color designed) {
    _syncInkCache();
    // Keyed apart from [ink] so the same shade can resolve differently under
    // the two thresholds without one overwriting the other.
    return _inkCache.putIfAbsent(designed.toARGB32() ^ 0x5A5A5A5A, () {
      if (contrastRatio(designed, pageColor) >= 3.0) return designed;
      if (contrastRatio(secondaryText, pageColor) >= 3.0) return secondaryText;
      return Color.lerp(textPrimary, pageColor, 0.35) ?? textPrimary;
    });
  }

  /// The readable ink for an ARBITRARY surface â€” for the handful of widgets
  /// that paint their own fixed background (a white sheet, a brand-coloured
  /// chip) and cannot rely on the page rule.
  static Color inkOn(Color surface) =>
      contrastRatio(white, surface) >= contrastRatio(black, surface)
          ? white
          : black;

  static const Color scaffoldBackgroundColor = Color(0xFFF2F0EF);
  static const Color scaffoldBackgroundColor2 = Color(0xFFEDEEF4);
  static const Color darkGreen = Color(0xFF184C27);

  static const Color lightGreen = Color(0xff53E9AB);

  static const Color yellow3 = Color(0xFFFCCC5E);
  static const Color green = Color(0xFF50BB29);
  static const Color lightOrange = Color(0xFFFFB544);
  static const Color orange3 = Color(0xFFFFc438);
  static const Color orangeIndcator = Color(0xFFFDA030);
  // Ink shades â€” see [ink]. Declared as getters so they track the panel page.
  static Color get lightBlack => ink(const Color(0xFF1F1F1F));
  static Color veryLightBlack = Colors.white.withValues(alpha: 0.15);
  static Color get veryVeryLightBlack => ink(const Color(0xFF313131));
  static Color get black12 => ink(const Color(0xFF121212));
  static const Color backgroundBottomVip = Color(0xFF101010);
  static const Color fieldColorChat = Color(0xff282828);
  static const Color darkGreenChat = Color(0xff025144);
  static const Color greenWhatsApp = Color(0xff25D366);
  static const Color darkBlackChat = Color(0xff1D282F);
  static const Color lightBlackChat = Color(0xFF909090);
  static const Color yellow = Color(0xFFFFAD38);
  static const Color lightYellow = Color(0xFFFAE280);
  static const Color darkYellow = Color(0xFFE3AA6E);
  static const Color gray = Color(0xffD9D9D9);
  static const Color levelColor = Color(0xFFE8EFFF);

  static const Color profileCardColor = Color(0xFF903EE9);

  static const Color cardColor = Color(0xff69B7FC);
  static const Color timeColor = Color(0xffD1D1CF);
  static const Color divider = Color(0xFFf5f5f5);

  // Derived from the mutable [primary] which is set from the panel AFTER class
  // load. As getters they re-derive on every read so they track the white-label
  // primary instead of freezing the build-time brand default (the white-label
  // bug). Same pattern as [theme2TextPrimary].
  static List<Color> get luckyGiftBannerColors => [
    ColorManager.primary,
    ColorManager.primary.withValues(alpha: 0.8),
    ColorManager.primary.withValues(alpha: 0.6),
    ColorManager.transparent,
  ];

  static List<Color> get senderBallanceBannerColors => [
    ColorManager.primary,
    ColorManager.primary,
    ColorManager.primary.withValues(alpha: 0.8),
    ColorManager.primary.withValues(alpha: 0.6),
    ColorManager.primary.withValues(alpha: 0.4),
  ];

  static const List<Color> saveButtonColors = [
    Color(0xFF4C2A72),
    Color(0xFF903EE9),
  ];
  static const List<Color> hostColors = [
    Color(0xFF4192DA),
    Color(0xFF6CB9FD),
  ];
  static const List<Color> familyColors = [
    Color(0xFF01E3CF),
    Color(0xFF00D4C2),
  ];

  static const List<Color> agencyColors = [
    Color(0xFFFDA874),
    Color(0xFFF9BE9A),
  ];

  static const List<Color> gradientButtonChat = [
    Color(0xFF6DD69E),
    Color(0xFF737373),
  ];

  static const List<Color> yellowGrident = [
    Color(0xFFEEB609),
    Color(0xFFDBA514),
  ];

  static const List<Color> buttonGrident = [
    Color(0xFFF9C87C),
    Color(0xFFFF8904),
  ];

  static const List<Color> buttonGridentMain = [
    Color(0xFF4C2A72),
    Color(0xFF903EE9),
  ];

  static const List<Color> followButtonGrident = [
    Color(0xFF5e2a8c),
    Color(0xFF2f286b),
  ];

  static const List<Color> rechargeGrident = [
    Color(0xFF8A2EFF),
    Color(0xFFCCE0FF),
  ];

  static const List<Color> giveGrident = [
    Color(0xFFFFCA5E),
    Color(0xFFFFB02E),
  ];

  static const List<Color> vipBuyButtonGradient = [
    Color(0xFFFDF1AE),
    Color(0xFFFDD54C),
  ];

  static const List<Color> cashOutGradient = [
    Color(0xFFFE7E07),
    Color(0xFFFFDE67),
  ];

  static const List<Color> pinkColors = [
    Color(0xFFD18FF9),
    Color(0xFFC60077),
  ];

  static const List<Color> notificationColors = [
    Color(0xFFFFF5F5),
    Color(0xFFF6FFF0),
    Color(0xFFFEF7E6),
    Colors.white,
  ];

  static const List<Color> agencypurpleColorList = [
    Color(0xFF8A2EFF),
    Color(0xFFCCE0FF),
  ];

  static const List<Color> maleContainer = [
    Color(0xff47cbf2),
    Color(0xff61eff0),
  ];

  static const List<Color> femaleContainer = [
    Color(0xffee81de),
    Color(0xfff3acec),
  ];

  static const List<Color> cpFriends = [
    Color(0xFF6893FB),
    Color(0xFF9DDAFC),
  ];

  static const List<Color> cpCouple = [
    Color(0xFFF7568C),
    Color(0xFFF99BB8),
  ];

  static const List<Color> cpBro = [
    Color(0xFF6377F7),
    Color(0xFF9AA6FB),
  ];

  static const List<Color> cpBackgroundGradient = [
    Color(0xFFFEBCCA),
    Color(0xFFFF8C9B),
  ];

  static const List<Color> bottomCardCpRank = [
    Color(0xFFffb7dc),
    Color(0xFFff74d5),
  ];

  static const List<Color> bottomCardRankGradient = [
    Color(0xFFFFFDFB),
    Color(0xFFFCE2BA),
  ];

  static const List<Color> backgroundVipBottomWidget = [
    Color(0xff0B390B),
    Color(0xff113052),
    Color(0xff310F4F),
    Color(0xff51183E),
    Color(0xff451112),
  ];

  static const Color defaultTextVip = Color(0xFFFEDC8B);

  static const List<Color> vipBackgroundColor = [
    Color(0xff082E0A),
    Color(0xff091A2D),
    Color(0xff1C092D),
    Color(0xff2A061E),
    Color(0xff2C0809),
    Color(0xff000000),
    Color(0xff000000),
    Color(0xff000000),
  ];

  // Getter (not a frozen list): derives from the mutable panel [primary] on
  // every read so it tracks the white-label brand color.
  static List<Color> get joinPurpelColors => [
    primary,
    const Color(0xFFA460D0),
    primary,
  ];
  static List<Color> receiverColors = [
    const Color(0xFF5D78FA),
    const Color(0xFFBD8BFC),
  ];
  static List<Color> roomColors = [
    const Color(0xFFD581FD),
    const Color(0xFFF499F2),
  ];

  static const List<Color> senderColors = [
    Color(0xFFFC8939),
    Color(0xFFFFD73A),
  ];

  static List<Color> backgroudContanerCoins = [
    const Color(0xFFFFE094),
    const Color(0xFFFEF8D4),
  ];

  static List<Color> backgroudContanerAgency = [
    const Color(0xFF5A5A5A).withValues(alpha: 0.82),
    const Color(0xFFBFBFBF),
  ];

  // Getter: depends on the mutable panel [primary] and [secondaryColor], so it
  // must re-derive per read instead of freezing the build-time defaults.
  static List<Color> get mainColorList => [primary, white, secondaryColor];
  static const List<Color> backgroundGradientDiamond = [
    Color(0xff4E51ED),
    Color(0xffAA51E8),
  ];

  //
  static const List<Color> backgroundGradientFamilyPro = [
    Color(0xff9181fe),
    Color(0xffcc68f0),
  ];

  static const List<Color> backgroundOtherUserRank = [
    Color(0xFFF5777B),
    Color(0xFF7791C9),
  ];

  //
  static const List<Color> roomDialogGradient = [
    Color(0xff0E0703),
    Color(0xff2D0F00),
    Color(0xff020100),
  ];

  static Color get textColor2Term => inkMuted(const Color(0xFF666666));
  static const Color whiteGrey = Color(0xFFF8F8F9);
  static const Color whiteGrey4 = Color(0xFFBCBBBA);
  static const Color whiteGrey5 = Color(0xFFEBEAEA);
  static const Color greySubtitle = Color(0xFFBCB6B6);
  static const Color black2 = Color(0xFF2B2B2B);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static Color get scaffoldBg {
    final isEnabled = HiveManager().getData<bool>(
      KeysManager.USER_BOX,
      KeysManager.IS_BODY_THEME_ENABLED_KEY,
    ) ??
        false;
    return isEnabled ? transparent : white;
  }

  static Color get scaffoldBgSpecial {
    final isEnabled = HiveManager().getData<bool>(
      KeysManager.USER_BOX,
      KeysManager.IS_BODY_THEME_ENABLED_KEY,
    ) ??
        false;
    return isEnabled ? transparent : primary;
  }

  static Color get scaffoldBgAlt {
    final isEnabled = HiveManager().getData<bool>(
      KeysManager.USER_BOX,
      KeysManager.IS_BODY_THEME_ENABLED_KEY,
    ) ??
        false;
    return isEnabled ? transparent : offWhite;
  }

  static const Color grey = Color(0xFF707070);
  static const Color transparent = Color(0x00000000);
  static const Color redAccount = Color(0xFFB71C1C);
  static const Color blue = Color(0xFF0091FE);

  static Color get lightDarkText => ink(const Color(0xFF3E3D3D));
  static Color get fffvTextgrey => ink(const Color(0xFF212024));
  static Color get mainTextgrey => ink(const Color(0xFF212024));
  static const Color buttonGrey = Color(0xFFe4e6e5);
  static Color get greyText => inkMuted(const Color(0xFF757373));
  static const Color lightGray = Color(0xFFD2E2FC);
  static const Color trailingColor = Color.fromARGB(255, 184, 184, 184);
  static Color get appBarTitlegrey => inkMuted(const Color(0xFF4D4D4D));
  static const Color grey2 = Color(0xFFC9C9C9);
  static const Color greyTabBar = Color(0xFF2E2E30);
  static const Color grey3 = Color(0xFFD9D9D9);
  static const Color greyLight = Color(0xFFF1F1F1);
  static const Color tapBarDivider = Color(0xFFE1EDFF);
  static const Color greyDark = Color(0xFF3E3E3E);
  static const Color borderColor = Color(0xFFE6E6E6);
  static const Color textAddInfo = Color(0xFFA4A4A4);
  static const Color pink = Color(0xFFEC008C);
  static Color get itemTexGreyt => ink(const Color(0xFF3C3940));

  static const baseColor = Color(0xFFE0E0E0);
  static const highlightColor = Color(0xFFF5F5F5);

  // loading color
  static const Color loadingColor = Color(0xff262E3E);
  static const Color secondaryTextColor = Color(0xffECC8DD);
  static const Color grayTextColor = Color(0xffA6A2A2);
  static const Color bottomNavBarUnselected = Color(0xFFD63B59);
  static const Color bottomNavBarSelected = Color(0xFF003FA6);
  static const Color countryYellow = Color(0xFFFFBF00);
  static const Color searchColor = Color(0xFFCCD8EB);
  static const Color indicatorColor = Color(0xFF2666CF);
  static const Color textTabBar2 = Color(0xFF828181);
  static Color get textTabBar => ink(const Color(0xFF323232));
  static const Color notificationChat1 = Color(0xFF2666CF);
  static const Color myColorMessageChat = Color(0xffAB46EA);
  static const Color senderColorMessageChat = Color(0xFFF6F6F6);
  static const Color greenChat1 = Color(0xFF0da886);
  static const Color rankTopGift = Color(0xFF67cfac);
  static const Color sendGift = Color(0xFF33e5ab);
  static const Color redIndicator = Color(0xFFFF0000);
  static const Color redIcons = Color(0xFFFE2B54);

  static const Color blueTabIndicator = Color(0xFF10A7FC);
  static const Color gold = Color(0xFFA8632A);
  static const Color gold3 = Color(0xFFE59E09);

  static const Color orange = Color(0xFFFF9428);
  static const Color orange2 = Color(0xffFFECEA);
  static const Color babyBlue2 = Color(0xFFCCD8EB);
  static const Color mainColor = Color(0xFF1A1A1A);
  static const Color formFieldColor = Color(0xFFF5F9FF);

  static const Color dailyPrizeBackground = Color(0xFF984C00);
  static const Color vipDialogGray = Color(0xFF1F1F1F);
  static const Color colorTextSup = Color(0xFFFFB4CF);
  static const lightGray1 = Color(0xFFf3f3f3);

  static const Color lightRed = Color(0xFFFF8485);
  static const Color agencyYellow = Color(0xFFE3AE6E);
  static const Color hanPurple = Color(0xFF5519FF);
  static const Color blue2 = Color(0xFF0091FE);
  static const Color darkPink = Color(0xFFF40A6D);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static Color get textForgetColor => inkMuted(const Color(0xFF454545));

  static const Color checkBoxColor = Color(0xFF29B68C);
  static const Color purchaseBottomColor = Color(0xFFA58DFF);
  static Color get lightGray99 => inkMuted(const Color(0xFF999999));

  static const Color grayConnction = Color(0xFF212121);
  static const Color backConnction = Color(0xFF21943d);
  static const Color buleShadw = Color(0xFFC1D9FF);
  static const Color bColor = Color(0xFFEB0000);
  static const Color lightGray2 = Color(0xFFB1B1B1);
  static const Color idGreyColor = Color(0xFFA8A6A6);
  static const Color noName = Color(0xFFC5C5C5);
  static const Color grayMouce = Color(0xFF605D5D);
  static const Color grayMouce4 = Color(0xFFA4A4A5);

  static const Color supportColor = Color(0xFFFBFBFB);
  static const Color supportBorderColor = Color(0xff0bfbfb);
  static const Color greyBorderColor = Color(0xffECECEC);
  static const Color greyColor = Color(0xFFa5a7a4);
  static const Color offWhite = Color(0xFFf9fafa);
  static const Color bgLevel = Color(0xFF0c0c30);
  static const Color levelCard = Color(0xfff76bc8);
  static const Color wealthCard = Color(0xfffeb648);
  static const Color walletCard = Color(0xffffa431);
  static const Color diamondCard = Color(0xff46afff);
  static const Color diamondBottom = Color(0xff47c9fe);
  static const Color grayMain = Color(0xFFbcbcc6);
  static const Color grayLight = Color(0xfff7f7f7);
  static Color get textColorMain => ink(const Color(0xFF343434));
  static Color get inactiveColor => ink(const Color(0xFF333333));
  static const Color vipCard = Color(0xFFfef5e6);
  static const Color vipTextCard = Color(0xFFf09a37);

  /// Admin-settable SECONDARY brand color. Now fed from the panel's
  /// `secondary_color`, which the API has always emitted and the app never
  /// read â€” this stayed frozen at the build-time navy on every palette.
  static Color secondaryColor = const Color(0xFF003FA6);

  /// Accent for the COINS/wallet surfaces (Recharge app bar, its tab bar, the
  /// refresh icon and the buy buttons). Was the fixed amber [walletCard]
  /// (0xFFffa431), which painted the entire Recharge screen gold â€” the single
  /// largest surface in the app that contradicted the panel palette, and a
  /// banned brand colour. A getter, so it tracks the panel primary.
  static Color get coinsAccent => primary;

  /// Accent for the DIAMONDS surfaces. Deliberately NOT [coinsAccent]: the two
  /// currencies have always been colour-coded apart and that is worth keeping.
  /// Panel-driven via `secondary_color` instead of the fixed [diamondCard] blue.
  static Color get diamondsAccent => secondaryColor;

  static Color whiteColor = const Color(0xFFFFFFFF);

  /// The vendor's default body ink. Routed through [ink] so it is black on a
  /// light palette and the panel's text colour on a dark one â€” this single
  /// getter is what made the room-type labels, field labels and dozens of other
  /// captions readable again without editing their call sites.
  static Color get blackColor => ink(const Color(0xFF000000));
  static Color get greyTextColor => inkMuted(const Color(0xFF707070));
  static Color yellowTextColor = const Color(0xFFFFAD38);
  static Color userContainer = const Color(0xFF534990);

  static const Color red = Color(0xFFA00539);
  static List<Color> luckyBoxGradient = [
    ColorManager.red,
    ColorManager.red,
    Colors.redAccent.withValues(alpha: 0.6),
    Colors.redAccent.withValues(alpha: 0.6),
  ];

  static Color primary = const Color(0xFFF0D060);
  static Color background = const Color(0xFF05060A);
  static Color bottomNavColor = const Color(0xFF05060A);
  static Color bottomNavActiveColor = const Color(0xFFF0D060);
  static Color bottomNavInactiveColor = const Color(0xFF9C8A52);

  /// Fixed HOME-page background band â€” THREE colours blending
  /// left-to-right (pink-purple #B763FF -> blue #5779FE -> blue-violet
  /// #5B4CFF), sampled directly off the approved reference design: it
  /// isn't a single hue fading top-to-bottom, the top band itself shifts
  /// hue ACROSS the screen. [BackgroundImgWidget] takes this as the band's
  /// own gradient and fades it vertically into white lower down (see
  /// [BackgroundImgWidget.backgroundGradient] / `_buildGradientBackground`)
  /// â€” this constant only carries the three colours, not the fade.
  /// Fixed (NOT panel-driven) and used only by [HomePage]; every other
  /// screen is unaffected.
  static const LinearGradient homeBackgroundGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFB763FF), Color(0xFF5779FE), Color(0xFF5B4CFF)],
  );

  /// Fixed HOME-page tab bar / search-icon colour â€” plain white, paired with
  /// [homeBackgroundGradient] above.
  ///
  /// The tab bar on the home page (Me/Popular/Discover/Live + the search
  /// icon beside it) used to read [headerColor], a panel-driven value the
  /// admin sets independently of this page's background. That's fine on
  /// every OTHER screen, but the home page now always paints the fixed
  /// purpleâ†’lavender gradient above regardless of what the panel says, so a
  /// panel colour picked for some other (often dark) background can land on
  /// top of it looking wrong or low-contrast. Fixed white â€” like the
  /// reference design â€” stays readable against the gradient no matter what
  /// the panel is set to. Used only by the home page's tab bar/search icon;
  /// every other screen keeps using [headerColor] untouched.
  static const Color homeHeaderTextColor = Color(0xFFFFFFFF);

  /// Muted/unselected variant of [homeHeaderTextColor] â€” same white, lower
  /// opacity, for the unselected home-page tabs.
  static Color homeHeaderTextColorMuted = const Color(0xFFFFFFFF).withValues(alpha: 0.6);

  /// Fixed "light black" (soft off-black, not the panel-driven textPrimary)
  /// for Moment post cards â€” the caption text, the username, and the "..."
  /// menu icon. Requested directly: the panel's textPrimary can land on the
  /// wrong side of the post card's plain white surface depending on what the
  /// admin has picked, so this stays a fixed, always-readable dark grey
  /// regardless.
  static const Color momentPostTextColor = Color(0xFF100F0F);

  /// Fixed brand purple gradient â€” mirrors `_kNavSelectedGradient` in
  /// layout_page.dart, now exposed here so any screen can reuse it (the
  /// Moment post card's "Say Hi" button, the Moment image-viewer's Follow
  /// button, the Status-details refresh button, etc). Fixed, NOT
  /// panel-driven â€” this is the app's own signature brand accent.
  /// Updated to the owner's latest `_kNavSelectedGradient` value (was the
  /// pink->purple 0xFFE10792/0xFFA11BF4 pair).
  static const List<Color> brandGradientColors = [
    Color(0xFFA510FB),
    Color(0xFF5204C6),
  ];
  static const List<Color> brandGradientColors1 = [
    Color(0xFFFD3E04),
    Color(0xFFFB9704),
    Color(0xFFF80404),
  ];
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: brandGradientColors,
  );
  static const LinearGradient brandGradient1 = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: brandGradientColors1,
  );
  /// Light, always-readable text/icon colour for surfaces painted with
  /// [brandGradient] (Say Hi button, add-moment posting options).
  static const Color onBrandGradient = Color(0xFFFFFFFF);

  /// Ordered bottom-nav icon URLs from the admin panel, one per tab
  /// (Home, Explore/Games, Chat, Moment/World, Profile). Each entry holds an
  /// active (selected) and inactive (unselected) URL. Empty list when the panel
  /// shipped no icons â€” the nav bar then falls back to the bundled generic set.
  /// Populated from the colors response and the Hive cache on cold start.
  static List<NavIconUrls> navIcons = const [];

  /// The panel URLs for a given nav tab index, or null when the panel shipped no
  /// icon for that tab (caller falls back to the bundled generic asset). A URL
  /// being '' (state unset) is treated as absent for that state.
  static NavIconUrls? navIconAt(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= navIcons.length) return null;
    final icon = navIcons[tabIndex];
    if (icon.active.isEmpty && icon.inactive.isEmpty) return null;
    return icon;
  }

  /// Panel-driven background descriptor for the bottom-nav region
  /// (`regions.nav`). Null when the panel shipped no region â€” both nav bars then
  /// fall back to the legacy single-color derived gradient. Populated from the
  /// colors response and the Hive cache on cold start.
  static RegionBackgroundData? navRegion;

  /// Panel-driven background descriptor for the body region (`regions.body`).
  /// Stored for the upcoming body wiring; parsed/cached now for completeness.
  static RegionBackgroundData? bodyRegion;

  /// Per-color gradient tokens (`{key}_grad`), one per panel color that the
  /// backend dual-emits. Keyed by the flat color key. A `solid` token (or an
  /// absent key) leaves the matching flat static (e.g. [primary], [iconColor])
  /// as the only source; a `gradient` token feeds the gradient getters below.
  /// Populated from the colors response and the Hive cache on cold start.
  static ColorTokenData? primaryColorToken;
  static ColorTokenData? headerColorToken;
  static ColorTokenData? buttonTextColorToken;
  static ColorTokenData? textPrimaryColorToken;
  static ColorTokenData? textSecondaryColorToken;
  static ColorTokenData? iconColorToken;
  static ColorTokenData? cardColorToken;

  /// The app body's background as a [LinearGradient], for surfaces that want to
  /// blend into the page instead of sitting on a flat card (the "more rooms"
  /// room cards). Sourced from the panel body region (`regions.body`) when it is
  /// a renderable gradient/color, so it matches the scaffold background exactly;
  /// otherwise it degrades to a derived gradient over the [background] color.
  ///
  /// Honors the body region's saved `direction`/`reverse` (the round-trip fix):
  /// a horizontal/diagonal panel gradient now renders along that axis instead of
  /// the old hardcoded top->bottom. Return type stays [LinearGradient] so the
  /// existing call sites (countries_dialog / exit_panel / theme2 profile) are
  /// untouched; a `radial` body region degrades to its axis-equivalent linear
  /// here (radial is handled by [buildRegionGradient] for the region painters).
  static LinearGradient get bodyBackgroundGradient {
    final region = bodyRegion;
    if (region != null && region.isRenderable && region.type != 'image') {
      final colors = region.colors
          .map(Methods.safeHexColor)
          .whereType<Color>()
          .toList(growable: false);
      final (begin, end) =
      gradientAlignment(region.direction, region.reverse);
      if (colors.length >= 2) {
        return LinearGradient(begin: begin, end: end, colors: colors);
      }
      if (colors.length == 1) {
        return LinearGradient(
          begin: begin,
          end: end,
          colors: [colors.first, colors.first],
        );
      }
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [background, background.withValues(alpha: 0.85)],
    );
  }

  // â”€â”€â”€ Gradient direction â†’ alignment (panel/back enum, single source) â”€â”€â”€â”€â”€â”€â”€
  // The panel/back enum is: vertical | horizontal | diagonal_down | diagonal_up
  // | radial. This is THE one place the enum maps to Flutter alignments so the
  // region painter, the body gradient and every per-color token getter all draw
  // along the exact axis the owner saved (fixing the round-trip bug where the
  // saved direction was dropped and everything rendered top->bottom).

  /// The (begin, end) alignment pair for a saved [direction], with [reverse]
  /// swapping the two ends. Unknown directions (and `radial`, which has no
  /// begin/end notion) default to the vertical top->bottom axis â€” callers that
  /// can render a true radial use [buildRegionGradient] instead.
  static (Alignment begin, Alignment end) gradientAlignment(
      String direction,
      bool reverse,
      ) {
    final Alignment begin;
    final Alignment end;
    switch (direction) {
      case 'horizontal':
        begin = Alignment.centerLeft;
        end = Alignment.centerRight;
        break;
      case 'diagonal_down':
        begin = Alignment.topLeft;
        end = Alignment.bottomRight;
        break;
      case 'diagonal_up':
        begin = Alignment.bottomLeft;
        end = Alignment.topRight;
        break;
      case 'vertical':
      case 'radial':
      default:
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
        break;
    }
    return reverse ? (end, begin) : (begin, end);
  }

  /// Build the panel gradient for [colors] along [direction]. Returns a
  /// [RadialGradient] for `radial` (where [reverse] reverses the color order,
  /// since a radial has no begin/end to swap) and a [LinearGradient] otherwise.
  /// Callers pass already-parsed [Color]s (>= 1); a single color is duplicated so
  /// the gradient is always valid.
  static Gradient buildRegionGradient(
      List<Color> colors,
      String direction,
      bool reverse,
      ) {
    final stops = colors.length == 1 ? [colors.first, colors.first] : colors;
    if (direction == 'radial') {
      return RadialGradient(
        colors: reverse ? stops.reversed.toList(growable: false) : stops,
      );
    }
    final (begin, end) = gradientAlignment(direction, reverse);
    return LinearGradient(begin: begin, end: end, colors: stops);
  }

  // â”€â”€â”€ Per-color {key}_grad gradient getters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Each getter returns a [Gradient] ONLY when the matching panel token is a
  // real multi-stop gradient; otherwise null so the caller paints the existing
  // flat static (.primary, .surfaceCardColor, ...) as the solid fallback. This
  // is additive â€” the flat statics are untouched, so the hundreds of existing
  // call sites keep working unchanged and only gradient-aware surfaces opt in.

  static Gradient? _tokenGradient(ColorTokenData? token) {
    if (token == null || !token.isGradient) return null;
    final colors = token.colors
        .map(Methods.safeHexColor)
        .whereType<Color>()
        .toList(growable: false);
    if (colors.length < 2) return null;
    return buildRegionGradient(colors, token.direction, token.reverse);
  }

  /// Gradient for the brand/primary color (`app_primary_color_grad`) â€” for
  /// primary CTA buttons/FABs. Null when the panel set a solid color (use
  /// [primary]).
  static Gradient? get primaryGradient => _tokenGradient(primaryColorToken);
  static bool get primaryIsGradient => primaryColorToken?.isGradient ?? false;

  /// Gradient for the header/top-bar color (`text_header_color_grad`). Null when
  /// solid (use [headerColor]).
  static Gradient? get headerGradient => _tokenGradient(headerColorToken);
  static bool get headerIsGradient => headerColorToken?.isGradient ?? false;

  /// Gradient for the button-text color (`button_text_color_grad`). Null when
  /// solid (use [buttonTextColor]).
  static Gradient? get buttonTextGradient =>
      _tokenGradient(buttonTextColorToken);
  static bool get buttonTextIsGradient =>
      buttonTextColorToken?.isGradient ?? false;

  /// Gradient for the primary text color (`text_primary_color_grad`). Null when
  /// solid (use [textPrimary]).
  static Gradient? get textPrimaryGradient =>
      _tokenGradient(textPrimaryColorToken);
  static bool get textPrimaryIsGradient =>
      textPrimaryColorToken?.isGradient ?? false;

  /// Gradient for the secondary text color (`text_secondary_color_grad`). Null
  /// when solid (use [secondaryText]).
  static Gradient? get textSecondaryGradient =>
      _tokenGradient(textSecondaryColorToken);
  static bool get textSecondaryIsGradient =>
      textSecondaryColorToken?.isGradient ?? false;

  /// Gradient for the monochrome-icon tint (`icon_color_grad`). Null when solid
  /// (use [iconColor]).
  static Gradient? get iconGradient => _tokenGradient(iconColorToken);
  static bool get iconIsGradient => iconColorToken?.isGradient ?? false;

  /// Gradient for the elevated-card surface (`card_color_grad`) â€” for cards that
  /// should fade across instead of a flat fill. Null when solid (use
  /// [surfaceCardColor]).
  static Gradient? get cardGradient => _tokenGradient(cardColorToken);
  static bool get cardIsGradient => cardColorToken?.isGradient ?? false;

  /// A [BoxDecoration] for an ELEVATED card that paints the panel
  /// [cardGradient] when the owner saved a `card_color_grad` gradient and falls
  /// back to the flat [surfaceCardColor] otherwise. Centralizes the
  /// "BoxDecoration rejects both color and gradient" rule (color is null while a
  /// gradient is present) so every card surface renders the panel gradient with
  /// the exact colors/order/direction/reverse the owner saved, or the flat
  /// color (never white) when the token is solid/absent.
  static BoxDecoration cardDecoration({
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    BoxShape shape = BoxShape.rectangle,
  }) {
    final gradient = cardGradient;
    return BoxDecoration(
      color: gradient == null ? surfaceCardColor : null,
      gradient: gradient,
      borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
      border: border,
      boxShadow: boxShadow,
      shape: shape,
    );
  }

  /// A [BoxDecoration] for a PRIMARY accent/CTA surface that paints the panel
  /// [primaryGradient] when the owner saved an `app_primary_color_grad` gradient
  /// (including a `radial`) and falls back to the flat [primary] otherwise.
  /// Same color XOR gradient rule as [cardDecoration].
  static BoxDecoration primaryDecoration({
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    BoxShape shape = BoxShape.rectangle,
  }) {
    final gradient = primaryGradient;
    return BoxDecoration(
      color: gradient == null ? primary : null,
      gradient: gradient,
      borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
      border: border,
      boxShadow: boxShadow,
      shape: shape,
    );
  }

  /// Restore the cached `{key}_grad` tokens (compact form) so the gradients apply
  /// on cold start before the colors response returns. A null/blank cache entry
  /// leaves the token null so the matching flat color is used as the solid
  /// fallback.
  static void restoreCachedColorTokens() {
    primaryColorToken = ColorTokenData.decode(HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.PRIMARY_GRAD_KEY));
    headerColorToken = ColorTokenData.decode(HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.HEADER_GRAD_KEY));
    buttonTextColorToken = ColorTokenData.decode(HiveManager().getData<String>(
        KeysManager.USER_BOX, KeysManager.BUTTON_TEXT_GRAD_KEY));
    textPrimaryColorToken = ColorTokenData.decode(HiveManager().getData<String>(
        KeysManager.USER_BOX, KeysManager.TEXT_PRIMARY_GRAD_KEY));
    textSecondaryColorToken = ColorTokenData.decode(HiveManager()
        .getData<String>(
        KeysManager.USER_BOX, KeysManager.TEXT_SECONDARY_GRAD_KEY));
    iconColorToken = ColorTokenData.decode(HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.ICON_GRAD_KEY));
    cardColorToken = ColorTokenData.decode(HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.CARD_GRAD_KEY));
  }

  /// Restore the cached region backgrounds (compact `type|image|colors` form) so
  /// the regions apply on cold start before the colors response returns.
  static void restoreCachedRegions() {
    navRegion = RegionBackgroundData.decode(
      HiveManager()
          .getData<String>(KeysManager.USER_BOX, KeysManager.NAV_REGION_KEY),
    );
    bodyRegion = RegionBackgroundData.decode(
      HiveManager()
          .getData<String>(KeysManager.USER_BOX, KeysManager.BODY_REGION_KEY),
    );
  }

  /// Restore the panel nav-icon URLs from the Hive cache (list of
  /// "active|inactive" strings) so the bar shows the custom icons on cold start
  /// before the colors response returns. No-op when nothing was cached.
  static void restoreCachedNavIcons() {
    final cached = HiveManager()
        .getData<List>(KeysManager.USER_BOX, KeysManager.NAV_ICON_URLS_KEY);
    if (cached == null) return;
    navIcons = cached.map<NavIconUrls>((e) {
      final parts = '$e'.split('|');
      return NavIconUrls(
        active: parts.isNotEmpty ? parts[0] : '',
        inactive: parts.length > 1 ? parts[1] : '',
      );
    }).toList(growable: false);
  }

  static Color headerColor = const Color(0xFF05060A);
  static Color buttonTextColor = const Color(0xFF14110A);

  /// Admin-settable tint for monochrome ICONS (top-bar search/trophy, discover
  /// filter arrow, profile feature-icon assets, search-field icon). Defaults to
  /// the brand dark â€” NEVER white â€” so a missing panel value renders visible
  /// icons on the light surfaces instead of invisible white-on-white ones.
  /// Driven from the colors response and re-hydrated from Hive on cold start.
  static Color iconColor = const Color(0xFF05060A);

  /// Admin-settable surface color for ELEVATED cards (the "more rooms" room
  /// cards in the exit sheet, the profile feature grids & info cards). A tier
  /// distinct from [background] (the page fill): a card painted with the page
  /// color would visually merge into the page. Defaults to white to preserve the
  /// current look; the owner sets a dark surface from the panel for dark
  /// palettes. Driven from the colors response and re-hydrated from Hive on cold
  /// start. NOTE: separate from the legacy const [cardColor] (a fixed CP brand
  /// blue) which is NOT panel-driven.
  static Color surfaceCardColor = const Color(0xFFFFFFFF);

  // â”€â”€â”€ Text colour â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // IM PARTY is a LIGHT app. The panel's `is_dark_mode_enabled` flag is
  // deliberately not read here: there is no dark variant to switch to, so a
  // stray row in the database cannot flip the app's ink to white and blank the
  // whole UI. The palette still comes from the panel â€” it just has to be a
  // light one, and [ink]/[inkMuted] verify that per shade.

  static bool get isEnabled =>
      HiveManager().getData<bool>(
        KeysManager.USER_BOX,
        KeysManager.IS_BODY_THEME_ENABLED_KEY,
      ) ??
          false;

  /// Admin-settable primary text color. When unset (null) the adaptive
  /// black/white default below is preserved so the current look is unchanged.
  static Color? _primaryTextOverride;
  static set primaryText(Color color) => _primaryTextOverride = color;

  /// Admin-settable secondary/subtitle text color.
  static Color secondaryText = const Color(0xFF707070);

  /// Text that sits on a FIXED dark surface (level cards, dark gradients, media
  /// overlays). Stays white regardless of the admin primary/secondary text
  /// colors so it never becomes invisible on a light custom palette. NOT
  /// admin-driven by design.
  static const Color onDark = Color(0xFFFFFFFF);

  /// Text colour â€” the panel's value when it set one, otherwise black. Never
  /// white: this app has no dark mode.
  static Color get textPrimary => _primaryTextOverride ?? black;

  /// The page fill for surfaces that used to switch with dark mode. Always the
  /// light one now.
  static Color get backgroundDarkLight => white;

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // â”€â”€â”€ Theme2 App Colors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Color theme2BgDark = Color(0xFF141230);
  static const Color theme2BgMedium = Color(0xFF1B1840);
  static const Color theme2CardBg = Color(0xFF1E1A3A);
  static const Color theme2CardBorder = Color(0xFF2D2755);
  static const Color theme2Accent = Color(0xFF8B5CF6);
  static const Color theme2AccentLight = Color(0xFFA78BFA);
  static const Color theme2PartyBadge = Color(0xFF9333EA);
  static const Color theme2TabActive = Color(0xFFFF6B35);

  // â”€â”€â”€ Theme2 text colors â€” panel-driven (was hardcoded white/grey) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // These three were the root of nearly every white element on the theme_2
  // surfaces (top tabs, room names, party/visitor labels, sub-tabs). They are
  // now getters bound to the admin text palette so a custom panel palette
  // recolors them everywhere at once. They remain non-const on purpose.
  //
  // theme2TextPrimary  -> primary body text   (admin text_primary_color)
  // theme2TextSecondary-> secondary/subtitle  (admin text_secondary_color)
  // theme2TabInactive  -> unselected tab label (admin text_secondary_color)
  static Color get theme2TextPrimary => textPrimary;
  static Color get theme2TextSecondary => secondaryText;
  static Color get theme2TabInactive => secondaryText;
  static const Color theme2FilterBg = Color(0xFF2A2650);
  static const Color theme2FilterActive = Color(0xFF7C3AED);
  static const Color theme2GradientStart = Color(0xFF8B5CF6);
  static const Color theme2GradientEnd = Color(0xFFFF6B35);
  static const Color theme2BannerBg = Color(0xFF251F4A);
  static const Color theme2CreateRoomBg = Color(0xFF7C6FEE);
  static const Color theme2GameCardBg1 = Color(0xFF2563EB);
  static const Color theme2GameCardBg2 = Color(0xFFD97706);
  static const Color theme2GameCardBg3 = Color(0xFFEC4899);
  static const Color theme2GameCardBg4 = Color(0xFF059669);
  static const Color theme2SignalBars = Color(0xFFFF4444);

  static const List<Color> theme2BgGradient = [
    Color(0xFF141230),
    Color(0xFF1B1840),
    Color(0xFF141230),
  ];

  static const List<Color> theme2TabGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFFD746),
  ];

  static const List<Color> theme2AccentGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF6D28D9),
  ];
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static LinearGradient gradientLinearTabBar(Color base) {
    const middleYellow = Color(0xFFF7FFBC);

    return LinearGradient(
      colors: [
        base,
        middleYellow,
        base.withValues(alpha: 0.5),
      ],
      begin: AlignmentDirectional.centerEnd,
      end: AlignmentDirectional.centerStart,
    );
  }
}

/// Active/inactive bottom-nav icon URLs for one tab, sourced from the admin
/// panel. A lightweight holder kept here so [ColorManager] stays free of any
/// feature-layer import.
class NavIconUrls {
  final String active;
  final String inactive;

  const NavIconUrls({this.active = '', this.inactive = ''});
}
