part of '../edit_profile_screen.dart';

// class _EditBirthdayRow extends StatelessWidget {
//   const _EditBirthdayRow({
//     required this.initialDateTime,
//     required this.onDateTimeChanged,
//     required this.onConfirm,
//     required this.title,
//   });
//
//   final DateTime? initialDateTime;
//   final ValueChanged<DateTime> onDateTimeChanged;
//   final void Function()? onConfirm;
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     return _RowEditInfo(
//       title: title,
//       subtitle: StringManager.birthDay.tr(),
//       onTap: () {
//         showCupertinoModalPopup(
//           context: context,
//           builder: (_) => Container(
//             height: 300.h,
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
//                       StringManager.modifyBirthday.tr(),
//                       style: context.bodyMedium
//                           .size(16)
//                           .bold
//                           .colorExt(ColorManager.textPrimary),
//                     ),
//                     ButtonWidget(
//                       title: StringManager.confirm.tr(),
//                       fontSize: 14,
//                       onPressed: onConfirm??()=>Navigator.pop(context),
//                       width: ScreenUtil().screenWidth * 0.3,
//                       fontWeight: FontWeight.w500,
//                       titleColor: ColorManager.lightDarkText,
//                       backgroundColor: ColorManager.transparent,
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: CupertinoTheme(
//
//                     data: CupertinoThemeData(
//                       textTheme: CupertinoTextThemeData(
//                         dateTimePickerTextStyle: context.titleLarge
//                             .colorExt(
//                               ColorManager.testBottomColor,
//                             )
//                             .w500
//                             .copyWith(
//                               fontFamily: StringManager.fontFamily,
//                             ),
//                       ),
//                     ),
//                     child: CupertinoDatePicker(
//
//                       mode: CupertinoDatePickerMode.date,
//                       initialDateTime: initialDateTime ?? DateTime.now(),
//                       onDateTimeChanged: (DateTime value) =>
//                           onDateTimeChanged(value),
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
