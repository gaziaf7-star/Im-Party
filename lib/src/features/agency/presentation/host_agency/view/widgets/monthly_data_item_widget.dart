import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/agency_ui.dart';

/// Stat card (Profits, Diamond, On-mic time...): label + value on the left,
/// the stat's icon in a tinted tile on the right.
class MonthlyDataItemWidget extends StatelessWidget {
  final String title;
  final String? subTitle;
  final dynamic icon;
  final dynamic subIcon;
  final String? value;
  final Color textColor;
  final double? scale;
  final void Function()? onTap;

  const MonthlyDataItemWidget({
    super.key,
    required this.title,
    this.value,
    this.onTap,
    this.subTitle,
    this.scale,
    this.subIcon,
    required this.icon,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AgencyCard(
        onTap: onTap,
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 10.w, 12.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AgencyUI.muted,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (subIcon != null)
                        SizedBox(height: 22.h, child: subIcon),
                    ],
                  ),
                  4.hBox,
                  SizedBox(
                    height: 26.h,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      // Value stays black like its label (on request).
                      child: Text(
                        value ?? '0',
                        style: TextStyle(
                          color: AgencyUI.ink,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            6.wBox,
            Container(
              width: 40.w,
              height: 40.w,
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: (icon is String)
                  ? Image.asset(icon, fit: BoxFit.contain)
                  : icon,
            ),
          ],
        ),
      ),
    );
  }
}
