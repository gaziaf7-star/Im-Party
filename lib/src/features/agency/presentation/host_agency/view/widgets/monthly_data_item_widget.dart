import 'package:general/src/core/index.dart';

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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: context.paddingAll(10),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: 8.radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: (0.8)), // Shadow color
                // offset: const Offset(1, 1), // Shadow offset (x, y)
                // blurRadius: 1, // Spread of the shadow
                // spreadRadius: 1, // Intensity around the edges
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextWidget(
                        title,
                        style: context.bodyMedium
                            .size(12)
                            .colorExt(ColorManager.momentPostTextColor),
                      ),
                      subIcon ?? const SizedBox(),
                    ],
                  ),
                  SizedBox(
                    //  width: 60.w,
                    height: 30.h,
                    child: FittedBox(
                      child: TextWidget(
                        value ?? 0.toString(),
                        // Fixed black (was the per-card accent `textColor`),
                        // on request -- every card's value now matches its
                        // label instead of each stat having its own hue.
                        style: context.bodyMedium
                            .colorExt(ColorManager.momentPostTextColor)
                            .size(18),
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              (icon is String)
                  ? Image.asset(
                      icon,
                      scale: scale ?? 4,
                    )
                  : icon,
            ],
          ),
        ),
      ),
    );
  }
}
