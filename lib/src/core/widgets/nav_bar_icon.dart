import 'package:general/src/core/index.dart';

/// Renders a single bottom-nav tab icon.
///
/// The icon is driven by the admin panel: each tab ships an ACTIVE (selected)
/// and INACTIVE (unselected) image URL. The matching URL is fetched and cached
/// on the device via [CacheImageWidget]. When the panel shipped no URL for the
/// requested state, the bundled generic [fallbackAsset] is rendered instead
/// (tinted with the active/inactive nav color) so the bar is never blank.
class NavBarIcon extends StatelessWidget {
  const NavBarIcon({
    super.key,
    required this.tabIndex,
    required this.isSelected,
    required this.fallbackAsset,
    required this.size,
    this.activeColor,
    this.inactiveColor,
  });

  /// Index into the panel's ordered nav-icon list
  /// (0 Home, 1 Explore/Games, 2 Chat, 3 Moment/World, 4 Profile).
  final int tabIndex;
  final bool isSelected;

  /// Bundled generic asset used only when the panel URL for this state is empty.
  final String fallbackAsset;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final icon = ColorManager.navIconAt(tabIndex);
    final url = icon == null
        ? ''
        : (isSelected ? icon.active : icon.inactive);

    if (url.isNotEmpty) {
      return CacheImageWidget(
        url: url,
        height: size,
        width: size,
        boxFit: BoxFit.contain,
        isStopLoadingAndError: true,
      );
    }

    final tint = isSelected
        ? (activeColor ?? ColorManager.bottomNavActiveColor)
        : (inactiveColor ?? ColorManager.bottomNavInactiveColor);
    return ImageWidget(
      image: fallbackAsset,
      height: size,
      width: size,
      color: tint,
    );
  }
}
