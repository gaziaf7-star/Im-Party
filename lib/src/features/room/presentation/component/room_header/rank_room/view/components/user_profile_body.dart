part of 'package:general/src/features/room/presentation/component/room_header/rank_room/view/rank_room_page.dart';

class _UserProfileBody extends StatelessWidget {
  final String exp;
  final int index;
  const _UserProfileBody({required this.exp, required this.index});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 80.h,
      padding: context.paddingSymmetric(horizontal: 20),
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: 20.radiusCircular,
          topLeft: 20.radiusCircular,
        ),
        color: ColorManager.userContainer
      ),
      child: Row(
        children: [
          TextWidget(
            'NO',
            style: context.bodyMedium.bold.colorExt(ColorManager.textPrimary),
          ),
          8.wBox,
          UserImage(
            borderRadius: 20.radius,
            displayName: MyDataModel.getInstance().name ?? '',
            image: MyDataModel.getInstance().profile?.image ?? '',imageSize: 40,),
          10.wBox,
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 140.w,minWidth: 5.w),
            child: TextWidget(
              MyDataModel.getInstance().name ?? '',
              style: context.bodyMedium.bold.copyWith(
                color: ColorManager.white
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 70.w,minWidth: 5.w),
                    child: TextWidget(exp,overflow: TextOverflow.ellipsis,maxLines: 1,style: context.bodyMedium.copyWith(
                      color: ColorManager.white
                    ),)),
                2.5.wBox,
                Image.asset(
                  index == 0 ? AssetsManager.fire2 : AssetsManager.fire2,
                  scale: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
