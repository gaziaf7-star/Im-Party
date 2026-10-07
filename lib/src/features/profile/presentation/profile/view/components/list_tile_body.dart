part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

class ListTileBody extends StatelessWidget {
  const ListTileBody({super.key,
    required this.image,
    required this.title,
    required this.onTap,
    this.isVip= false,

  });
  final String image, title;
  final VoidCallback onTap;
  final bool isVip;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          12.wBox,
          Padding(
            padding: context.paddingSymmetric(horizontal: 5),
            child: ImageWidget(
              image:  image,
              height: 25.h,
              width: 34.w,
            ),
          ),


          TextWidget(
              title,
              // Fixed light-black (was textPrimary — panel-driven, can go white
              // and vanish on this white/gradient screen).
              style: context.bodyMedium.size(16).w400.colorExt(ColorManager.momentPostTextColor)
          ),
          const Spacer(),
          if (isVip)
            Container(
              padding: context.paddingSymmetric(horizontal: 12, vertical: 4),
              // Brand-tinted chip with fixed dark text (was flat primary for
              // both bg tint and text).
              decoration: BoxDecoration(
                color: ColorManager.brandGradientColors.first.withValues(alpha: 0.12),
                borderRadius:20.radius,
              ),
              child: TextWidget(
                  StringManager.becomeVip.tr(),
                  style: context.bodyMedium.w400.colorExt(ColorManager.momentPostTextColor)
              ),
            ),
          IconButton(onPressed:onTap , icon: Icon(Icons.navigate_next_sharp,color: ColorManager.momentPostTextColor.withValues(alpha: (0.4 )),))

        ],
      ),
    );
  }
}