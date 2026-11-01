import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';

import 'event_page.dart';
import 'moment_page.dart';

/// Event and Moments behind one bottom-bar destination. The Reels and
/// Following (reels) tabs are hidden on request; the Reels screen is not
/// built at all, so no video player runs behind this page.
class MomentsHubPage extends StatefulWidget {
  const MomentsHubPage({super.key});

  @override
  State<MomentsHubPage> createState() => _MomentsHubPageState();
}

class _MomentsHubPageState extends State<MomentsHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  int _index = 0; // 0 Event, 1 Moments

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    if (_controller.index != _index) {
      setState(() => _index = _controller.index);
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
    return BackgroundImgWidget(
      backgroundGradient: ColorManager.homeBackgroundGradient,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: _HubTabBar(controller: _controller),
            ),
          ),
          Expanded(
            // IndexedStack keeps each feed's scroll position when switching.
            child: IndexedStack(
              index: _index,
              children: const [
                EventPage(),
                MomentPage(showOwnTabBar: false),
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
        indicatorColor: const Color(0xFFF8284D),
        indicatorWidth: 17.w,
        indicatorHeight: 4.h,
        radius: 20,
      ),
      indicatorPadding: EdgeInsets.symmetric(vertical: -2.5.h),
      dividerHeight: 0,
      labelPadding: context.paddingOnly(start: 14),
      // Same as the Home tabs: selected #F8284D, unselected black, bold.
      unselectedLabelStyle: context.bodyMedium.w700
          .colorExt(Colors.black)
          .size(18),
      labelStyle: context.bodyMedium.w800
          .size(21)
          .colorExt(const Color(0xFFF8284D)),
      tabs: [
        Text(StringManager.event.tr()),
        Text(StringManager.moment.tr()),
      ],
    );
  }
}