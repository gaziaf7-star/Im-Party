part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';











class RowBuilderWidget extends StatelessWidget {
  const RowBuilderWidget({
    super.key,
    required this.onTap,
    this.country,
    this.payment,
    this.isWithdrawalScreen = false,
  });

  final bool isWithdrawalScreen;
  final VoidCallback onTap;
  final CountryEntity? country;
  final PaymentsGetwaysEntity? payment;

  @override
  Widget build(BuildContext context) {
    // Check if country is null (i.e., payment data is being used)
    bool isPayment = country == null;

    return (isWithdrawalScreen ? _buildWithdrawalScreen(context, isPayment) : _buildChargeAgencyScreen(context, isPayment));
  }

  Widget _buildWithdrawalScreen(BuildContext context, bool isPayment) {
    return
      isPayment
        ? BlocBuilder<GetShippingAgentsFullDataModelBloc, GetShippingAgentsFullDataModelState>(
      bloc: di<GetShippingAgentsFullDataModelBloc>(),
      buildWhen: (prev, curr) => prev.selectedPayment != curr.selectedPayment,
      builder: (context, state) {
        return _buildRow(
          context,
          payment?.photo ?? '',
          payment?.name ?? '',
          di<GetShippingAgentsFullDataModelBloc>().state.selectedPayment?.id == payment?.id,
        );
      },
    )
       :
      BlocBuilder<GetShippingAgentsFullDataModelBloc, GetShippingAgentsFullDataModelState>(
      bloc: di<GetShippingAgentsFullDataModelBloc>(),
      buildWhen: (prev, curr) => prev.selectedCountry != curr.selectedCountry,
      builder: (context, state) {

        return _buildRow(
          context,
          country?.photo ?? '',
          country?.name ?? '',
          di<GetShippingAgentsFullDataModelBloc>().state.selectedCountry?.id == country?.id,
        );
      },
    );
  }

  Widget _buildChargeAgencyScreen(BuildContext context, bool isPayment) {
    return isPayment
        ? BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
      bloc: di<UpdateChargeAgencyBloc>(),
      buildWhen: (prev, curr) => prev.selectedPayments != curr.selectedPayments,
      builder: (context, state) {
        return _buildRow(
          context,
          payment?.photo ?? '',
          payment?.name ?? '',
          di<UpdateChargeAgencyBloc>().state.selectedPayments.contains(payment),
        );
      },
    )
        : BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
      bloc: di<UpdateChargeAgencyBloc>(),
      buildWhen: (prev, curr) => prev.selectedCountries != curr.selectedCountries,
      builder: (context, state) {
        return _buildRow(
          context,
          country?.photo ?? '',
          country?.name ?? '',
          di<UpdateChargeAgencyBloc>().state.selectedCountries.contains(country),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, String imageUrl, String name, bool isSelected) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // CountryIcon with dynamic photo and size
          CountryIcon(
            country: imageUrl,
            borderRadius: 15.radius,
            width: 40.w,
            height: 20.h,
          ),
          10.wBox,
          // TextWidget with dynamic name and styling
          TextWidget(
            name,
            style: context.bodyMedium.size(16).bold,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Selection indicator (circle)
          _buildSelectionIndicator(isSelected,context),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected,BuildContext context) {
    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorManager.primary,
          width: 2.0,
        ),
      ),
      child: Container(
        margin: context.paddingAll(2),
        decoration: BoxDecoration(
          color: isSelected ? ColorManager.primary : ColorManager.transparent,
          borderRadius: 10.radius,
        ),
      ),
    );
  }
}


















// class RowBuilderWidget extends StatelessWidget {
//   const RowBuilderWidget({super.key,
//     required this.onTap,
//     this.country,
//     this.payment,
//     this.isWithdrawalScreen = false});
//
//   final bool isWithdrawalScreen;
//
//   final VoidCallback onTap;
//   final CountryEntity? country;
//   final PaymentsGetwaysEntity? payment;
//
//   @override
//   Widget build(BuildContext context) {
//     if (country == null) {
//       ///////////////country
//
//       return (isWithdrawalScreen == true)
//           ? BlocBuilder<GetShippingAgentsFullDataModelBloc,
//           GetShippingAgentsFullDataModelState>(
//         bloc: di<GetShippingAgentsFullDataModelBloc>(),
//         builder: (context, state) {
//           return InkWell(
//             onTap: onTap,
//             child: Row(
//               children: [
//                 //todo for hosni border raduis
//                 CountryIcon(
//                   country: payment?.photo ?? '',
//                   borderRadius: 15.radius,
//                   width: 40.w,
//                   height: 20.h,
//                 ),
//                 10.wBox,
//                 TextWidget(
//                   payment?.name ?? '',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const Spacer(),
//
//                 Container(
//                   width: 15.w,
//                   height: 15.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: ColorManager.primary,
//                       // Border color for unselected state
//                       width: 2.0,
//                     ),
//                     // Transparent for unselected state
//                   ),
//                   child: Container(
//                     margin: context.paddingAll(2),
//                     decoration: BoxDecoration(
//                         color: (di<GetShippingAgentsFullDataModelBloc>()
//                             .state
//                             .selectedPayment
//                             ?.id ??
//                             0) ==
//                             (payment?.id ?? 0)
//                             ? ColorManager
//                             .primaryColor // Filled color for selected state
//                             : ColorManager.transparent,
//                         borderRadius: 10.radius),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       )
//           : BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
//         bloc: di<UpdateChargeAgencyBloc>(),
//         builder: (context, state) {
//           return InkWell(
//             onTap: onTap,
//             child: Row(
//               children: [
//                 //todo for hosni border raduis
//                 CountryIcon(
//                   country: payment?.photo ?? '',
//                   borderRadius: 15.radius,
//                   width: 40.w,
//                   height: 20.h,
//                 ),
//                 10.wBox,
//                 TextWidget(
//                   payment?.name ?? '',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const Spacer(),
//
//                 BlocBuilder<UpdateChargeAgencyBloc,
//                     UpdateChargeAgencyState>(
//                   bloc: di<UpdateChargeAgencyBloc>(),
//                   builder: (context, state) {
//                     return Container(
//                       width: 15.w,
//                       height: 15.w,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: ColorManager.primary,
//                           // Border color for unselected state
//                           width: 2.0,
//                         ),
//                         // Transparent for unselected state
//                       ),
//                       child: Container(
//                         margin: context.paddingAll(2),
//                         decoration: BoxDecoration(
//                             color: di<UpdateChargeAgencyBloc>()
//                                 .state
//                                 .selectedPayments
//                                 .contains(payment)
//                                 ? ColorManager
//                                 .primaryColor // Filled color for selected state
//                                 : ColorManager.transparent,
//                             borderRadius: 10.radius),
//                       ),
//                     );
//                   },
//                 )
//               ],
//             ),
//           );
//         },
//       )
//       ;
//     } else {
//       return (isWithdrawalScreen == true)
//           ? BlocBuilder<GetShippingAgentsFullDataModelBloc,
//           GetShippingAgentsFullDataModelState>(
//         bloc: di<GetShippingAgentsFullDataModelBloc>(),
//         builder: (context, state) {
//
//           return InkWell(
//             onTap: onTap,
//             child: Row(
//               children: [
//                 //todo for hosni border raduis
//                 CountryIcon(
//                   country: country?.photo ?? '',
//                   borderRadius: 15.radius,
//                   width: 40.w,
//                   height: 20.h,
//                 ),
//                 10.wBox,
//                 TextWidget(
//                   country?.name ?? '',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const Spacer(),
//
//                 BlocBuilder<GetShippingAgentsFullDataModelBloc,
//                     GetShippingAgentsFullDataModelState>(
//                   bloc: di<GetShippingAgentsFullDataModelBloc>(),
//                   builder: (context, state) {
//                     return Container(
//                       width: 15.w,
//                       height: 15.w,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: ColorManager.primary,
//                           // Border color for unselected state
//                           width: 2.0,
//                         ),
//                         // Transparent for unselected state
//                       ),
//                       child: Container(
//                         margin: context.paddingAll(2),
//                         decoration: BoxDecoration(
//                             color: (di<GetShippingAgentsFullDataModelBloc>()
//                                 .state
//                                 .selectedCountry
//                                 ?.id ??
//                                 0) ==
//                                 (country?.id ?? 0)
//                                 ? ColorManager
//                                 .primaryColor // Filled color for selected state
//                                 : ColorManager.transparent,
//                             borderRadius: 10.radius),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       )
//           : BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
//         bloc: di<UpdateChargeAgencyBloc>(),
//         builder: (context, state) {
//           return InkWell(
//             onTap: onTap,
//             child: Row(
//               children: [
//                 //todo for hosni border raduis
//                 CountryIcon(
//                   country: country?.photo ?? '',
//                   borderRadius: 15.radius,
//                   width: 40.w,
//                   height: 20.h,
//                 ),
//                 10.wBox,
//                 TextWidget(
//                   country?.name ?? '',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const Spacer(),
//
//                 BlocBuilder<UpdateChargeAgencyBloc,
//                     UpdateChargeAgencyState>(
//                   bloc: di<UpdateChargeAgencyBloc>(),
//                   builder: (context, state) {
//                     return Container(
//                       width: 15.w,
//                       height: 15.w,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: ColorManager.primary,
//                           // Border color for unselected state
//                           width: 2.0,
//                         ),
//                         // Transparent for unselected state
//                       ),
//                       child: Container(
//                         margin: context.paddingAll(2),
//                         decoration: BoxDecoration(
//                             color: di<UpdateChargeAgencyBloc>()
//                                 .state
//                                 .selectedCountries
//                                 .contains(country)
//                                 ? ColorManager
//                                 .primaryColor // Filled color for selected state
//                                 : ColorManager.transparent,
//                             borderRadius: 10.radius),
//                       ),
//                     );
//                   },
//                 )
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
// }
