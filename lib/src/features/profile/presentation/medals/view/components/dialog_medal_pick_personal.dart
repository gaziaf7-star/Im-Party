part of '../medals_page.dart';

class BottomDialogPickPersonal extends StatefulWidget {
  final List<String> pickedAchievements;
  final List<int> pickedRoomIds;

  /// When true, renders as plain content to fill a page body (dark theme,
  /// no fixed height, no bottom-sheet rounded-top/white styling) instead of
  /// the bottom-sheet look -- used by [BadgeManagePage].
  final bool asPage;

  const BottomDialogPickPersonal({
    super.key,
    required this.pickedAchievements,
    required this.pickedRoomIds,
    this.asPage = false,
  });

  @override
  State<BottomDialogPickPersonal> createState() =>
      _BottomDialogPickPersonalState();
}

class _BottomDialogPickPersonalState extends State<BottomDialogPickPersonal>
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

  /// Was a multi-select + separate Save button -- on request, tapping an
  /// inactive badge now confirms once ("Activate this badge?") and saves
  /// immediately, no Save button needed any more. Tapping an already-active
  /// badge deactivates it right away (no confirm needed) -- on request
  /// ("active kora inactive kora jassa nah").
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
          MedalsTabBar(
            controller: _controller,
            titles: [
              StringManager.achievementBadge.tr(),
              StringManager.specialBadge.tr(),
            ],
          ),
          // A little breathing room between the tab bar and the cards, on
          // request -- was flush against it after the earlier big-gap fix.
          16.hBox,
          Expanded(
            child: Stack(
              children: [
                // Was Alignment.center, which vertically centered the fixed
                // 360.h grid box inside all the remaining space -- leaving a
                // big empty gap above the cards. Positioned.fill anchors it
                // to the top instead, on request ("onek gap").
                Positioned.fill(
                  child: BlocBuilder<GetBadgesBloc, GetBadgesStates>(
                  bloc: di<GetBadgesBloc>(),
                  buildWhen: (prev, curr) =>
                      prev.myAllBadgeState != curr.myAllBadgeState ||
                      prev.myAllBadge != curr.myAllBadge,
                  builder: (context, state) {
                    List<ImageData> recharge_ = [];
                    List<ImageData> activity_ = [];
                    List<ImageData> data_ = [];
                    if (state.myAllBadgeState.isLoaded) {
                      for (int i = 0; i < state.myAllBadge.length; i++) {
                        if (state.myAllBadge[i].type == 'recharge_target') {
                          recharge_.add(state.myAllBadge[i]);
                        } else if (state.myAllBadge[i].type ==
                            'no achievement') {
                          activity_.add(state.myAllBadge[i]);
                        }
                      }
                      data_ = state.myAllBadge
                          .where((a) =>
                              a.type == 'recharge_target' ||
                              a.type == 'no achievement')
                          .toList();

                      final initialSelectedIds = data_
                          .where((badge) => widget.pickedAchievements
                              .contains(badge.id.toString()))
                          .map((badge) => badge.id)
                          .toList();

                      selectionBloc.add(const ClearSelection());
                      for (final id in initialSelectedIds) {
                        selectionBloc
                            .add(SelectBadge(badgeId: id, context: context));
                      }
                    }
                    return TabBarView(
                        controller: _controller,
                        children: [
                          GridView.builder(
                            padding: EdgeInsets.only(
                                right: 10.w, left: 10, bottom: 70.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              // 2 per row on the full page, on request --
                              // was always 4. Same card size/shape as the
                              // main Badge page's Achievement tab
                              // (tab_bar_view.dart), on request.
                              crossAxisCount: widget.asPage ? 2 : 4,
                              mainAxisSpacing: widget.asPage ? 10 : 5,
                              crossAxisSpacing: widget.asPage ? 10 : 5,
                              childAspectRatio: widget.asPage ? 0.82 : 1,
                            ),
                            itemCount: recharge_.length,
                            itemBuilder: (context, index) {
                              return BlocBuilder<SelectionBloc, SelectionState>(
                                bloc: selectionBloc,
                                buildWhen: (prev, curr) =>
                                    prev.selectedIds != curr.selectedIds,
                                builder: (context, selectionState) {
                                  final isSelected = selectionState
                                      .selectedIds
                                      .contains(recharge_[index].id);
                                  return _PickBadgeCard(
                                    imageUrl: recharge_[index].image,
                                    isSelected: isSelected,
                                    onTap: () => _toggleBadge(
                                      context,
                                      badgeId: recharge_[index].id,
                                      otherPickedIds: widget.pickedRoomIds,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          GridView.builder(
                            padding: EdgeInsets.only(
                                right: 10.w, left: 10, bottom: 70.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: widget.asPage ? 2 : 4,
                              mainAxisSpacing: widget.asPage ? 10 : 5,
                              crossAxisSpacing: widget.asPage ? 10 : 5,
                              childAspectRatio: widget.asPage ? 0.82 : 1,
                            ),
                            itemCount: activity_.length,
                            itemBuilder: (context, index) {
                              return BlocBuilder<SelectionBloc, SelectionState>(
                                bloc: selectionBloc,
                                buildWhen: (prev, curr) =>
                                    prev.selectedIds != curr.selectedIds,
                                builder: (context, selectionState) {
                                  final isSelected = selectionState
                                      .selectedIds
                                      .contains(activity_[index].id);
                                  return _PickBadgeCard(
                                    imageUrl: activity_[index].image,
                                    isSelected: isSelected,
                                    onTap: () => _toggleBadge(
                                      context,
                                      badgeId: activity_[index].id,
                                      otherPickedIds: widget.pickedRoomIds,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                  },
                ),
                ),
                // Save button removed -- activating a badge now saves
                // immediately via the confirm popup, on request.
                if (!widget.asPage)
                  Positioned(
                    bottom: 5,
                    left: 1,
                    right: 1,
                    child: _BadgesBodybottomDialog(
                      index: 0,
                      pickedRoomIds: widget.pickedRoomIds,
                    ),
                  ),
              ],
            ),
          )
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

/// Shared pickable-badge card: gradient fill + gold border (matching the
/// rest of the Badge feature), with an "Active" ribbon when selected --
/// replacing the plain white-bordered container, on request.
class _PickBadgeCard extends StatelessWidget {
  const _PickBadgeCard({
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAnimated = imageUrl.contains('.svga') ||
        imageUrl.contains('.zz') ||
        imageUrl.contains('.zzz');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: 15.radius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A2408), Color(0xFF1C1004)],
          ),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFE9A8) : const Color(0xCCFFD98A),
            width: isSelected ? 2.5 : 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: context.paddingAll(10),
                child: isAnimated
                    ? CacheSvgaWidget(url: imageUrl, boxFit: BoxFit.contain)
                    : ImageViewWidget(url: imageUrl, boxFit: BoxFit.contain),
              ),
            ),
            // Small "Active" label, top-right corner -- was a bottom
            // banner, on request.
            if (isSelected)
              Positioned(
                top: 6.h,
                right: 6.w,
                child: Container(
                  padding: context.paddingSymmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: 10.radius,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE9A8), Color(0xFFB8862F)],
                    ),
                  ),
                  child: TextWidget(
                    'Active',
                    isTranslate: false,
                    style: context.bodySmall.bold.size(10).colorExt(const Color(0xFF3A2205)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
