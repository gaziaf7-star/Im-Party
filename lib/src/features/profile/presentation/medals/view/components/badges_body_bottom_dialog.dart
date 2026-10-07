part of '../medals_page.dart';

class _BadgesBodybottomDialog extends StatelessWidget {

  final List<int> pickedRoomIds;
  const _BadgesBodybottomDialog({
    required this.index,
    required this.pickedRoomIds,
    this.showPreview = true,
  });

  final int index;

  /// When false, renders just a compact Save button (no full-width cream
  /// preview card with the currently-worn badge icons) -- used by
  /// [BadgeManagePage], on request ("bottom a ja card ta dhkssa ata thkba
  /// nah").
  final bool showPreview;

  void _save(BuildContext context) {
    final selectedIds = di<SelectionBloc>().state.selectedIds;
    if (selectedIds.length < 4) {
      Navigator.pop(context);
      di<PickMyBadgesBloc>().add(
        PickMyBadgesEvent(ids: selectedIds + pickedRoomIds),
      );
    } else {
      Methods.showToast(context, message: StringManager.pleaseSelect3Items.tr(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showPreview) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: context.paddingSymmetric(horizontal: 15),
          child: GestureDetector(
            onTap: () => _save(context),
            child: Container(
              padding: context.paddingSymmetric(horizontal: 24, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: 20.radius,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE9A8), Color(0xFFB8862F)],
                ),
              ),
              child: TextWidget(
                StringManager.save.tr(),
                style: context.bodyMedium.bold.colorExt(const Color(0xFF3A2205)),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      width: ScreenUtil().screenWidth,

      margin: context.paddingSymmetric(horizontal: 5),
      decoration:   BoxDecoration(
        color: ColorManager.primary,
        borderRadius: 15.radius,
      ),
      child: BlocBuilder<UserBadgesBloc, UserBadgesState>(
        bloc: di<UserBadgesBloc>(),
        buildWhen: (prev, curr) => prev.myBadge != curr.myBadge,
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              10.wBox,
              index == 0
                  ? _BadgeContainerBody(
                badgeImages: state.myBadge!
                    .where((badge) => badge.type != 2)
                    .map((badge) => badge.image)
                    .toList(),
                badgeIds: state.myBadge!
                    .where((badge) => badge.type != 2)
                    .map((badge) => badge.id.toString())
                    .toList(),
              )
                  : _BadgeContainerBody(
                badgeImages: state.myBadge!
                    .where((badge) => badge.type == 2)
                    .map((badge) => badge.image)
                    .toList(),
                badgeIds: state.myBadge!
                    .where((badge) => badge.type == 2)
                    .map((badge) => badge.id.toString())
                    .toList(),
              ),
              const Spacer(),
              ButtonWidget(
                width: 70.w,
                elevation: 0.0,
                height: 30.w,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                onPressed: () => _save(context),
                paddingButton: context.paddingZero(),
                isFittedBox: false,
                title: StringManager.save.tr(),
                backgroundColor: ColorManager.scaffoldBg,
                titleColor: ColorManager.primary,
              ),
              10.wBox,
            ],
          );
        },
      ),
    );
  }
}
