import 'package:general/src/core/index.dart';

class LightTheme {
  // IM PARTY is a light app, so Material's brightness is fixed rather than
  // derived. Leaving it derived would mean a panel row could turn the page dark
  // and take every dialog, menu and scrollbar with it â€” which is the switch this
  // product does not want to have.

  /// Built fresh on each access so it reflects the CURRENT [ColorManager]
  /// values (admin/panel overrides applied at runtime). A `static final`
  /// froze the ThemeData at first access, ignoring later panel colors.
  static ThemeData get theme => ThemeData(
    fontFamily: "AppFont",
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light().copyWith(
      primary: ColorManager.primary,
      secondary: ColorManager.secondaryColor,
      surface: ColorManager.surfaceCardColor,
      onSurface: ColorManager.textPrimary,
      onPrimary: ColorManager.buttonTextColor,
    ),
    scaffoldBackgroundColor: ColorManager.offWhite,
    // Anything that does not paint its own fill lands on the panel card colour
    // instead of Material's white, so its text (now the panel ink) reads.
    canvasColor: ColorManager.surfaceCardColor,
    dialogTheme: DialogThemeData(
      backgroundColor: ColorManager.surfaceCardColor,
      surfaceTintColor: ColorManager.transparent,
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'AppFont',
        color: ColorManager.textPrimary,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14.sp,
        fontFamily: 'AppFont',
        color: ColorManager.textPrimary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ColorManager.surfaceCardColor,
      surfaceTintColor: ColorManager.transparent,
      modalBackgroundColor: ColorManager.surfaceCardColor,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: ColorManager.surfaceCardColor,
      surfaceTintColor: ColorManager.transparent,
      textStyle: TextStyle(
        fontSize: 14.sp,
        fontFamily: 'AppFont',
        color: ColorManager.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: ColorManager.surfaceCardColor,
      surfaceTintColor: ColorManager.transparent,
    ),
    listTileTheme: ListTileThemeData(
      textColor: ColorManager.textPrimary,
      iconColor: ColorManager.textPrimary,
    ),
    iconTheme: IconThemeData(color: ColorManager.textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorManager.black,
      surfaceTintColor: ColorManager.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorManager.bottomNavColor,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: ColorManager.textPrimary,
        fontFamily: 'AppFont',
        fontFamilyFallback: const ['SegoeUI', 'sans-serif'],
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        color: ColorManager.textPrimary,
        fontFamily: 'AppFont',
        fontFamilyFallback: const ['SegoeUI', 'sans-serif'],
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        color: ColorManager.textPrimary,
        fontFamily: 'AppFont',
        fontFamilyFallback: const ['SegoeUI', 'sans-serif'],
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        color: ColorManager.textPrimary.withValues(alpha: 0.60),
        fontFamily: 'AppFont',
        fontFamilyFallback: const ['SegoeUI', 'sans-serif'],
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      // Hint and label were Material's default black-on-light; on the panel's
      // dark field fill they vanished. Bound to the panel text palette.
      hintStyle: TextStyle(
        fontFamily: 'AppFont',
        color: ColorManager.secondaryText,
      ),
      labelStyle: TextStyle(
        fontFamily: 'AppFont',
        color: ColorManager.secondaryText,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: 'AppFont',
        color: ColorManager.textPrimary,
      ),
      fillColor: ColorManager.grayLight.withValues(alpha: 0.7),
      enabledBorder: OutlineInputBorder(
        borderRadius: 30.radius,
        borderSide: const BorderSide(
          width: 1.5,
          color: ColorManager.transparent,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: 30.radius,
        borderSide: const BorderSide(
          width: 1.5,
          color: ColorManager.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: 30.radius,
        borderSide: BorderSide(
          width: 1.5,
          color: ColorManager.grayLight.withValues(alpha: 0.7),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: 30.radius,
        borderSide: const BorderSide(
          color: ColorManager.redAccount,
          width: 1.5,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ColorManager.grey,
      thickness: 1.0,
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide.none,
      fillColor: const WidgetStatePropertyAll(ColorManager.checkBoxColor),
      checkColor: WidgetStatePropertyAll(
        ColorManager.inkOn(ColorManager.checkBoxColor),
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: 10.5.radius,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

