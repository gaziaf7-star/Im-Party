import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/agency_ui.dart';

/// One tappable Agency Center row as a white card: tinted icon tile, title,
/// trailing content (avatars, text...) and a chevron.
class CustomRowWidget extends StatelessWidget {
  final Widget child;
  final String title;
  final Color? color;
  final bool? isNeedArrow;
  final dynamic iconName;
  final void Function()? onTap;
  final double? scale;

  const CustomRowWidget({
    super.key,
    required this.child,
    required this.title,
    required this.onTap,
    this.scale,
    this.color,
    this.isNeedArrow = true,
    required this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    return AgencyCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: (color ?? ColorManager.primary).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: (iconName is String)
                ? Image.asset(
                    iconName,
                    color: color,
                    fit: BoxFit.contain,
                  )
                : iconName,
          ),
          10.wBox,
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AgencyUI.ink,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          8.wBox,
          const Spacer(),
          DefaultTextStyle.merge(
            style: TextStyle(color: AgencyUI.muted, fontSize: 12.sp),
            child: child,
          ),
          if (isNeedArrow == true) ...[
            4.wBox,
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AgencyUI.muted,
            ),
          ],
        ],
      ),
    );
  }
}
