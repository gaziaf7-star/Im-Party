
import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/domain/entity/charge_agency_info_entity.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/send_withdrawel_request_manager/send_withdrawel_request_bloc.dart';

class PaymentSelectionPart extends StatelessWidget {
  final List<PaymentsGetwaysEntity> paymentList;

  const PaymentSelectionPart({required this.paymentList, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendWithdrawalRequestBloc, SendWithdrawalRequestState>(
      bloc: di<SendWithdrawalRequestBloc>(),
      buildWhen: (prev, curr) => prev.payment != curr.payment,
      builder: (context, state) {
        return InkWell(
          onTap: () {
            state.payment == null
                ? di<SendWithdrawalRequestBloc>()
                    .add(PaymentSelectEvent(payment: paymentList[0]))
                : null;

            Methods.showCupertinoCountriesPicker(
              context: context,
              isFirstOpen: true,
              isPayment: true,
              onChanged: (value) {
                di<SendWithdrawalRequestBloc>()
                    .add(PaymentSelectEvent(payment: paymentList[value]));
              },
              children: List.generate(paymentList.length, (index) {
                return TextWidget(
                  paymentList[index].name ?? "",
                  style: context.bodyLarge,
                );
              }),
            );
            // context.pushNamedRoute(Routes.dataScreen,
            //     arguments: true);

            // if (isWithdrawalScreen == true) {
            //   di<SendWithdrawalRequestBloc>().add(const ShowCountries());
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
                    bottom: BorderSide(color: Colors.grey.withValues(alpha: (0.2 ))))),
            child:
                TextWidget(
              ((di<SendWithdrawalRequestBloc>().state.payment?.name ?? '') !=
                      '')
                  ? di<SendWithdrawalRequestBloc>().state.payment!.name!
                  : StringManager.choosePaymentMethod.tr(),
              style: context.bodyLarge.colorExt(
                ColorManager.secondaryText,
              ),
            ),
          ),
        );
      },
    );
  }
}
