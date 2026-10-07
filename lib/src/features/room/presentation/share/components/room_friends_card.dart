part of 'package:general/src/features/room/presentation/share/share_room_internal_screen.dart';

class _RoomFriendsCard extends StatelessWidget {
  const _RoomFriendsCard({
    required this.users,
    required this.room,
    required this.idsAndBool,
    required this.selectedIds,
    required this.selectAll,
  });
  final List<UserEntity> users;
  final EnterRoomModel room;
  final bool selectAll;
  final List<int> selectedIds;
  final Map<int, bool> idsAndBool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 15.0),
      child: ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => 10.hBox,
          itemBuilder: (context, index) {
            return UserInfoRow(
              user: users[index],
              padding: context.paddingSymmetric(vertical: 8),
              endIcon: SizedBox(
                width: 32.w,
                child: Checkbox(
                  shape: const CircleBorder(
                      side: BorderSide(color: ColorManager.grey)),
                  side: WidgetStateBorderSide.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const BorderSide(
                          width: 2.0, color: ColorManager.transparent);
                    } else {
                      return const BorderSide(
                          width: 2.0, color: ColorManager.grey);
                    }
                  }),
                  checkColor: ColorManager.white,
                  activeColor: ColorManager.blue,
                  value: idsAndBool[users[index].id!] ?? selectAll,
                  onChanged: (bool? value) {
                    di<ShareRoomBloc>()
                        .add(ToggleSelectionRoom(users[index].id!));
                  },
                ),
              ),
            );
          }),
    );
  }
}
