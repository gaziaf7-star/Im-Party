import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/reels_upload_request.dart';

/// Theme2 Bottom Navigation Bar - matches the Theme2/Hiya Live design from screenshots.
/// Uses Theme2 dark theme with proper active/inactive icons from AssetsManager.
class Theme2BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Theme2BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Index mapping, kept consistent with Theme2LayoutPage._pageBuilders:
  ///   [Home, (Moment if isShowMoment), (Reels if isReelsVisible), Chat, Profile]
  /// In RTL the first child renders rightmost, so Chat (right after Reels) shows
  /// to the LEFT of the centered Reels.
  int get _momentIndex => ConstantsManager.isShowMoment ? 1 : -1;
  int get _reelsIndex {
    if (!ConstantsManager.isReelsVisible) return -1;
    return ConstantsManager.isShowMoment ? 2 : 1;
  }

  int get _chatIndex {
    var index = 1;
    if (ConstantsManager.isShowMoment) index++;
    if (ConstantsManager.isReelsVisible) index++;
    return index;
  }

  int get _profileIndex => _chatIndex + 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.2, color: ColorManager.grey),
        ),
      ),
      // Panel-driven nav region background when present; otherwise the legacy
      // single-color derived gradient so existing clients look identical.
      child: RegionBackground(
        descriptor: ColorManager.navRegion,
        fallback: (_) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: GradientHelper.buildGradientFromBottomColor(
              ColorManager.bottomNavColor,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
          children: [
            // Home (panel nav-icon index 0)
            _buildNavItem(
              context: context,
              tabIndex: 0,
              fallbackIcon: AssetsManager.icHome,
              label: StringManager.home.tr(),
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            // Moment (if enabled) - placed before Reels (panel nav-icon index 3)
            if (ConstantsManager.isShowMoment)
              _buildNavItem(
                context: context,
                tabIndex: 3,
                fallbackIcon: AssetsManager.icWorld,
                label: StringManager.moment.tr(),
                isSelected: currentIndex == _momentIndex,
                onTap: () => onTap(_momentIndex),
              ),
            // Reels (if enabled) — stays centered. TikTok style: while the
            // user is ALREADY on the Reels tab the item morphs into a "+"
            // (upload a video); otherwise it is the normal Reels icon/tab.
            // Reels is NOT a panel-driven nav tab, so it keeps the bundled
            // generic reel asset.
            if (ConstantsManager.isReelsVisible)
              currentIndex == _reelsIndex
                  ? _buildUploadItem(context)
                  : _buildNavItem(
                      context: context,
                      tabIndex: -1,
                      fallbackIcon: AssetsManager.icReel,
                      label: StringManager.reels.tr(),
                      isSelected: false,
                      onTap: () => onTap(_reelsIndex),
                    ),
            // Chat (immediately after Reels -> left of Reels in RTL)
            // (panel nav-icon index 2)
            _buildNavItem(
              context: context,
              tabIndex: 2,
              fallbackIcon: AssetsManager.icBubble,
              label: StringManager.watsJo.tr(),
              isSelected: currentIndex == _chatIndex,
              onTap: () => onTap(_chatIndex),
            ),
            // Profile (panel nav-icon index 4)
            _buildNavItem(
              context: context,
              tabIndex: 4,
              fallbackIcon: AssetsManager.icProfile,
              label: StringManager.mine.tr(),
              isSelected: currentIndex == _profileIndex,
              onTap: () => onTap(_profileIndex),
            ),
          ],
          ),
        ),
      ),
    );
  }

  /// The TikTok-style "+" shown in the Reels slot while the Reels tab is
  /// active — tapping it opens the upload flow (via [reelsUploadRequest]).
  Widget _buildUploadItem(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => reelsUploadRequest.value++,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 42.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: ColorManager.bottomNavActiveColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.add,
                color: ColorManager.bottomNavColor, size: 22.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int tabIndex,
    required String fallbackIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavBarIcon(
              tabIndex: tabIndex,
              isSelected: isSelected,
              fallbackAsset: fallbackIcon,
              size: 26.h,
            ),
            3.hBox,
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? ColorManager.bottomNavActiveColor
                    : ColorManager.bottomNavInactiveColor,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
