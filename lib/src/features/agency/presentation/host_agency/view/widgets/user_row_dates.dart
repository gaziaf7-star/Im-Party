import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

class UserRowDatas extends StatelessWidget {
  const UserRowDatas({
    super.key,
    required this.dataHistory,
    required this.month,
    required this.year,
  });

  final AgencyHistoryEntity dataHistory;
  final String month;
  final String year;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Methods().userProfileNavigator(
          context: context,
          userId: dataHistory.id.toString(),
        );
      },
      onLongPress: () {
        if (dataHistory.id != MyDataModel.getInstance().id) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: DialogRemoveAnchor(
                content: StringManager.removeAnchor.tr(),
                onTapConfirm: () {
                  di<KickOutAgencyBloc>().add(
                    KickOutAgencyEvent(
                      context: context,
                      userId: dataHistory.id.toString(),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
      },
      child: Container(
        width: ScreenUtil().screenWidth,
        padding: context.paddingOnly(
          start: 10,
          top: 5,
          bottom: 5,
          end: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // color: ColorManager.veryLightBlack,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserImage(
              image: dataHistory.image,
              displayName: dataHistory.name,
              imageSize: 50,
            ),
            10.wBox,
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap FittedBox with a SizedBox for proper constraints
                  SizedBox(
                    width: ScreenUtil().screenWidth * 0.5,
                    child: TextWidget(
                      dataHistory.name,
                      style:context.bodyMedium.bold
                    ),
                  ),
                  TextWidget('ID: ${dataHistory.uuid}'),
                ],
              ),
            ),
            const Spacer(flex: 1),
            TextWidget(dataHistory.diamonds.toString()),
            const Spacer(flex: 1),
            TextWidget(dataHistory.totalUsed.toString()),
          ],
        ),
      ),
    );
  }
}

//
// import 'package:general/src/core/index.dart';
// import 'package:general/src/features/agency/agency.dart';
//
// class UserRowDatas extends StatelessWidget {
//   const UserRowDatas({
//     super.key,
//     required this.dataHistory,
//     required this.month,
//     required this.year,
//   });
//
//   final AgencyHistoryEntity dataHistory;
//   final String month;
//   final String year;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Methods().userProfileNavigator(
//           context: context,
//           userId: dataHistory.id.toString(),
//         );
//       },
//       onLongPress: () {
//         if (dataHistory.id != MyDataModel.getInstance().id) {
//           showDialog(
//             context: context,
//             builder: (context) => Dialog(
//               child: DialogRemoveAnchor(
//                 content: StringManager.removeAnchor.tr(),
//                 onTapConfirm: () {
//                   di<KickOutAgencyBloc>().add(
//                     KickOutAgencyEvent(
//                       context: context,
//                       userId: dataHistory.id.toString(),
//                     ),
//                   );
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//           );
//         }
//       },
//       child: Container(
//         width: ScreenUtil().screenWidth,
//         padding: context.paddingOnly(
//             start: 10, top: 5, bottom: 5, end: 20),
//         decoration: BoxDecoration(
//           borderRadius: 15.radius,
//       //    color: ColorManager.veryLightBlack,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             UserImage(
//               image: dataHistory.image,
//               imageSize: 50,
//             ),
//             10.wBox,
//             Expanded(
//               flex: 2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FittedBox(
//                     child: TextWidget(
//                       dataHistory.name,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   TextWidget('ID: ${dataHistory.uuid}'),
//                 ],
//               ),
//             ),
//             const Spacer(
//               flex: 1,
//             ),
//             TextWidget(dataHistory.diamonds.toString()),
//             const Spacer(
//               flex: 1,
//             ),
//             TextWidget(dataHistory.totalUsed.toString()),
//           ],
//         ),
//       ),
//     );
//   }
// }
