
import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/charge_agency/bloc/get_payments_getways_manager/get_payments_getways_bloc.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_shipping_agents_full_data_manager/get_shipping_agents_full_data_bloc.dart';

class PaymentSelectWidget extends StatefulWidget {
  const PaymentSelectWidget({super.key});

  @override
  State<PaymentSelectWidget> createState() => _PaymentSelectWidgetState();
}

class _PaymentSelectWidgetState extends State<PaymentSelectWidget> {

  @override
  void initState() {

    if (!di<GetPaymentsGetwaysDataBloc>().state.requestState.isLoaded) {
      di<GetPaymentsGetwaysDataBloc>().add(const GetPaymentGetwaysData());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetShippingAgentsFullDataModelBloc,
        GetShippingAgentsFullDataModelState>(
      bloc: di<GetShippingAgentsFullDataModelBloc>(),
      buildWhen: (prev, curr) => prev.selectedPayment != curr.selectedPayment,
      builder: (context, state) {
        return BlocBuilder<GetPaymentsGetwaysDataBloc,
            GetPaymentsGetwaysDataState>(
          bloc: di<GetPaymentsGetwaysDataBloc>(),
          buildWhen: (prev, curr) => prev.selectedPayment != curr.selectedPayment || prev.data != curr.data,
          builder: (context, state) {
            return InkWell(
              onTap: () {
                state.selectedPayment == null
                    ? di<GetShippingAgentsFullDataModelBloc>()
                        .add(SelectPayment(paymentMethod: state.data?[0]))
                    : null;


                Methods.showCupertinoCountriesPicker(
                  context: context,
                  isFirstOpen: true,
                  isPayment: true,
                  onChanged: (value) {
                    di<GetShippingAgentsFullDataModelBloc>()
                        .add(SelectPayment(paymentMethod: state.data?[value]));

                  },
                  children: List.generate(state.data?.length ?? 0, (index) {
                    return TextWidget(
                      state.data?[index].name ?? "",
                      style: context.bodyLarge,
                    );
                  }),
                );
                // context.pushNamedRoute(Routes.dataScreen,
                //     arguments: true);

                // if (isWithdrawalScreen == true) {
                //   di<GetShippingAgentsFullDataModelBloc>().add(const ShowCountries());
                //
                //
                // } else {
                //   di<UpdateChargeAgencyBloc>().add(const ShowCountriesEvent());
                // }
              },
              child: Container(
                width: ScreenUtil().screenWidth,
                padding: context.paddingSymmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.withValues(alpha: (0.2 ))))),
                child: TextWidget(
                  ((di<GetShippingAgentsFullDataModelBloc>()
                                  .state
                                  .selectedPayment
                                  ?.name ??
                              '') !=
                          '')
                      ? di<GetShippingAgentsFullDataModelBloc>()
                          .state
                          .selectedPayment!
                          .name!
                      : StringManager.choosePaymentMethod.tr(),
                  style: context.bodyLarge.colorExt(
                    ColorManager.secondaryText,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
