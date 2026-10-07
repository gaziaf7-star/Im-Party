// import 'package:general/src/core/index.dart';
// import 'package:general/src/core/widgets/gender_widget.dart';
// import 'package:general/src/features/games/data/model/profile_user_model.dart';
//
// import '../../../../../core/widgets/level_container.dart';
// import '../../../../../core/widgets/vip_container.dart';
//
// class ProfileCardDialog extends StatelessWidget {
//    const ProfileCardDialog({super.key,required this.data,});
//
//
//   final UserProfileModel data;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 445.h,
//       decoration: BoxDecoration(
//         borderRadius: 20.radius,
//         color: ColorManager.white,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             height: 275.h,
//             width: ScreenUtil().screenWidth,
//             margin: context.paddingAll(8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 topLeft: 20.radiusCircular,
//                 topRight: 20.radiusCircular,
//               ),
//             ),
//             child: UserImage(
//               image: data.image ?? '',
//               imageSize: 400.w,
//               borderRadius: BorderRadius.only(
//                 topLeft: 20.radiusCircular,
//                 topRight: 20.radiusCircular,
//               ),
//             ),
//           ),
//           Padding(
//             padding: context.paddingSymmetric(horizontal: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 5.hBox,
//                 Row(
//                   children: [
//                     ConstrainedBox(
//                       constraints: BoxConstraints(
//                         maxWidth: 110.w,
//                         minWidth: 5.w,
//                       ),
//                       child: TextWidget(
//                     data.name!,
//                         style: context.bodyLarge.colorExt(ColorManager.textPrimary),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ),
//                     5.wBox,
//                     GenderWidget(age: data.age??0, gender: data.gender??0),
//                     5.wBox,
//                     LevelContainer(
//                       image: data.senderLevelImage,
//                       // height: 17.h,
//                       // width: 50.w,
//                     ),
//                     5.wBox,
//                     LevelContainer(
//                       image: data.receiverLevelImage,
//                       // height: 17.h,
//                       // width: 50.w,
//                     ),
//                     5.wBox,
//                     VipContainer(
//                       vip: data.vipLevelImage,
//                       height: 17.h,
//                       width: 50.w,
//                     ),
//                   ],
//                 ),
//                 60.hBox,
//                 ButtonWidget(
//                   onPressed: (){
//                     //Methods.printLog(data.uuid.toString());
//                     context.popRoute();
//                     Navigator.pushNamed(
//                       context,
//                       Routes.messages,
//                       arguments: MessagesParameter(
//                         hasColorName: data.hasColorName??false,
//                         name: data.name??'',
//                         image: data.image??'',
//                         userId: '${data.id}',
//                           message:StringManager.sayHello.tr(),
//                       ),
//                     );
//                   },
//                   title:  Row(
//                     children: [
//                       Image.asset(AssetsManager.meetChat,scale: 3,),
//                       5.wBox,
//                       TextWidget(StringManager.sayHello.tr(),style: context.bodyMedium.w500.colorExt(ColorManager.textPrimary),),
//                     ],
//                   ),
//                   backgroundColors: ColorManager.gradientButtonChat,
//                   radius: 10,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
