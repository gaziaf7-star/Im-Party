import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';

part 'components/bill_tab_bar_body.dart';

part 'components/bill_tab_bar_view_body.dart';

part 'widgets/bill_item_row.dart';

class BillPage extends StatelessWidget {
  const BillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        iconColor: ColorManager.black,
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.coinsAccent,
            ColorManager.coinsAccent.withValues(alpha: 0.75),
          ],
        ),
        title: StringManager.record.tr(),
        titleStyle:
        context.bodyMedium.size(20).w600.colorExt(ColorManager.black),
      ),
      body: BlocBuilder<BillBloc, BillState>(
        bloc: di<BillBloc>(),
        buildWhen: (prev, curr) => false,
        builder: (context, state) {
          return Padding(
            padding: context.paddingAll(15),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.rechargeRecord);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: context.paddingSymmetric(
                        horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: 12.radius,
                      border: Border.all(
                          color: ColorManager.grey2.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.black.withValues(alpha: 0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AssetsManager.walletTigerIcon,
                          width: 20,
                        ),
                        12.wBox,
                        Expanded(
                          child: TextWidget(
                            StringManager.rechargeRecord.tr(),
                            style: context.bodyMedium.w600
                                .size(16)
                                .colorExt(ColorManager.black),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: ColorManager.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                15.hBox,
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.coinsRecord);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: context.paddingSymmetric(
                        horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: 12.radius,
                      border: Border.all(
                          color: ColorManager.grey2.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.black.withValues(alpha: 0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AssetsManager.coinsVip,
                          width: 20,
                          height: 20,
                        ),
                        12.wBox,
                        Expanded(
                          child: TextWidget(
                            StringManager.coinsRecord.tr(),
                            style: context.bodyMedium.w600
                                .size(16)
                                .colorExt(ColorManager.black),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: ColorManager.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//Column(
//               children: [
//                 Container(
//                   color: ColorManager.white,
//                   width: ScreenUtil().screenWidth,
//                   child: Column(
//                     children: [
//                       5.hBox,
//                       _BillTabBarBody(controller: billController),
//                       5.hBox,
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: billController,
//                     children: [
//                       HandlingDataWidget(
//                         reqState: state.billGivingRequest,
//                         title: StringManager.titleEmptyTransaction.tr(),
//                         subTitle: StringManager.subEmptyTransaction.tr(),
//                         onTap: () => di<BillBloc>().add(
//                             const GetBillGivingEvent(
//                                 param: BillParam(type: 'givin'))),
//                         child: BillTabBarViewBody(
//                           billEntityList: state.billGiving ?? [],
//                           type: 1,
//                         ),
//                       ),
//                       HandlingDataWidget(
//                         reqState: state.billReceivedRequest,
//                         title: StringManager.titleEmptyTransaction.tr(),
//                         subTitle: StringManager.subEmptyTransaction1.tr(),
//                         onTap: () => di<BillBloc>().add(
//                             const GetBillReceivedEvent(
//                                 param: BillParam(type: 'receving'))),
//                         child: BillTabBarViewBody(
//                           billEntityList: state.billReceived ?? [],
//                           type: 2,
//                         ),
//                       ),
//                       HandlingDataWidget(
//                         reqState: state.billRechargeRequest,
//                         title: StringManager.titleEmptyTransaction.tr(),
//                         subTitle: StringManager.subEmptyTransaction2.tr(),
//                         onTap: () => di<BillBloc>().add(
//                             const GetBillRechargeEvent(
//                                 param: BillParam(type: 'recharge'))),
//                         child: BillTabBarViewBody(
//                           billEntityList: state.billRecharge ?? [],
//                           type: 3,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );