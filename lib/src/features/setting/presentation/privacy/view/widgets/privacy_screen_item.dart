part of 'package:general/src/features/setting/presentation/privacy/view/privacy_screen.dart';

class PrivacyScreenItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool currentValue;
  final void Function(bool) onChanged;

  const PrivacyScreenItem({
    super.key,
    required this.title,
    required this.subTitle,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingOnly(start: 5, end: 5, bottom: 10),
      margin: context.paddingSymmetric(vertical: 1, horizontal: 5.w),
      decoration: BoxDecoration(
          borderRadius: 8.radius, color: ColorManager.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextWidget(
                title,
                style: context.bodyLarge.w600.colorExt(ColorManager.black),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: currentValue,
                  onChanged: onChanged,
                  activeThumbColor: ColorManager.white,
                  inactiveThumbColor: ColorManager.white,
                  activeTrackColor: ColorManager.primary,
                  inactiveTrackColor: ColorManager.gray,
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return ColorManager.white;
                        }
                        return ColorManager.white; // Use the default color.
                      }),
                ),
              ),
            ],
          ),
          TextWidget(
            subTitle,
            style: context.bodySmall.colorExt(ColorManager.black.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}