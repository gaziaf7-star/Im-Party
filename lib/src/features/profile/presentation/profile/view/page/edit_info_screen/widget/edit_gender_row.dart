part of '../edit_profile_screen.dart';

// class _EditGenderRow extends StatelessWidget {
//   const _EditGenderRow({
//     required this.currentGender,
//   });
//
//   final int? currentGender;
//
//   @override
//   Widget build(BuildContext context) {
//     return _RowEditInfo(
//       title: currentGender == 1
//           ? StringManager.male.tr()
//           : currentGender == 0
//               ? StringManager.female.tr()
//               : '',
//       subtitle: StringManager.gender.tr(),
//       onTap: () {
//         showCupertinoModalPopup(
//           context: context,
//           builder: (_) => Container(
//             height: 180.h,
//             width: ScreenUtil().screenWidth,
//             color: ColorManager.white,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ButtonWidget(
//                       title: StringManager.cancel.tr(),
//                       fontSize: 14,
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       width: ScreenUtil().screenWidth * 0.3,
//                       fontWeight: FontWeight.w500,
//                       titleColor: ColorManager.lightDarkText,
//                       backgroundColor: ColorManager.transparent,
//                     ),
//                     TextWidget(
//                       StringManager.modifyGender.tr(),
//                       style: context.bodyMedium
//                           .size(16)
//                           .bold
//                           .colorExt(ColorManager.textPrimary),
//                     ),
//                     ButtonWidget(
//                       title: StringManager.confirm.tr(),
//                       fontSize: 14,
//                       onPressed: () {
//                         di<EditInformationBloc>().add(
//                           const EditInformationEvent(),
//                         );
//                         Navigator.pop(context);
//                       },
//                       width: ScreenUtil().screenWidth * 0.3,
//                       fontWeight: FontWeight.w500,
//                       titleColor: ColorManager.lightDarkText,
//                       backgroundColor: ColorManager.transparent,
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: CupertinoTheme(
//                     data: CupertinoThemeData(
//                       textTheme: CupertinoTextThemeData(
//                         dateTimePickerTextStyle: context.titleLarge.w500
//                             .colorExt(ColorManager.textPrimary)
//                             .copyWith(
//                               fontFamily: StringManager.fontFamily,
//                             ),
//                       ),
//                     ),
//                     child: MediaQuery.removePadding(
//                       context: context,
//                       removeTop: true,
//                       child: CupertinoPicker(
//                         itemExtent: 40,
//                         selectionOverlay:
//                             CupertinoPickerDefaultSelectionOverlay(
//                           background:
//                               ColorManager.lightDarkText.withValues(alpha:0.1),
//                         ),
//                         onSelectedItemChanged: (value) {
//                           di<EditInformationBloc>().add(SelectedGenderEvent(
//                             gender: value == 0
//                                 ? StringManager.male.tr()
//                                 : StringManager.female.tr(),
//                           ));
//                         },
//                         scrollController: FixedExtentScrollController(
//                           initialItem: -1,
//                         ),
//                         children: [
//                           TextWidget(
//                             StringManager.male.tr(),
//                             style: context.bodyLarge
//                                 .colorExt(ColorManager.testBottomColor),
//                           ),
//                           TextWidget(
//                             StringManager.female.tr(),
//                             style: context.bodyLarge
//                                 .colorExt(ColorManager.testBottomColor),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 20.hBox,
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
