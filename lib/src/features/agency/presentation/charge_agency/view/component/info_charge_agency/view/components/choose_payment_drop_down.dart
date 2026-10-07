
part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';




class ChoosePaymentDropDown extends StatefulWidget {
  // static ValueNotifier<List<int>> selectedPayments = ValueNotifier([]);
  //  static ValueNotifier<bool> showPayments = ValueNotifier(false);
  final bool isWithdrawalScreen;

  const ChoosePaymentDropDown({
    super.key,
    this.isWithdrawalScreen = false,
  });

  @override
  State<ChoosePaymentDropDown> createState() => _ChoosePaymentDropDownState();
}

class _ChoosePaymentDropDownState extends State<ChoosePaymentDropDown> {





  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth * 0.9,
        height: 150.h,
      child: BlocBuilder<GetPaymentsGetwaysDataBloc,
          GetPaymentsGetwaysDataState>(
        bloc: di<GetPaymentsGetwaysDataBloc>(),
        buildWhen: (prev, curr) => prev.requestState != curr.requestState || prev.data != curr.data,
        builder: (context, state) {
          return HandlingDataWidget(reqState: state.requestState,
              title: StringManager.noPaymentsTitle.tr(),
              subTitle: StringManager.noPaymentsSubTitle.tr(),
              child:ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) =>
                    Divider(
                      color: Colors.grey.withValues(alpha: (0.4 )),
                      thickness: 0.5,
                      height: 15.h,
                      endIndent: 20.w,
                      indent: 20.w,
                    ),
                padding: context.paddingSymmetric(
                    vertical: 20),
                itemBuilder: (context, index) {
                  return RowBuilderWidget(
                    onTap: () {
                      di<UpdateChargeAgencyBloc>().add(
                          SelectPaymentEvent(payment: state.data?[index]));

                      // if (widget.isWithdrawalScreen == true) {
                      //   di<GetShippingAgentsFullDataModelBloc>().add(
                      //       SelectPayment(paymentMethod: state.data?[index]));
                      // } else {
                      //   di<UpdateChargeAgencyBloc>().add(
                      //       SelectPaymentEvent(payment: state.data?[index]));
                      // }
                    },
                    payment: state.data![index],
                    //isWithdrawalScreen: true,
                    // image: state.data![index].photo!,
                    // title: state.data![index].name ?? '',
                    // id: state.data![index].id!,
                    // valueListenable: ChoosePaymentDropDown.selectedPayments,
                    //
                  );
                },
                itemCount: state.data?.length??0,
              ));


        },
      ),
    );
  }
}
