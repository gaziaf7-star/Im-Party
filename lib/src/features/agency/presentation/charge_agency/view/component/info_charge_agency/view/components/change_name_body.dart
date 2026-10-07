// part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/info_charge_agency_screen.dart';
//
// class _ChangeNameBody extends StatefulWidget {
//   const _ChangeNameBody({
//     required this.id,
//     required this.name,
//   });
//
//   final int id;
//   final String name;
//
//   @override
//   State<_ChangeNameBody> createState() => _ChangeNameBodyState();
// }
//
// class _ChangeNameBodyState extends State<_ChangeNameBody> {
//   // late final TextEditingController controller;
//
//   @override
//   void initState() {
//     di<UpdateChargeAgencyBloc>().add(SetNameEvent(name: widget.name));
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     //  di<UpdateChargeAgencyBloc>().add(SetNameEvent(name: widget.name));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: ScreenUtil().screenWidth * 0.90,
//       decoration: BoxDecoration(
//         borderRadius: 20.radius,
//         color: ColorManager.veryLightBlack,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header
//           Container(
//             height: 50.h,
//             width: ScreenUtil().screenWidth,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(20.r),
//                 topLeft: Radius.circular(20.r),
//               ),
//
//             ),
//             child: Center(
//               child: TextWidget(
//                 StringManager.nameAgency.tr(),
//                 style: const TextStyle(
//                   color: ColorManager.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           20.hBox, // TextWidget Feild
//           Padding(
//             padding: context.paddingSymmetric(
//                 horizontal: 12
//             ),
//             child: TextInputWidget(
//               StringManager.nameAgency,
//               controller:
//                   di<UpdateChargeAgencyBloc>().state.textEditingController,
//               fillColor: const Color(0xFFEEEDED),
//               contentPadding: context.paddingSymmetric(
//                 horizontal: 20,
//               ),
//             ),
//           ),
//           50.hBox, // Actions
//           Padding(
//             padding: context.paddingSymmetric(
//               horizontal: 12,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: MainButton(
//                     onTap: () => Navigator.pop(context),
//                     title: StringManager.cancel.tr(),
//                     buttonColor: ColorManager.white,
//                     titleColor: ColorManager.black,
//                     height: 40.h,
//                     borderColor: Colors.grey,
//                   ),
//                 ),
//                 30.hBox,
//                 Expanded(
//                   child: MainButton(
//                     onTap: () {
//                       di<UpdateChargeAgencyBloc>()
//                           .add(SetNameEvent(name: widget.name));
//
//                       di<UpdateChargeAgencyBloc>().add(
//                         UpdateChargeAgencyEvent(
//                           context: context,
//                           agencyId: widget.id,
//                         ),
//                       );
//                       Navigator.pop(context);
//                     },
//                     title: StringManager.save.tr(),
//                     buttonColor: ColorManager.grey,
//                     height: 40.h,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           20.hBox,
//         ],
//       ),
//     );
//   }
// }
