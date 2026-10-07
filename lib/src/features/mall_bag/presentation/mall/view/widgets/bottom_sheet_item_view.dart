import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

import '../../../../mall_bag.dart';

class BottomSheetItemView extends StatelessWidget {
  final MallEntity data;
  final MallOrBagType tabType;

  const BottomSheetItemView(
      {required this.data, required this.tabType, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: ScreenUtil().screenWidth,
            padding: context.paddingSymmetric(horizontal: 50),
            decoration: BoxDecoration(
              borderRadius: 10.radius,
              color: ColorManager.orange2,
            ),
            child: ImageViewWidget(
              url: data.image ?? '',
              width: 80,
              height: 180,
              boxFit: BoxFit.contain,
            ),
          ),
          5.hBox,
          Padding(
            padding: context.paddingSymmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                10.hBox,
                TextWidget(
                  (data).name.toString(),
                  style: context.bodyMedium.size(14).w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                5.hBox,
                TextWidget(
                  '${(data).price.toString()} ${StringManager.gold.tr()}/${(data).expire} ${StringManager.days.tr()}',
                  style:
                      context.bodyMedium.colorExt(ColorManager.greyTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                30.hBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      AssetsManager.coinPayment,
                      scale: 3,
                    ),
                    5.wBox,
                    FittedBox(
                      child: TextWidget(
                        (data).price.toString(),
                        style: context.bodyMedium.bold,
                      ),
                    ),
                  ],
                ),
                30.hBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      AssetsManager.coinPayment,
                      scale: 3,
                    ),
                    TextWidget((di<MyStoreBloc>().state.myStore?.coins ?? 0)
                        .toString()),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 20.h,
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 3,
                      child: MainButton(
                        title: StringManager.test.tr(),
                        isLoading: false,
                        buttonColor: ColorManager.primary,
                        onTap: () => TestItemsController.instance.onMallCardTap(
                            context,
                            TestMallBagParam(
                              image: data.image,
                              svg: data.svg,
                              type: data.imageType,
                            ),
                            tabType),
                        width: 153.w,
                        height: 47.h,
                        borderRadius: 10.radius,
                      ),
                    ),
                    5.wBox,
                    Expanded(
                      flex: 3,
                      child: MainButton(
                          title: StringManager.purchase.tr(),
                          width: 153.w,
                          height: 47.h,
                          isLoading: false,
                          borderRadius: 10.radius,
                          buttonColor: ColorManager.purchaseBottomColor,

                          // backgroundColors:
                          // ColorManager.backgroudContanerAgency,
                          onTap: () {
                            if (tabType == MallOrBagType.specialId) {
                              di<MallBuyBloc>().add(BuyItemSpecialIdEvent(
                                idItem: int.parse((data).id!),
                              ));
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pop();
                              di<MallBuyBloc>().add(BuyItemEvent(
                                idItem: (data).id!,
                              ));
                            }
                          }),
                    )
                  ],
                ),
                // 5.hBox,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
