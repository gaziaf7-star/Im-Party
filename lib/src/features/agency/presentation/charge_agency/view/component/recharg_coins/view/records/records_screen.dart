import '../../../../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../../../../../profile/presentation/bill_coin/bloc/bill_bloc.dart';
import '../../../../../../../../profile/presentation/bill_coin/view/components/dialog_start_end_date.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  void initState() {
    if (!di<BillBloc>().state.billRechargeRequest.isLoaded) {
      di<BillBloc>()
          .add(const GetBillRechargeEvent(param: BillParam(type: 'recharge',shippingType: 'shipping')));
    }
    di<BillBloc>()
        .add(const AddListenerRechargeEvent(param: BillParam(type: 'recharge',isLoading: false,shippingType: 'shipping')));
    super.initState();
  }


  @override
  void dispose() {
    di<BillBloc>()
        .add(const RemoveListenerRechargeEvent(param: BillParam(type: 'recharge',isLoading: false)));
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: StringManager.rechargeRecord.tr(),
        iconLasted: IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: ColorManager.scaffoldBg,
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
              color: ColorManager.appBarTitlegrey,
              scale: 5,
            ),
          ),
        ),
      ),
      body: BlocBuilder<BillBloc, BillState>(
        bloc: di<BillBloc>(),
        buildWhen: (prev, curr) => prev.billRechargeRequest != curr.billRechargeRequest || prev.billRecharge != curr.billRecharge,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.billRechargeRequest,
            title: StringManager.titleEmptyTransaction.tr(),
            subTitle: StringManager.subEmptyTransaction1.tr(),
            onTap: (){
              di<BillBloc>()
                  .add(const GetBillRechargeEvent(param: BillParam(type: 'recharge')));
            },
            child: RefreshIndicatorWidget(
              onRefresh: ()async{
                di<BillBloc>()
                    .add(const GetBillRechargeEvent(param: BillParam(type: 'recharge',isRefresh:true,isLoading: false,shippingType: 'shipping')));
              },
              child: ListView.builder(
                  itemCount: state.billRecharge.length,
                  controller: state.rechargeScrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  context.paddingSymmetric(horizontal: 2, vertical: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: context.paddingSymmetric(horizontal: 5, vertical: 15),
                      margin: context.paddingAll(5),
                      decoration: BoxDecoration(
                          color: ColorManager.surfaceCardColor,
                          borderRadius: 5.radius,
                          border: Border.all(
                              width: 1, color: ColorManager.whiteGrey5)),

                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                '${StringManager.type.tr()} ${state.billRecharge[index].type}',
                                style: context.bodyMedium.bold,
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
                                  style: context.bodySmall,
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
                                      state.billRecharge[index].diamonds.toString(),
                                      style: context.bodyMedium.w600.size(14),
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
                                  '${ state.billRecharge[index].createdAt.split(' ')[0]}\n'
                                      '${ state.billRecharge[index].createdAt.split(' ')[1]} ${ state.billRecharge[index].createdAt.split(' ')[2]}',
                                  style: context.bodySmall
                                      .colorExt(ColorManager.whiteGrey4),
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