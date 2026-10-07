part of 'package:general/src/features/profile/presentation/levels/view/level_page.dart';

class BottomCard extends StatelessWidget {
  const BottomCard({super.key, required this.isSender});

  final bool isSender;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      padding: context.paddingAll(15),
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: 10.radiusCircular,
          topRight: 10.radiusCircular,
        ),
        color: ColorManager.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UserImage(
            image: MyDataModel.getInstance().profile?.image ?? '',
            displayName: MyDataModel.getInstance().name ?? '',
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: 170.radius,
            imageSize: 60.w,
          ),
          10.wBox,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<MyStoreBloc, MyStoreState>(
                bloc: di<MyStoreBloc>(),
                buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                builder: (context, state) {
                  return TextWidget(
                    '${isSender?state.myStore?.coins:state.myStore?.diamonds}',
                    style: context.bodyLarge.colorExt(ColorManager.textPrimary),
                  );
                },
              ),
              10.hBox,
              Row(
                children: [
                  TextWidget(
                      " ${isSender ? MyDataModel.getInstance().level?.nextSenderLevel : MyDataModel.getInstance().level?.nextReciverLevel}",
                      style: context.bodySmall.colorExt(ColorManager.gold3)),
                  5.wBox,
                  TextWidget(StringManager.nextTo.tr(),
                      style: context.bodySmall.colorExt(ColorManager.textPrimary)),
                ],
              ),
            ],
          ),
          // IdWithCopyIcon(
          //   userData: MyDataModel.getInstance().convertMyDataEntityToUserEntity(MyDataModel.getInstance()),
          // ),
          // Padding(
          //   padding: context.paddingSymmetric(horizontal: 20),
          //   child: Column(
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           TextWidget(
          //             '${StringManager.level} ${MyDataModel.getInstance().level?.senderLevel ?? ''}',
          //             style: const TextStyle(color: ColorManager.black,),
          //           ),
          //
          //         ],
          //       )
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
