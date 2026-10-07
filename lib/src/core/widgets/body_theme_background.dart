import 'package:general/src/core/index.dart';

class BodyThemeBackground extends StatelessWidget {
  const BodyThemeBackground({super.key});

  /// Everything below reads STATIC state — ColorManager regions and the Hive
  /// body-theme keys — none of which is part of this widget's identity. Callers
  /// construct it as `const BodyThemeBackground()`, so Flutter canonicalises the
  /// instance and skips the subtree when the parent rebuilds: the background
  /// painted whatever was available on the very first frame and never updated.
  ///
  /// That is why the header kept the cold-start gradient derived from
  /// app_primary_color while the bottom bar — built later — picked up the
  /// panel's nav region. Listening to the same notifiers the app shell uses
  /// makes the repaint happen wherever this widget is embedded.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ConstantsManager.colorsNotifier,
        ConstantsManager.bodyThemeNotifier,
      ]),
      builder: (context, _) => _buildBackground(context),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final themeType = HiveManager().getData<String>(
          KeysManager.USER_BOX,
          KeysManager.BODY_THEME_TYPE_KEY,
        ) ??
        '';

    if (themeType == 'image') {
      final image = HiveManager().getData<String>(
            KeysManager.USER_BOX,
            KeysManager.BODY_THEME_IMAGE_KEY,
          ) ??
          '';
      if (image.isNotEmpty) {
        return ImageViewWidget(
          url: image,
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          boxFit: BoxFit.cover,
        );
      }
    } else if (themeType == 'color') {
      final colorHex = HiveManager().getData<String>(
            KeysManager.USER_BOX,
            KeysManager.BODY_THEME_COLOR_KEY,
          ) ??
          '';
      final color = Methods.safeHexColor(colorHex);
      if (color != null) {
        return Container(color: color);
      }
    } else if (themeType == 'gradient') {
      final g1 = HiveManager().getData<String>(
            KeysManager.USER_BOX,
            KeysManager.BODY_THEME_GRADIENT_ONE_KEY,
          ) ??
          '';
      final g2 = HiveManager().getData<String>(
            KeysManager.USER_BOX,
            KeysManager.BODY_THEME_GRADIENT_TWO_KEY,
          ) ??
          '';
      final g3 = HiveManager().getData<String>(
            KeysManager.USER_BOX,
            KeysManager.BODY_THEME_GRADIENT_THREE_KEY,
          ) ??
          '';
      final gradientColors = [
        Methods.safeHexColor(g1),
        Methods.safeHexColor(g2),
        Methods.safeHexColor(g3),
      ].whereType<Color>().toList();
      if (gradientColors.length >= 2) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
        );
      }
      // Gradient invalid (fewer than 2 valid colors): fall back to the body
      // theme color before the generic ColorManager.primary fallback below.
      final bodyColor = Methods.safeHexColor(
        HiveManager().getData<String>(
          KeysManager.USER_BOX,
          KeysManager.BODY_THEME_COLOR_KEY,
        ),
      );
      if (bodyColor != null) {
        return Container(color: bodyColor);
      }
    }

    // No body theme configured: paint the panel's BODY region as the page fill
    // and the panel's NAV region as a faded band at the top — exactly what
    // BackgroundImgWidget draws for the non-body-theme path.
    //
    // This widget used to stretch the NAV wash over the WHOLE screen, so with a
    // body theme on you got the header colours bleeding down the entire page and
    // with it off you got a different top from every other screen. Splitting the
    // two regions makes both paths render the same header and keeps each panel
    // region doing the job it is named for.
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: ColorManager.bodyBackgroundGradient,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: GradientHelper.headerBandHeight,
          child: GradientHelper.buildHeaderBackdrop(ColorManager.navRegion),
        ),
      ],
    );
  }
}
