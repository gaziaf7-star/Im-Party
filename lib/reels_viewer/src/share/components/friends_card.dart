part of 'package:general/reels_viewer/src/share/share_internel_screen.dart';

class _FriendsCard extends StatelessWidget {
  const _FriendsCard({
    required this.users,
    required this.reel,
    required this.idsAndBool,
    required this.selectedIds,
    required this.selectAll,
  });
  final List<UserEntity> users;
  final ReelsEntity reel;
  final bool selectAll;
  final List<int> selectedIds;
  final Map<int, bool> idsAndBool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 15.0, ),

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
                    di<ShareReelBloc>()
                        .add(ToggleSelection(users[index].id!));
                  },
                ),
              ),
            );
          }),
    );
  }
}
