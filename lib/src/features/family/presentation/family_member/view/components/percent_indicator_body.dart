part of '../family_member_page.dart';

// class _PercentIndicatorBody extends StatelessWidget {
//   const _PercentIndicatorBody({required this.data});
//
//   final ShowFamilyEntity? data;
//
//   @override
//   Widget build(BuildContext context) {
//     final double percent =
//         (((data?.members!.length ?? 0) + 1) / (data?.maxNumOfMembers ?? 0));
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TextWidget(
//           '${(data?.members?.length ?? 0)}',
//           style: context.bodySmall.colorExt(ColorManager.textPrimary),
//         ),
//         LinearPercentIndicator(
//           barRadius: Radius.circular(10.w),
//           width: MediaQuery.of(context).size.width - 220,
//           lineHeight: 12.h,
//           percent: percent > 1 ? 1 : percent,
//           backgroundColor: ColorManager.black.withValues(alpha:0.4),
//           progressColor: ColorManager.primary,
//         ),
//         TextWidget(
//           '${(data?.maxNumOfMembers ?? 0)}',
//           style: context.bodySmall.colorExt(ColorManager.textPrimary),
//         ),
//       ],
//     );
//   }
//
//
//
// }
