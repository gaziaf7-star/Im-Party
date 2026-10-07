part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';

class PaymentSelectionBody extends StatefulWidget {
  final bool isWithdrawalScreen;

  const PaymentSelectionBody({super.key, this.isWithdrawalScreen = false});

  @override
  State<PaymentSelectionBody> createState() => _PaymentSelectionBodyState();
}

class _PaymentSelectionBodyState extends State<PaymentSelectionBody> {
  @override
  void initState() {
    if (!di<GetPaymentsGetwaysDataBloc>().state.requestState.isLoaded) {
      di<GetPaymentsGetwaysDataBloc>().add(const GetPaymentGetwaysData());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            di<UpdateChargeAgencyBloc>().add(const ShowPaymentsEvent());
          },
          child: Container(
            width: ScreenUtil().screenWidth,
            padding: context.paddingSymmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: (0.2))))),
            child: BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
              bloc: di<UpdateChargeAgencyBloc>(),
              buildWhen: (prev, curr) => prev.showPayments != curr.showPayments,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextWidget(
                          StringManager.choosePaymentMethod.tr(),
                          style: context.bodyLarge
                              .colorExt(
                                ColorManager.secondaryText,
                              )
                              .size(12),
                        ),
                        const Spacer(),
                        ...List.generate(
                          ((di<GetChargeAgencyBloc>()
                                          .state
                                          .data
                                          ?.payments
                                          ?.length ??
                                      0) <
                                  4)
                              ? di<GetChargeAgencyBloc>()
                                      .state
                                      .data
                                      ?.payments
                                      ?.length ??
                                  0
                              : 4,
                          (index) {
                            final String payment = di<GetChargeAgencyBloc>()
                                    .state
                                    .data
                                    ?.payments?[index]
                                    .photo ??
                                '';
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: UserImage(
                                image: payment,
                                imageSize: 25,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    di<UpdateChargeAgencyBloc>().state.showPayments == true
                        ? const ChoosePaymentDropDown()
                        : const SizedBox(),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
