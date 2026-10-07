part of '../family_rank_page.dart';

// class _FamilyRankRowItem extends StatelessWidget {
//   final FamilyRankEntity familyRankEntity;
//   final int i;
//
//   const _FamilyRankRowItem({required this.familyRankEntity, required this.i});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, Routes.familyScreen,
//             arguments: familyRankEntity.id.toString());
//       },
//       child: Container(
//         padding: context.paddingSymmetric(horizontal: 10, vertical: 8),
//         margin: context.paddingSymmetric(vertical: 5, horizontal: 10),
//         decoration: BoxDecoration(
//           borderRadius: 10.radius,
//           color: ColorManager.white,
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 SizedBox(
//                   height: (i > 2) ? 60.h : 65.h,
//                   child: Stack(
//                     alignment: AlignmentDirectional.bottomCenter,
//                     children: [
//                       (i == 0)
//                           ? Image.asset(
//                               AssetsManager.firstFamilyMedal,
//                               width: 38.w,
//                               height: 38.w,
//                             )
//                           : (i == 1)
//                               ? Image.asset(
//                                   AssetsManager.secondFamilyMedal,
//                                   width: 38.w,
//                                   height: 38.w,
//                                 )
//                               : (i == 2)
//                                   ? Image.asset(
//                                       AssetsManager.thirdFamilyMedal,
//                                       width: 38.w,
//                                       height: 38.w,
//                                     )
//                                   : Container(
//                                       width: 35.w,
//                                       height: 15.h,
//                                       margin: context.paddingOnly(bottom: 10),
//                                       decoration: BoxDecoration(
//                                           color: ColorManager.purple,
//                                           borderRadius: 4.radius),
//                                       child: Center(
//                                         child: TextWidget(
//                                           'LV.${i + 1}',
//                                           style: context.bodySmall.copyWith(
//                                               color: Colors.white,
//                                               fontSize: 10),
//                                         ),
//                                       ),
//                                     ),
//                       Align(
//                         alignment: AlignmentDirectional.topCenter,
//                         child: Container(
//                           width: 35.w,
//                           height: 35.w,
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             borderRadius: 25.radius,
//                           ),
//                           child: UserImage(
//                             image: familyRankEntity.img ?? '',
//                             imageSize: 35,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 20.wBox,
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextWidget(
//                         familyRankEntity.name ?? '',
//                         style: context.bodyMedium.w600,
//                       ),
//                       5.hBox,
//                       Row(
//                         children: [
//                           TextWidget(familyRankEntity.rank ?? ''),
//                           5.wBox,
//                           Image.asset(
//                             AssetsManager.cherries,
//                             height: 15.h,
//                             width: 15.h,
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 if (const MyDataModel().familyId == 0)
//                   ButtonWidget(
//                     onPressed: () {
//                       di<JoinFamilyBloc>().add(JoinFamilyEvent(
//                           familyId: familyRankEntity.id.toString()));
//                     },
//                     title: TextWidget(
//                       StringManager.joinAgency.tr(),
//                       style: context.bodyMedium.colorExt(ColorManager.textPrimary),
//                     ),
//                     paddingButton: EdgeInsets.zero,
//                     padding: EdgeInsets.zero,
//                     isFittedBox: false,
//                     fontSize: 8,
//                     height: 22,
//                     width: 50,
//                     backgroundColor: ColorManager.pink,
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//
//     // return Material(
//     //   color: ColorManager.transparent,
//     //   shadowColor: ColorManager.transparent,
//     //   elevation: 0,
//     //   child: InkWell(
//     //     onTap: () {
//     //       Navigator.pushNamed(context, Routes.familyScreen,
//     //           arguments: familyRankEntity.id.toString());
//     //     },
//     //     child: Container(
//     //       padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
//     //       margin: context.paddingOnly(
//     //         bottom: 6.0,
//     //       ),
//     //       decoration: BoxDecoration(
//     //           color: ColorManager.white.withValues(alpha:0.15),
//     //           borderRadius: 5.radius),
//     //       child: Column(
//     //         children: [
//     //           Row(
//     //             children: [
//     //               TextWidget(
//     //                 '${i + 1}',
//     //                 style: context.bodyLarge
//     //                     .size(12)
//     //                     .w700
//     //                     .colorExt(ColorManager.grey),
//     //               ),
//     //               10.wBox,
//     //               UserImage(
//     //                 image: familyRankEntity.img ?? '',
//     //                 imageSize: 50,
//     //               ),
//     //               10.wBox,
//     //               Expanded(
//     //                 flex: 2,
//     //                 child: Column(
//     //                   crossAxisAlignment: CrossAxisAlignment.start,
//     //                   children: [
//     //                     Row(
//     //                       children: [
//     //                         FittedBox(
//     //                           child: TextWidget(
//     //                             familyRankEntity.name ?? '',
//     //                             style: context.bodyMedium.w600,
//     //                             overflow: TextOverflow.ellipsis,
//     //                           ),
//     //                         ),
//     //                         5.wBox,
//     //                       ],
//     //                     ),
//     //                     20.hBox,
//     //                   ],
//     //                 ),
//     //               ),
//     //               const Spacer(flex: 1),
//     //               TextWidget(
//     //                 ' ${familyRankEntity.rank}',
//     //                 style: context.bodyLarge,
//     //               ),
//     //             ],
//     //           ),
//     //         ],
//     //       ),
//     //     ),
//     //   ),
//     // );
//   }
// }
