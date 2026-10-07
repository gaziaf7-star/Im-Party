import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/presentation/bag/view/widgets/send_bottom_sheet.dart';
import 'package:general/src/features/mall_bag/presentation/component/custom_model_bottom_sheet.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

import '../../../../mall_bag.dart';

class BottomSheetBagItemView extends StatelessWidget {
  final MyBagEntity data;
  final MallOrBagType tabType;

  const BottomSheetBagItemView(
      {required this.data, required this.tabType, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ScreenUtil().screenWidth,
            padding: context.paddingSymmetric(horizontal: 50),
            decoration: BoxDecoration(
                borderRadius: 10.radius,
                color: ColorManager.orange.withValues(alpha: (0.1))),
            child: ImageViewWidget(
              url: data.image ?? "",
              width: 80,
              height: 180,
              boxFit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: context.paddingSymmetric(horizontal: 20),
            child: SizedBox(
              height: ScreenUtil().screenHeight * 0.25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.hBox,
                  TextWidget(
                    (data).name.toString(),
                    style: context.bodyMedium.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  5.hBox,
                  TextWidget(
                    '${(data).expire} ${StringManager.days.tr()}',
                    style:
                        context.bodyMedium.colorExt(ColorManager.greyTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
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
                          width: 153.w,
                          height: 47.h,
                          borderRadius: 10.radius,
                          title: data.isUsed
                              ? StringManager.unUse.tr()
                              : StringManager.use.tr(),
                          isLoading: false,
                          buttonColor: ColorManager.primary,
                          onTap: () {
                            if (tabType == MallOrBagType.specialId) {
                              di<UseUnUseBloc>().add(
                                UseUnUseSpecialIdEvent(
                                  param: UseUnUseBagItemParam(
                                    itemId: (data).id.toString(),
                                    isUsed: data.isUsed ? false : true,
                                  ),
                                  tabType: tabType,
                                ),
                              );
                            } else {
                              if ((data).isUsed) {
                                di<UseUnUseBloc>().add(
                                  UnUseEvent(
                                    param: UseUnUseBagItemParam(
                                      itemId: (data).id.toString(),
                                      type: tabType == MallOrBagType.frame
                                          ? '1'
                                          : tabType == MallOrBagType.bubble
                                              ? '2'
                                              : tabType == MallOrBagType.intro
                                                  ? '3'
                                                  : '4',
                                    ),
                                    tabType: tabType,
                                  ),
                                );
                              } else {
                                di<UseUnUseBloc>().add(
                                  UseEvent(
                                    param: UseUnUseBagItemParam(
                                      itemId: (data).id.toString(),
                                      type: tabType == MallOrBagType.frame
                                          ? '1'
                                          : tabType == MallOrBagType.bubble
                                              ? '2'
                                              : tabType == MallOrBagType.intro
                                                  ? '3'
                                                  : '4',
                                    ),
                                    tabType: tabType,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      5.wBox,
                      Expanded(
                        flex: 3,
                        child: MainButton(
                          title: StringManager.send.tr(),
                          width: 153.w,
                          height: 47.h,
                          borderRadius: 10.radius,
                          isLoading: false,
                          buttonColor: ColorManager.primary,
                          onTap: () => customModalBottomSheet(
                            context,
                            radius: 0,
                            height: ScreenUtil().screenHeight * 0.7,
                            child: SendBottomSheet(
                              isMall: false,
                              selectedItem: data,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.hBox,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
