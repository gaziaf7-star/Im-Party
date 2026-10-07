import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/main_reels_screen.dart';

import 'event_page.dart';
import 'moment_page.dart';

/// Moments and Reels behind ONE bottom-bar destination.
///
/// They used to be two separate tabs, which cost two of the five slots and left
/// no room for the go-live button in the centre. Both are short-form feeds, so
/// they belong together: this hub keeps one bottom tab and surfaces
/// `Moments | Reels | Following` across the top.
///
/// Reels is kept as a SINGLE [ReelsScreen] instance behind an [IndexedStack]
/// rather than one per tab: the Reels and Following feeds share one
/// GetReelsBloc, so a second instance would fight the first over controllers and
/// playback. The hub's own tabs drive that one instance through
/// [ReelsScreenState.showFeed], and the screen's internal tab bar is hidden so
/// the same control is not drawn twice.
class MomentsHubPage extends StatefulWidget {
  const MomentsHubPage({super.key});

  @override
  State<MomentsHubPage> createState() => _MomentsHubPageState();
}

class _MomentsHubPageState extends State<MomentsHubPage>
    with SingleTickerProviderStateMixin {
  static const int _event = 0;
  // Referenced through _stackFor rather than by name; kept for readability of
  // the index constants above it.
  // ignore: unused_field
  static const int _moments = 1;
  static const int _reels = 2;
  static const int _following = 3;

  /// Position of each tab inside the IndexedStack. Event and Moments have one
  /// child each; Reels and Following share the single ReelsScreen.
  static const List<int> _stackFor = <int>[0, 1, 2, 2];

  late final TabController _controller;
  final GlobalKey<ReelsScreenState> _reelsKey = GlobalKey<ReelsScreenState>();

  int _index = _event;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    final next = _controller.index;
    if (next == _index) return;

    setState(() => _index = next);

    // Both reel tabs render the same screen; tell it which feed to show.
    if (next == _reels) {
      _reelsKey.currentState?.showFeed(ReelsType.forYou);
    } else if (next == _following) {
      _reelsKey.currentState?.showFeed(ReelsType.following);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Same fixed purple->blue->white band as HomePage
    // (ColorManager.homeBackgroundGradient via BackgroundImgWidget), per
    // owner request that Moment match Home's background. This page had no
    // Scaffold/background of its own before — it just sat on whatever
    // LayoutPage's own Scaffold painted behind it (plain white) — so this
    // wraps the existing Column exactly as HomePage wraps its own body,
    // rather than changing anything else about the page.
    return BackgroundImgWidget(
      backgroundGradient: ColorManager.homeBackgroundGradient,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            // A little breathing room from the very top edge — owner asked
            // for this main Event/Moment/Reels/Following bar to come down
            // slightly (it sat flush against the top before).
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: _HubTabBar(controller: _controller),
            ),
          ),
          Expanded(
            // IndexedStack, not TabBarView: swiping between a scrolling moment
            // feed and a full-screen video pager fights for the horizontal drag,
            // and keeping both alive preserves scroll position and avoids
            // re-initialising the video controllers on every switch.
            child: IndexedStack(
              index: _stackFor[_index],
              children: [
                const EventPage(),
                const MomentPage(showOwnTabBar: false),
                ReelsScreen(key: _reelsKey, showOwnTabBar: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTabBar extends StatelessWidget {
  const _HubTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    // Leading gap matches the Home tab bar's own 16.wBox — was flush against
    // the screen edge with no gap at all, out of step with Home's bar sitting
    // just to the right of the edge.
    return Row(
      children: [
        16.wBox,
        Expanded(child: _buildTabBar(context)),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      overlayColor: WidgetStateColor.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      // Fixed white here instead of the panel-driven ColorManager.textPrimary
      // — this tab bar now always sits on the fixed home-style gradient
      // (see MomentsHubPage), so it needs the same fixed-white treatment the
      // Home tab bar already got, not whatever the panel's textPrimary is.
      indicator: MDIndicator(
        indicatorColor: ColorManager.homeHeaderTextColor,
        indicatorWidth: 17.w,
        indicatorHeight: 4.h,
        radius: 20,
      ),
      indicatorPadding: EdgeInsets.symmetric(vertical: -2.5.h),
      dividerHeight: 0,
      labelPadding: context.paddingOnly(start: 14),
      unselectedLabelStyle: context.bodyMedium
          .colorExt(ColorManager.homeHeaderTextColorMuted)
          .size(18),
      labelStyle: context.bodyMedium.w600
          .size(18)
          .colorExt(ColorManager.homeHeaderTextColor),
      tabs: [
        Text(StringManager.event.tr()),
        Text(StringManager.moment.tr()),
        Text(StringManager.reels.tr()),
        Text(StringManager.following.tr()),
      ],
    );
  }
}