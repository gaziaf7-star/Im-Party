
import 'package:general/src/features/games/games.dart';


class RechargeWidget extends StatelessWidget {
  const RechargeWidget({
    super.key,
    required this.quantity,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.iconWidth,
    required this.iconHeight,
    required this.onTap,
  });
  final String quantity;
  final String title;
  final String icon;
  final double iconWidth;
  final double iconHeight;
  final Gradient gradient;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        height: 65.h,
        width: 155.w,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            10.wBox,
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 5.0),
            //   child: Image.asset(
            //     icon,
            //     height: iconHeight,
            //     width: iconWidth,
            //   ),
            // ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            quantity,
                            style: context.bodyMedium.size(20).w500.colorExt(ColorManager.textPrimary),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        );
                      },
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: context.bodyMedium.size(15).w500.colorExt(ColorManager.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                           Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0.w),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: ColorManager.white,
                              size: 16,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
class RechargeWidget extends StatelessWidget {
  const RechargeWidget({
    super.key,
    required this.quantity,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.iconWidth,
    required this.iconHeight,
    required this.onTap,
  });
  final String quantity;
  final String title;
  final String icon;
  final double iconWidth;
  final double iconHeight;
  final Gradient gradient;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        height: 65.h,
        width: 160.w,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              icon,
              height: iconHeight,
              width: iconWidth,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  quantity,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    TextWidget(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.textPrimary,
                      ),
                    ),
                    10.wBox,
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: ColorManager.white,
                      size: 16,
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/