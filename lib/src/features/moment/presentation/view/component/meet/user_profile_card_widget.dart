// import 'package:flutter_card_swiper/flutter_card_swiper.dart';
// import 'package:general/src/core/widgets/gender_widget.dart';
// import 'package:general/src/features/games/domain/entities/user_profile_entity.dart';
// import 'package:general/src/features/games/presentation/games/bloc/action/action_bloc.dart';
// import 'package:general/src/features/moment/presentation/view/component/meet/meet_user_images_carousel.dart';
//
// import '../../../../../../core/index.dart';
//
// class UserProfileCardWidget extends StatelessWidget {
//   const UserProfileCardWidget(
//       {super.key, required this.data, required this.controller});
//   final UserProfileEntity data;
//   final CardSwiperController controller;
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<ActionBloc>.value(
//       value: di<ActionBloc>(),
//       child: Container(
//         margin: context.paddingSymmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: 10.radiusCircular,
//             topRight: 10.radiusCircular,
//           ),
//           color: ColorManager.white,
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 clipBehavior: Clip.hardEdge,
//                 height: ScreenUtil().screenHeight * 0.5,
//                 alignment: AlignmentDirectional.bottomCenter,
//                 decoration: BoxDecoration(
//                   borderRadius: 10.radius,
//                 ),
//                 child: Stack(
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       height: ScreenUtil().screenHeight * 0.85,
//                       child: MeetUserImagesCarousel(data: data),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                           colors: [
//                             ColorManager.black.withValues(alpha:0.9),
//                             ColorManager.black.withValues(alpha:0.6),
//                             ColorManager.black.withValues(alpha:0.3),
//                             ColorManager.black.withValues(alpha:0.0),
//                           ],
//                         ),
//                       ),
//                       padding: context.paddingAll(15),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   Methods().userProfileNavigator(
//                                     context: context,
//                                     userId: '${data.id}',
//                                   );
//                                 },
//                                 child: UserImage(
//                                   image: data.image ?? '',
//                                   // frame: data.frame,
//                                   // positionedBottom: 13,
//                                   // frameSize: 65.w,
//                                   imageSize: 45.w,
//                                   boxFit: BoxFit.fill,
//                                 ),
//                               ),
//                               5.wBox,
//                               GestureDetector(
//                                 onTap: () {
//                                   Methods().userProfileNavigator(
//                                     context: context,
//                                     userId: '${data.id}',
//                                   );
//                                 },
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         TextWidget(
//                                           data.name ?? '',
//                                           style: context.bodySmall.w600
//                                               .colorExt(ColorManager.textPrimary)
//                                               .size(13.sp),
//                                         ),
//                                         10.wBox,
//                                         GenderWidget(
//                                             age: data.age ?? 0,
//                                             gender: data.gender ?? 0),
//                                       ],
//                                     ),
//                                     5.hBox,
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         if (data.senderLevelImage != '') ...[
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20.r),
//                                             ),
//                                             child: ImageViewWidget(
//                                               url: data.senderLevelImage ?? '',
//                                               width: 40.w,
//                                               height: 15.h,
//                                               boxFit: BoxFit.fill,
//                                               radius: 20,
//                                             ),
//                                           )
//                                         ],
//                                         if (data.receiverLevelImage != '') ...[
//                                           5.wBox,
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20.r),
//                                             ),
//                                             child: ImageViewWidget(
//                                               url:
//                                                   data.receiverLevelImage ?? '',
//                                               width: 40.w,
//                                               height: 15.h,
//                                               boxFit: BoxFit.fill,
//                                               radius: 20,
//                                             ),
//                                           )
//                                         ],
//                                         if (data.vipLevelImage != null &&
//                                             data.vipLevelImage != '') ...[
//                                           5.wBox,
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20.r),
//                                             ),
//                                             child: ImageViewWidget(
//                                               url: data.vipLevelImage ?? '',
//                                               width: 50.w,
//                                               height: 15.h,
//                                               boxFit: BoxFit.fill,
//                                               radius: 20,
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                     5.hBox,
//                                     Padding(
//                                       padding: context.paddingSymmetric(
//                                           horizontal: 5),
//                                       child: TextWidget(
//                                         data.bio ?? "",
//                                         overflow: TextOverflow.ellipsis,
//                                         maxLines: 1,
//                                         style: context.bodyLarge.w400
//                                             .colorExt(ColorManager.textPrimary),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               // const Spacer(),
//                               // Container(
//                               //   padding: context.paddingSymmetric(
//                               //     horizontal: 10,
//                               //     vertical: 3.0,
//                               //   ),
//                               //   decoration: BoxDecoration(
//                               //     color: ColorManager.white,
//                               //     borderRadius: 10.radius,
//                               //   ),
//                               //   child: TextWidget(
//                               //     '${data.distance} ${StringManager.mail}',
//                               //     style: context.bodyLarge.colorExt(
//                               //       ColorManager.bottomNavBarSelected,
//                               //     ),
//                               //   ),
//                               // ),
//                             ],
//                           ),
//
//                           /* Row(
//                             children: [
//                               Expanded(
//                                 child: TextWidget(
//                                   data.name ?? "",
//                                   overflow: TextOverflow.ellipsis,
//                                   style: context.bodyLarge.w600
//                                       .colorExt(ColorManager.textPrimary),
//                                 ),
//                               ),
//                               Container(
//                                 padding: context.paddingSymmetric(
//                                   horizontal: 10,
//                                   vertical: 3.0,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: ColorManager.white,
//                                   borderRadius: 10.radius,
//                                 ),
//                                 child: TextWidget(
//                                   '${data.distance} ${StringManager.mail}',
//                                   style: context.bodyLarge.colorExt(
//                                     ColorManager.bottomNavBarSelected,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),*/
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//                 height: ScreenUtil().screenHeight * 0.3,
//                 child: Column(
//                   children: [
//                     10.hBox,
//                     IconButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, Routes.messages,
//                             arguments: MessagesParameter(
//                               hasColorName: false,
//                               name: data.name.toString(),
//                               image: data.image ?? '',
//                               userId: data.id.toString(),
//                             ));
//                       },
//                       icon: ImageWidget(
//                         height: 50,
//                         width: 50,
//                         image: AssetsManager.hi,
//                         color: ColorManager.grey,
//                       ),
//                     ),
//                     10.hBox,
//                     TextWidget(
//                       StringManager.swipeRight.tr(),
//                       style: context.bodyMedium
//                           .size(14)
//                           .w500
//                           .colorExt(ColorManager.greyText),
//                     )
//                   ],
//                 )),
//             // ActionButtonBody(controller: controller, data: data),
//           ],
//         ),
//       ),
//     );
//   }
// }
