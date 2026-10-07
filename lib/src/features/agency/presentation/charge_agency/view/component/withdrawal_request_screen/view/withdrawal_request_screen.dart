import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/withdrawal_request_screen/view/widgets/country_selection_part.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/withdrawal_request_screen/view/widgets/payment_selection_part.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  final ShippingAgentsFullDataEntity shippingAgentsFullDataModel;

  const WithdrawalRequestScreen({
    super.key,
    required this.shippingAgentsFullDataModel,
  });

  @override
  State<WithdrawalRequestScreen> createState() =>
      _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  final MyStoreBloc _storeBloc = di<MyStoreBloc>();
  final SendWithdrawalRequestBloc _sendWithdrawalRequestBloc =
      di<SendWithdrawalRequestBloc>();

  @override
  void initState() {
    super.initState();
    if (!_storeBloc.state.reqState.isLoaded) {
      _storeBloc.add(const GetMyStoreEvent());
    }
  }

  @override
  void dispose() {
    _sendWithdrawalRequestBloc.add(const ClearTheSelection());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendWithdrawalRequestBloc, SendWithdrawalRequestState>(
      bloc: _sendWithdrawalRequestBloc,
      buildWhen: (prev, curr) => prev.amountController != curr.amountController,
      builder: (context, state) {
        return Scaffold(
          appBar:  AppBarWidget(
            title: StringManager.withdrawalRequest.tr(),
          ),
          backgroundColor: ColorManager.scaffoldBgAlt,
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          body: Padding(
            padding: context.paddingSymmetric(horizontal: 10),
            child: Column(
              children: [
                150.hBox,
                Container(
                  width: ScreenUtil().screenWidth,
                  margin:
                      context.paddingSymmetric(vertical: 10, horizontal: 15),
                  padding: context.paddingSymmetric(
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: 30.radius,
                  ),
                  child: Column(
                    children: [
                      TextWidget(
                        StringManager.theAmountOfMoney.tr(),
                        style: context.bodyMedium.size(10.sp * 1.8).w700.copyWith(  overflow: TextOverflow.ellipsis),
                      ),
                      BlocBuilder<MyStoreBloc, MyStoreState>(
                        bloc: di<MyStoreBloc>(),
                        buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.myStore != curr.myStore,
                        builder: (context, state) {
                          return HandlingDataWidget(
                              reqState: state.reqState,
                              title: StringManager.somethingWrong.tr(),
                              subTitle: StringManager.someThingWentWrong.tr(),
                              child: TextWidget(
                                '\$ ${state.myStore?.userUsd}',
                                style: context.bodyMedium.size(10.sp * 3.2,).bold.copyWith(overflow: TextOverflow.ellipsis),

                              ));
                        },
                      ),
                    ],
                  ),
                ),
                10.hBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    TextInputWidget(
                      label: TextWidget(
                        StringManager.amount.tr(),
                        style: context.bodyLarge.colorExt(
                          ColorManager.secondaryText,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: (0.2 ))),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      StringManager.amountYouWantToTransfer.tr(),
                      controller:
                          _sendWithdrawalRequestBloc.state.amountController,
                      keyboardType: TextInputType.number,
                      hintStyle: context.bodyLarge.colorExt(
                        ColorManager.secondaryText,
                      ),
                      textColor: ColorManager.secondaryText,
                      textSize: 20,
                      contentPadding: context.paddingSymmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                    ),
                    10.hBox,
                    PaymentSelectionPart(
                      paymentList:
                          widget.shippingAgentsFullDataModel.paymentGetaway ??
                              [],
                    ),
                    10.hBox,

                    CountrySelectionPart(
                      countryList:
                          widget.shippingAgentsFullDataModel.countries!,
                    ),
                    10.hBox,
                    // TextWidget(
                    //   StringManager.addaNote,
                    //   style: TextStyle(
                    //     fontSize: 10.sp * 1.4,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    // 5.hBox,
                    TextInputWidget(
                      label: TextWidget(
                        StringManager.addaNote.tr(),
                        style: context.bodyLarge.colorExt(
                          ColorManager.secondaryText,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: (0.2 ))),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      StringManager.enteraNote.tr(),
                      controller:
                          _sendWithdrawalRequestBloc.state.notesController,
                      hintStyle: context.bodyLarge.colorExt(
                        ColorManager.secondaryText,
                      ),
                      maxLines: 5,
                      textColor: ColorManager.secondaryText,
                      contentPadding: context.paddingSymmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    120.hBox,
                    Center(
                      child: ButtonWidget(
                        onPressed: () {
                          if (_sendWithdrawalRequestBloc
                              .state.amountController.text.isEmpty) {
                            Methods.showToast(
                              context,
                              message: StringManager.pleaseEnterQuantity.tr(),
                            );
                          } else if (_sendWithdrawalRequestBloc.state.payment ==
                              null) {
                            Methods.showToast(
                              context,
                              message: StringManager.pleaseEnterPaymentMethod.tr(),
                            );
                          } else if (_sendWithdrawalRequestBloc.state.country ==
                              null) {
                            Methods.showToast(
                              context,
                              message: StringManager.pleaseEnterCountry.tr(),
                            );
                          } else {
                            _sendWithdrawalRequestBloc.add(
                              SendWithdrawalRequestEvent(
                                agentId:
                                    '${widget.shippingAgentsFullDataModel.id}',
                                context: context,
                              ),
                            );
                          }
                        },
                        title: StringManager.submit.tr(),
                        height: 55.h,
                        width: 300.w,
                        elevation: 0,
                        backgroundColor: ColorManager.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
