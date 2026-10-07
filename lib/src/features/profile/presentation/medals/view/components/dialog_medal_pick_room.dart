part of '../medals_page.dart';

class BottomDialogPickRoom extends StatefulWidget {
  final List<String> pickedAchievements;
  final List<int> pickedPersonalIds;

  /// See [BottomDialogPickPersonal.asPage].
  final bool asPage;

  const BottomDialogPickRoom({
    super.key,
    required this.pickedAchievements,
    required this.pickedPersonalIds,
    this.asPage = false,
  });

  @override
  State<BottomDialogPickRoom> createState() => _BottomDialogPickRoomState();
}

class _BottomDialogPickRoomState extends State<BottomDialogPickRoom>
    with TickerProviderStateMixin {
  final selectionBloc = di<SelectionBloc>();
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBadge(
    BuildContext context, {
    required int badgeId,
    required List<int> otherPickedIds,
  }) {
    if (selectionBloc.state.selectedIds.contains(badgeId)) {
      final updated = List<int>.from(selectionBloc.state.selectedIds)..remove(badgeId);
      selectionBloc.add(SelectBadge(badgeId: badgeId, context: context));
      di<PickMyBadgesBloc>().add(PickMyBadgesEvent(ids: updated + otherPickedIds));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        title: 'Activate badge',
        description: 'Do you want to activate this badge?',
        onTap: () {
          final updated = [...selectionBloc.state.selectedIds, badgeId];
          if (updated.length > 3) {
            Navigator.of(context).pop();
            Methods.showToast(context, message: StringManager.pleaseSelect3Items.tr(), isError: true);
            return;
          }
          selectionBloc.add(SelectBadge(badgeId: badgeId, context: context));
          di<PickMyBadgesBloc>().add(PickMyBadgesEvent(ids: updated + otherPickedIds));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
        children: [
          6.hBox,
          MedalsTabBar(
            controller: _controller,
            titles: [
              StringManager.roomBadge.tr(),
              StringManager.giftBadge.tr(),
            ],
          ),
          6.hBox,
          BlocBuilder<GetBadgesBloc, GetBadgesStates>(
            bloc: di<GetBadgesBloc>(),
            buildWhen: (prev, curr) => prev.myAllBadgeState != curr.myAllBadgeState || prev.myAllBadge != curr.myAllBadge,
            builder: (context, state) {
              List<ImageData> data_ = [];
              if (state.myAllBadgeState.isLoaded) {
                data_ = state.myAllBadge
                    .where((a) => a.type == 'room_target')
                    .toList();

                final initialSelectedIds = data_
                    .where((badge) =>
                        widget.pickedAchievements.contains(badge.id.toString()))
                    .map((badge) => badge.id)
                    .toList();

                selectionBloc.add(const ClearSelection());
                for (final id in initialSelectedIds) {
                  selectionBloc.add(SelectBadge(badgeId: id, context: context));
                }
              }
              return HandlingDataWidget(
                reqState: state.myAllBadgeState,
                title: StringManager.noAchievements.tr(),
                subTitle: StringManager.noAchievementSubtitle.tr(),
                child: Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      GridView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          // 2 per row on the full page, on request -- was
                          // always 4. Same card size/shape as the main
                          // Badge page's Achievement tab, on request.
                          crossAxisCount: widget.asPage ? 2 : 4,
                          mainAxisSpacing: widget.asPage ? 10 : 5,
                          crossAxisSpacing: widget.asPage ? 10 : 5,
                          childAspectRatio: widget.asPage ? 0.82 : 1,
                        ),
                        itemCount: data_.length,
                        itemBuilder: (context, index) {
                          return BlocBuilder<SelectionBloc, SelectionState>(
                            bloc: selectionBloc,
                            buildWhen: (prev, curr) => prev.selectedIds != curr.selectedIds,
                            builder: (context, selectionState) {
                              final isSelected = selectionState.selectedIds
                                  .contains(data_[index].id);
                              return _PickBadgeCard(
                                imageUrl: data_[index].image,
                                isSelected: isSelected,
                                onTap: () => _toggleBadge(
                                  context,
                                  badgeId: data_[index].id,
                                  otherPickedIds: widget.pickedPersonalIds,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),
              );
            },
          ),
          6.hBox,
          // Save button removed -- activating a badge now saves immediately
          // via the confirm popup, on request.
          if (!widget.asPage)
            _BadgesBodybottomDialog(
              index: 1,
              pickedRoomIds: widget.pickedPersonalIds,
            ),
          10.hBox,
        ],
      );

    if (widget.asPage) return content;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 450.h,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.only(
          topLeft: 20.radiusCircular,
          topRight: 20.radiusCircular,
        ),
      ),
      child: content,
    );
  }
}
