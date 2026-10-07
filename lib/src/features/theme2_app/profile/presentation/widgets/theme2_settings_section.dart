import 'package:general/src/core/index.dart';

class Theme2SettingsSection extends StatelessWidget {
  const Theme2SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: ColorManager.cardDecoration(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          // Customer service (خدمة العملاء) moved to grid section next to invite friends
          // Block list (قائمة الحظر) — KEEP (not duplicate)
          _SettingsItem(
            icon: Icons.lock_outline,
            title: StringManager.blockList.tr(),
            onTap: () => context.pushNamedRoute(Routes.blockListScreen),
          ),
          _divider(),
          _SettingsItem(
            icon: Icons.info_outline,
            title: StringManager.aboutUs.tr(),
            onTap: () => context.pushNamedRoute(Routes.aboutUsPage),
          ),
          _divider(),
          _SettingsItem(
            icon: Icons.settings_outlined,
            title: StringManager.settings.tr(),
            onTap: () => context.pushNamedRoute(Routes.settingsScreen),
          ),
          // Privacy (الخصوصية/امتيازات VIP) REMOVED — duplicate of Settings > VIP Privileges
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    color: ColorManager.gray.withValues(alpha: 0.3),
    height: 1,
    indent: 56.w,
  );
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: ColorManager.black.withValues(alpha: 0.6),
            ),
            12.wBox,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: ColorManager.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: ColorManager.greyText,
            ),
          ],
        ),
      ),
    );
  }
}
