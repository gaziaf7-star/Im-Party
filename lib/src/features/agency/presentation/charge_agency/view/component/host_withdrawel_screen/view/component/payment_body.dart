// part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';
//
// class PaymentBody extends StatefulWidget {
//   const PaymentBody({super.key});
//
//   @override
//   State<PaymentBody> createState() => PaymentBodyState();
// }
//
// class PaymentBodyState extends State<PaymentBody> {
//   final _paymentsGetwaysDataBloc = di<GetPaymentsGetwaysDataBloc>();
//   static final ValueNotifier<PaymentsGetwaysEntity> payment =
//       ValueNotifier(const PaymentsGetwaysEntity(id: 0));
//
//   @override
//   void initState() {
//
//     if (!_paymentsGetwaysDataBloc.state.requestState.isLoaded) {
//       _paymentsGetwaysDataBloc.add(const GetPaymentGetwaysData());
//     }
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GetPaymentsGetwaysDataBloc, GetPaymentsGetwaysDataState>(
//       bloc: _paymentsGetwaysDataBloc,
//       builder: (context, state) {
//         return HandlingDataWidget(
//             reqState: state.requestState,
//             title: StringManager.noPaymentsTitle.tr(),
//             subTitle: StringManager.noPaymentsSubTitle.tr(),
//             child: ValueListenableBuilder(
//                 valueListenable: payment,
//                 builder: (context, value, _) {
//
//
//                   return ExpandableWidget<PaymentsGetwaysEntity>(
//                     data: state.data ?? [],
//                     title: payment.value.name != null
//                         ? '${payment.value.name}'
//                         : StringManager.howToWithdraw.tr(),
//                     borderColor: ColorManager.lightOrange.withValues(alpha:0.8),
//                     backgroundColor: ColorManager.scaffoldBg,
// borderRadius: 50.radius,
//                     titlleColor: Colors.grey,
//                     maxHeight: 120.h,
//                     onSelectedValue: (PaymentsGetwaysEntity value) {
//                       payment.value = value;
//                     },
//                   );
//                 }),
//
//
//         );
//       },
//     );
//   }
// }
