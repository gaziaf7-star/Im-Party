import 'package:general/src/core/index.dart';
import '../../../../../core/widgets/id_with_copy.dart';
import '../../../../room/presentation/gifts/gift.dart';
import 'components/dialog_start_end_date.dart';

class CoinsRecord extends StatefulWidget {
  const CoinsRecord({super.key});

  @override
  State<CoinsRecord> createState() => _CoinsRecordState();
}

class _CoinsRecordState extends State<CoinsRecord> {
  @override
  void initState() {
    if (!di<BillBloc>().state.billReceivedRequest.isLoaded) {
      di<BillBloc>()
          .add(const GetBillReceivedEvent(param: BillParam(type: 'receving')));
    }

    di<BillBloc>().add(const AddListenerBillReceivedEvent(
        param: BillParam(type: 'receving', isLoading: false)));

    super.initState();
  }

  @override
  void dispose() {
    di<BillBloc>().add(const RemoveListenerBillReceivedEvent(
        param: BillParam(type: 'receving', isLoading: false)));
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
        title: StringManager.coinsRecord.tr(),
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
                  return DialogStartEndDate(type: "receving");
                });
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
        prev.billReceivedRequest != curr.billReceivedRequest ||
            prev.billReceived != curr.billReceived ||
            prev.receivedScrollCtrl != curr.receivedScrollCtrl,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.billReceivedRequest,
            title: StringManager.titleEmptyTransaction.tr(),
            subTitle: StringManager.subEmptyTransaction1.tr(),
            onTap: () {
              di<BillBloc>().add(const GetBillReceivedEvent(
                  param: BillParam(type: 'receving')));
            },
            child: RefreshIndicatorWidget(
              onRefresh: () async {
                di<BillBloc>().add(const GetBillReceivedEvent(
                    param: BillParam(
                        type: 'receving', isLoading: false, isRefresh: true)));
              },
              child: ListView.builder(
                  itemCount: state.billReceived.length,
                  controller: state.receivedScrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  context.paddingSymmetric(horizontal: 10, vertical: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: context.paddingSymmetric(
                          horizontal: 10, vertical: 15),
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
                          ImageViewWidget(
                            url: state.billReceived[index].image,
                            width: 40.w,
                            height: 40.h,
                            radius: 20.r,
                            boxFit: BoxFit.cover,
                          ),
                          7.wBox,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 180.w,
                                  minWidth: 10.w,
                                ),
                                child: TextWidget(
                                  state.billReceived[index].name,
                                  style: context.bodyMedium
                                      .size(8)
                                      .w600
                                      .colorExt(
                                    Methods.safeHexColor(state
                                        .billReceived[index]
                                        .coloredName) ??
                                        ColorManager.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              3.hBox,
                              IdWithCopyIcon(
                                userId: state.billReceived[index].uuid,
                                idColor: ColorManager.black,
                                idStyle: context.bodySmall
                                    .colorExt(ColorManager.black),
                              ),
                              3.hBox,
                              FittedBox(
                                child: TextWidget(
                                  '${StringManager.reference.tr()} :${state.billReceived[index].operationNum}',
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
                                  TextWidget(
                                    state.billReceived[index].diamonds
                                        .toString(),
                                    style: context.bodyMedium.w600
                                        .colorExt(ColorManager.black)
                                        .size(13),
                                  ),
                                  5.wBox,
                                  Image.asset(
                                    AssetsManager.coinIcon,
                                    scale: 6,
                                  ),
                                ],
                              ),
                              TextWidget(
                                '${state.billReceived[index].createdAt.split(' ')[0]}\n'
                                    '${state.billReceived[index].createdAt.split(' ')[1]} ${state.billReceived[index].createdAt.split(' ')[2]}',
                                style: context.bodySmall
                                    .colorExt(ColorManager.black),
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