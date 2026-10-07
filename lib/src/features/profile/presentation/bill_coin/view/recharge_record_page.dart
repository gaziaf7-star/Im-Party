import 'package:general/src/core/index.dart';
import '../../../../room/presentation/gifts/gift.dart';
import 'components/dialog_start_end_date.dart';

class RechargeRecord extends StatefulWidget {
  const RechargeRecord({
    super.key,
  });

  @override
  State<RechargeRecord> createState() => _RechargeRecordState();
}

class _RechargeRecordState extends State<RechargeRecord> {
  @override
  void initState() {
    if (!di<BillBloc>().state.billRechargeRequest.isLoaded) {
      di<BillBloc>()
          .add(const GetBillRechargeEvent(param: BillParam(type: 'recharge')));
    }
    di<BillBloc>().add(const AddListenerRechargeEvent(
        param: BillParam(type: 'recharge', isLoading: false)));
    super.initState();
  }

  @override
  void dispose() {
    di<BillBloc>().add(const RemoveListenerRechargeEvent(
        param: BillParam(type: 'recharge', isLoading: false)));
    super.dispose();
  }

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
        title: StringManager.rechargeRecord.tr(),
        titleStyle:
        context.bodyMedium.size(18).w600.colorExt(ColorManager.black),
        iconLasted: IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: ColorManager.white,
              shape: RoundedRectangleBorder(
                borderRadius: 15.radius,
              ),
              builder: (BuildContext context) {
                return DialogStartEndDate(type: "recharge");
              },
            );
          },
          icon: Padding(
            padding: context.paddingSymmetric(horizontal: 10),
            child: Image.asset(
              AssetsManager.filterIcon,
              color: ColorManager.black,
              scale: 5,
            ),
          ),
        ),
      ),
      body: BlocBuilder<BillBloc, BillState>(
        bloc: di<BillBloc>(),
        buildWhen: (prev, curr) =>
        prev.billRechargeRequest != curr.billRechargeRequest ||
            prev.billRecharge != curr.billRecharge ||
            prev.rechargeScrollCtrl != curr.rechargeScrollCtrl,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.billRechargeRequest,
            title: StringManager.titleEmptyTransaction.tr(),
            subTitle: StringManager.subEmptyTransaction1.tr(),
            onTap: () {
              di<BillBloc>().add(const GetBillRechargeEvent(
                  param: BillParam(type: 'recharge')));
            },
            child: RefreshIndicatorWidget(
              onRefresh: () async {
                di<BillBloc>().add(const GetBillRechargeEvent(
                    param: BillParam(
                        type: 'recharge', isRefresh: true, isLoading: false)));
              },
              child: ListView.builder(
                  itemCount: state.billRecharge.length,
                  controller: state.rechargeScrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  context.paddingSymmetric(horizontal: 2, vertical: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      padding:
                      context.paddingSymmetric(horizontal: 5, vertical: 15),
                      margin: context.paddingAll(5),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                '${StringManager.type.tr()} ${state.billRecharge[index].type}',
                                style: context.bodyMedium.bold
                                    .colorExt(ColorManager.black),
                              ),
                              // 3.hBox,
                              // TextWidget(
                              //   'ID: ${state.billRecharge[index].id}',
                              //   style: context.bodySmall,
                              // ),
                              3.hBox,
                              FittedBox(
                                child: TextWidget(
                                  '${StringManager.reference.tr()} :${state.billRecharge[index].operationNum}',
                                  style: context.bodySmall
                                      .colorExt(ColorManager.black),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  FittedBox(
                                    child: TextWidget(
                                      state.billRecharge[index].diamonds
                                          .toString(),
                                      style: context.bodyMedium.w600
                                          .size(14)
                                          .colorExt(ColorManager.black),
                                    ),
                                  ),
                                  5.wBox,
                                  Image.asset(
                                    AssetsManager.coinsIcon,
                                    scale: 20,
                                  ),
                                ],
                              ),
                              FittedBox(
                                child: TextWidget(
                                  '${state.billRecharge[index].createdAt.split(' ')[0]}\n'
                                      '${state.billRecharge[index].createdAt.split(' ')[1]} ${state.billRecharge[index].createdAt.split(' ')[2]}',
                                  style: context.bodySmall
                                      .colorExt(ColorManager.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          );
        },
      ),
    );
  }
}