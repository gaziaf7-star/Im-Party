part of '../family_screen.dart';

// class _FamilyLevelBody extends StatelessWidget {
//   const _FamilyLevelBody({required this.showFamilyEntity});
//
//   final ShowFamilyEntity? showFamilyEntity;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: context.paddingSymmetric(horizontal: 10),
//       padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
//       width: ScreenUtil().screenWidth,
//       decoration: BoxDecoration(
//           // image: DecorationImage(
//           //     image: AssetImage(AssetsManager.familyBackground,),
//           //
//           //     fit: BoxFit.fill),
//         color: ColorManager.secondaryColor,
//           borderRadius: 8.radius),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           8.hBox,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               ImageWidget(
//                 height: 13.h,
//                 width: 13.w,
//                 image: AssetsManager.fire2,
//               ),
//               5.wBox,
//               TextWidget(
//                 "${showFamilyEntity?.familyLevelEntity?.familyExp ?? 0}/${showFamilyEntity?.familyLevelEntity?.nextExp ?? 0}",
//                 style: context.bodySmall.w600.size(8).colorExt(ColorManager.textPrimary),
//               ),
//             ],
//           ),
//           8.hBox,
//           LinearPercentIndicator(
//             padding: EdgeInsets.zero,
//             barRadius: 10.radiusCircular,
//             width: 150.w,
//             lineHeight: 6.h,
//             percent: showFamilyEntity?.familyLevelEntity?.per ?? 0.0,
//             backgroundColor: ColorManager.white.withValues(alpha:0.7),
//             progressColor: ColorManager.primary,
//           ),
//           8.hBox,
//           TextWidget(
//             "${StringManager.nextMonthLevelIs.tr()} ${showFamilyEntity?.familyLevelEntity?.nextName ?? ""}",
//             style: context.bodyMedium.w400.size(15).colorExt(ColorManager.textPrimary),
//           ),
//         ],
//       ),
//     );
//   }
// }
