part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';

class PaymentSelectableItem extends StatelessWidget {
  final PaymentsGetwaysEntity? payment;
  final bool isSelected;

  const PaymentSelectableItem(
      {required this.isSelected, required this.payment, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(20),
      margin: context.paddingSymmetric(horizontal: 15, vertical: 20),
      decoration:
          BoxDecoration(color: ColorManager.scaffoldBg, borderRadius: 25.radius),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
              alignment: AlignmentDirectional.topEnd,
              child: InkWell(
                onTap: () {
                  {
                    di<UpdateChargeAgencyBloc>()
                        .add(SelectPaymentEvent(payment: payment));
                  }
                },
                child: selectableIcon(
                    context: context,
                    isSelected: (di<UpdateChargeAgencyBloc>()
                        .state
                        .selectedPayments
                        .contains(payment))),
              )),
          ImageViewWidget(
            url: payment?.photo ?? '',
            width: 70,
            height: 70,
            boxFit: BoxFit.cover,
          ),
          5.hBox,
          SizedBox(
            width: 150.w,
            child: Center(
              child: TextWidget(
                payment?.name ?? '',
                style: context.bodyLarge
                    .size(20)
                    .w700
                    .colorExt(ColorManager.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectableIcon(
      {required bool isSelected, required BuildContext context}) {
    return Container(
      width: 20.w,
      height: 20.w,
      padding: context.paddingAll(5),
      decoration: BoxDecoration(
          border: Border.all(color: ColorManager.primary),
          borderRadius: 20.radius,
          color: ColorManager.transparent),
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
            borderRadius: 20.radius,
            color:
                isSelected ? ColorManager.primary : ColorManager.transparent),
      ),
    );
  }
}
