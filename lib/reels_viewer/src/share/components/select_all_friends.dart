part of 'package:general/reels_viewer/src/share/share_internel_screen.dart';

class _SelectAllFriends extends StatelessWidget {
  const _SelectAllFriends({
    required this.reel,
    required this.idsAndBool,
    required this.selectedIds,
    required this.selectAll,
  });
  final ReelsEntity reel;
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
                      (states) =>
                          const BorderSide(width: 2.0, color: ColorManager.grey),
                    ),
                    checkColor: ColorManager.white,
                    activeColor: ColorManager.blue,
                    value: selectAll,
                    onChanged: (bool? value) {
                      di<ShareReelBloc>().add(ToggleSelectAll());
                    },
                  ),
                  Text(
                    '${StringManager.select.tr()}  (${selectAll ? (state.data?.users ?? []).length.toInt() - selectedIds.length : selectedIds.length}/${(state.data?.users ?? []).length})',
                    style: context.bodyMedium.bold.colorExt( ColorManager.blackColor),

                  ),
                ],
              ),
              const Spacer(),
              MainButton(
                onTap: () {
                  di<ShareReelBloc>().add(ShareReel(context, reel));
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
