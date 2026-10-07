part of 'package:general/src/features/room/presentation/share/share_room_internal_screen.dart';

class _RoomSelectAllFriends extends StatelessWidget {
  const _RoomSelectAllFriends({
    required this.room,
    required this.idsAndBool,
    required this.selectedIds,
    required this.selectAll,
  });
  final EnterRoomModel room;
  final bool selectAll;
  final List<int> selectedIds;
  final Map<int, bool> idsAndBool;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchStates>(
      bloc: di<SearchBloc>(),
      buildWhen: (prev, curr) => prev.data != curr.data,
      builder: (context, state) {
        return Padding(
          padding: context.paddingSymmetric(vertical: 5),
          child: Row(
            children: [
              Row(
                children: [
                  Checkbox(
                    shape: const CircleBorder(
                        side: BorderSide(color: ColorManager.grey)),
                    side: WidgetStateBorderSide.resolveWith(
                      (states) => const BorderSide(
                          width: 2.0, color: ColorManager.grey),
                    ),
                    checkColor: ColorManager.white,
                    activeColor: ColorManager.blue,
                    value: selectAll,
                    onChanged: (bool? value) {
                      di<ShareRoomBloc>().add(ToggleSelectAllRoom());
                    },
                  ),
                  Text(
                    '${StringManager.select.tr()}  (${selectAll ? (state.data?.users ?? []).length.toInt() - selectedIds.length : selectedIds.length}/${(state.data?.users ?? []).length})',
                    style: context.bodyMedium.bold
                        .colorExt(ColorManager.textPrimary),
                  ),
                ],
              ),
              const Spacer(),
              MainButton(
                onTap: () {
                  di<ShareRoomBloc>().add(ShareRoom(context, room));
                },
                title: StringManager.share.tr(),
                buttonColor: ColorManager.primary,
                height: 40.h,
                width: 100.w,
              ),
              20.wBox,
            ],
          ),
        );
      },
    );
  }
}
