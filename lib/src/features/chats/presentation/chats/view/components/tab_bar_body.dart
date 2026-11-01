import '../../../../../../core/index.dart';
import '../widgets/chat_strings.dart';

/// Pill-style segmented tab bar for the Chats page (All / Groups / Unread),
/// matching the reference design: a filled brand-gradient pill for the
/// selected tab, soft translucent-white pills for the rest, each with a
/// small red counter badge floating on its top-right corner.
///
/// Still driven by the page's [TabController] (so TabBarView paging, swipe
/// and programmatic `animateTo` keep working) — this only replaces the
/// visual [TabBar]/indicator with a custom pill row.
class TabBarBody extends StatefulWidget {
  const TabBarBody({
    super.key,
    required this.controller,
    this.allCount = 0,
    this.groupsCount = 0,
    this.unreadCount = 0,
  });

  final TabController controller;

  /// Unread badge counts shown on each pill (0 = no badge).
  final int allCount;
  final int groupsCount;
  final int unreadCount;

  @override
  State<TabBarBody> createState() => _TabBarBodyState();
}

class _TabBarBodyState extends State<TabBarBody> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant TabBarBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTabChanged);
      widget.controller.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  // Only the selected index drives this bar's look, but TabController fires
  // its listener on every animation tick during a swipe too — rebuild only
  // once the settled index actually changes.
  int _lastIndex = -1;
  void _onTabChanged() {
    if (widget.controller.indexIsChanging ||
        widget.controller.index != _lastIndex) {
      _lastIndex = widget.controller.index;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.index;

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Shifted in from the leading edge (was flush-left) so the pill row
        // starts a bit further toward the right, like the reference design.
        padding: context.paddingOnly(start: 18, end: 4),
        child: Row(
          children: [
            _pill(
              context,
              index: 0,
              label: StringManager.all.tr(),
              count: widget.allCount,
              selected: selected == 0,
            ),
            8.wBox,
            _pill(
              context,
              index: 1,
              label: StringManager.groups.tr(),
              count: widget.groupsCount,
              selected: selected == 1,
            ),
            8.wBox,
            _pill(
              context,
              index: 2,
              label: ChatStrings.unreadTab,
              count: widget.unreadCount,
              selected: selected == 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required int index,
    required String label,
    required int count,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => widget.controller.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding:
                  context.paddingSymmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: selected ? ColorManager.brandGradient : null,
                color: selected
                    ? null
                    : Colors.black.withValues(alpha: 0.06),
                borderRadius: 24.radius,
                border: selected
                    ? null
                    : Border.all(
                        color: Colors.black.withValues(alpha: 0.18),
                        width: 0.7,
                      ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: ColorManager.brandGradientColors.last
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: context.bodyLarge
                    .size(13)
                    // Selected sits on the brand gradient (white); an
                    // unselected pill is on the white body (black).
                    .colorExt(selected ? Colors.white : Colors.black)
                    .copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
              ),
            ),
            if (count > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  constraints: BoxConstraints(minWidth: 20.w),
                  padding:
                      context.paddingSymmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B5C),
                    borderRadius: 20.radius,
                    border: Border.all(
                      color: ColorManager.white,
                      width: 1.4,
                    ),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: context.bodyMedium
                        .size(10)
                        .w700
                        .colorExt(ColorManager.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
