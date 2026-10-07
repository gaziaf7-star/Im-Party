part of '../family_member_page.dart';

// class UserSettings extends StatelessWidget {
//   final int userId;
//   final int familyId;
//   final int familyStatus;
//
//   const UserSettings(
//       {required this.userId,
//       required this.familyId,
//       required this.familyStatus,
//       super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 22.w,
//       height: 22.w,
//       child: PopupMenuButton(
//         iconColor: ColorManager.white,
//         elevation: 0.0,
//         itemBuilder: (_) => [
//           if (familyStatus == 0) ...{
//             popUpItemWidget(
//                 title: StringManager.addAdmin,
//                 onTap: () {
//                   di<ChangeUserTypeBloc>().add(ChangeUserTypeEvent(
//                     userId: userId.toString(),
//                     type: '1',
//                     familyId: familyId.toString(),
//                   ));
//                 })
//           },
//           if (familyStatus == 1) ...{
//             popUpItemWidget(
//               title: StringManager.removeAdmin,
//               onTap: () {
//
//                 di<ChangeUserTypeBloc>().add(ChangeUserTypeEvent(
//                     userId: userId.toString(),
//                     type: '0',
//                     familyId: familyId.toString(),
//                     ));
//               },
//             )
//           },
//           ...{
//             popUpItemWidget(
//                 title: StringManager.deleteMember,
//                 onTap: () {
//                   di<FamilyRemoveUserBloc>().add(RemoverFamilyUser(
//                     uId: userId.toString(),
//                     familyId: familyId.toString(),
//                   ));
//                 }),
//           }
//         ],
//         style: TextButton.styleFrom(
//             minimumSize: const Size(10, 10),
//             maximumSize: const Size(20, 20),
//             padding: context.paddingZero()),
//         padding: context.paddingZero(),
//         icon: const Icon(
//           Icons.more_horiz,
//           color: ColorManager.black,
//         ),
//         color: ColorManager.white,
//         shape: RoundedRectangleBorder(
//             borderRadius: 15.radius,
//             side: const BorderSide(color: ColorManager.black)),
//       ),
//     );
//   }
// }
















class UserSettings extends StatelessWidget {
  final int userId;
  final int familyId;
  final int familyStatus;

  const UserSettings({
    required this.userId,
    required this.familyId,
    required this.familyStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.more_horiz,
        color: ColorManager.textPrimary,
      ),
      onPressed: () {
        _showPopupMenu(context);
      },
    );
  }

  void _showPopupMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: ColorManager.black),
          ),
          title: const Text('User Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (familyStatus == 0) ...{
                _popupItemWidget(
                  context,
                  title: StringManager.addAdmin.tr(),
                  onTap: () {
                    di<ChangeUserTypeBloc>().add(ChangeUserTypeEvent(
                      userId: userId.toString(),
                      type: '1',
                      familyId: familyId.toString(),
                    ));
                    Navigator.pop(context); // Close the dialog after action
                  },
                ),
              },
              if (familyStatus == 1) ...{
                _popupItemWidget(
                  context,
                  title: StringManager.removeAdmin.tr(),
                  onTap: () {
                    di<ChangeUserTypeBloc>().add(ChangeUserTypeEvent(
                      userId: userId.toString(),
                      type: '0',
                      familyId: familyId.toString(),
                    ));
                    Navigator.pop(context); // Close the dialog after action
                  },
                ),
              },
              _popupItemWidget(
                context,
                title: StringManager.deleteMember.tr(),
                onTap: () {
                  di<FamilyRemoveUserBloc>().add(RemoverFamilyUser(
                    uId: userId.toString(),
                    familyId: familyId.toString(),
                  ));
                  Navigator.pop(context); // Close the dialog after action
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text('Cancel', style: context.bodyMedium.colorExt( Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _popupItemWidget(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}

