import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'components/header_body.dart';

part 'widgets/switch_widget.dart';

class ShippingAgentWithdrawalRequestScreen extends StatefulWidget {
  const ShippingAgentWithdrawalRequestScreen({
    super.key,
  });

  @override
  State<ShippingAgentWithdrawalRequestScreen> createState() =>
      _ShippingAgentWithdrawalRequestScreenState();
}

class _ShippingAgentWithdrawalRequestScreenState
    extends State<ShippingAgentWithdrawalRequestScreen> {
  @override
  void initState() {
    if (!di<GetChargeAgencyBloc>().state.requestState.isLoaded) {
      di<GetChargeAgencyBloc>().add(const GetChargeAgencyEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MakeShippingAgentToAdminWithdrawalRequestBloc,
        MakeShippingAgentToAdminWithdrawalRequestState>(
      bloc: di<MakeShippingAgentToAdminWithdrawalRequestBloc>(),
      buildWhen: (prev, curr) => prev.controller != curr.controller,
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBarWidget(
            title: Text(
              di<GetChargeAgencyBloc>().state.data?.name ?? '',
              style: context.bodyLarge.w600,
            ),
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              color: ColorManager.offWhite,
              padding: context.paddingSymmetric(horizontal: 20),
              height: ScreenUtil().screenHeight,
              width: ScreenUtil().screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  150.hBox,
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Container(
                      width: ScreenUtil().screenWidth,
                      margin: context.paddingSymmetric(
                          horizontal: 10, vertical: 30),
                      padding: context.paddingSymmetric(vertical: 10),
                      decoration:
                          const BoxDecoration(color: ColorManager.transparent),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextWidget(
                            StringManager.availableUSD.tr(),
                            style: context.bodyMedium.size(14).w700,
                          ),
                          BlocBuilder<GetChargeAgencyBloc,
                              GetChargeAgencyStates>(
                            bloc: di<GetChargeAgencyBloc>(),
                            buildWhen: (prev, curr) => prev.requestState != curr.requestState || prev.data != curr.data,
                            builder: (context, state) {
                              return Text(
                                "${state.requestState.isLoaded ? state.data?.usd.toString() : 0}",
                                style: context.bodyMedium.size(40).w700,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  20.hBox,
                  Padding(
                    padding: context.paddingAll(7),
                    child: TextInputWidget(
                      label: TextWidget(
                        StringManager.amount.tr(),
                        style: context.bodyLarge.colorExt(
                          ColorManager.secondaryText,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: (0.2))),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      StringManager.amountYouWantToTransfer.tr(),
                      controller: state.controller,
                      keyboardType: TextInputType.number,
                      hintStyle:
                          context.bodyMedium.size(16).colorExt(ColorManager.secondaryText),
                      contentPadding:
                          context.paddingSymmetric(horizontal: 10, vertical: 5),
                    ),
                  ),
                  15.hBox,
                  TextWidget(
                    StringManager.chooseType.tr(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  5.hBox,
                  SwitchWidget(
                    value: state.isCoins,
                    title: StringManager.coins.tr(),
                    onChanged: (value) {
                      di<MakeShippingAgentToAdminWithdrawalRequestBloc>()
                          .add(EditCoinsSwitchValue(value: !state.isCoins));
                    },
                  ),
                  5.hBox,
                  SwitchWidget(
                    value: state.isDollars,
                    title: StringManager.cash.tr(),
                    onChanged: (value) {
                      di<MakeShippingAgentToAdminWithdrawalRequestBloc>()
                          .add(EditDollarsSwitchValue(value: !state.isDollars));
                    },
                  ),
                  const Spacer(),
                  Center(
                    child: ButtonWidget(
                      onPressed: () {
                        if (state.controller.text.isEmpty) {
                          Methods.showToast(context,
                              message: StringManager.pleaseEnterQuantity.tr());
                        } else if (state.isDollars == false &&
                            state.isCoins == false) {
                          Methods.showToast(context,
                              message: StringManager.pleaseChooseAtype.tr());
                        } else {
                          di<MakeShippingAgentToAdminWithdrawalRequestBloc>()
                              .add(
                            MakeShippingAgentToAdminWithdrawalRequest(
                              context: context,
                              param:
                                  MakeShippingAgentToAdminWithdrawelRequestParam(
                                type: state.isCoins == true ? 1 : 2,
                                amount: state.controller.text,
                              ),
                            ),
                          );
                        }
                      },
                      title: StringManager.send.tr(),
                      height: 55.h,
                      width: 300.w,
                      elevation: 0,
                      backgroundColor: ColorManager.primary,
                    ),
                  ),
                  30.hBox,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
