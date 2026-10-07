import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/features/games/presentation/meet/meet_page.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/moment/presentation/view/component/add_moment/add_moment_screen.dart';
import 'package:general/src/features/moment/presentation/view/widgets/moment_item.dart';

import '../../../games/presentation/games/bloc/explore/explore_bloc.dart';
import '../bloc/moment_likes_bloc/get_moment_likes_event.dart';
import '../bloc/moment_likes_bloc/moment_likes_bloc_bloc.dart';
import 'component/moment_content/moment_content_screen.dart';

part 'widgets/moment_tab_bar.dart';
part 'widgets/momen_types_tab_bar.dart';
part 'widgets/moment_tab_bar_view_body.dart';

class MomentPage extends StatefulWidget {
  const MomentPage({super.key, this.showOwnTabBar = true});

  /// Whether to draw this page's own `Moment | Online` tab bar.
  ///
  /// False inside the Moments hub, which already puts a tab row above this page.
  /// Three stacked tab rows on one screen — hub tabs, these, and the
  /// Follow/Recommend/Latest filters — is one row too many; the hub owns the top
  /// level, this page keeps its filters.
  final bool showOwnTabBar;

  @override
  State<MomentPage> createState() => _MomentPageState();
}

class _MomentPageState extends State<MomentPage> with TickerProviderStateMixin {
  late final TabController _controller;
  late final TabController _momentTypesController;
  final _bloc = di<MomentBloc>();

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _momentTypesController =
        TabController(length: 3, vsync: this, initialIndex: 1);
    _momentTypesController.addListener(() {
      if (_momentTypesController.index == 0 &&
          !_bloc.state.reqFollowState.isLoaded) {
        _bloc.add(const FetchFollowMomentData(type: '6'));
      } else if (_momentTypesController.index == 1 &&
          !_bloc.state.reqState.isLoaded) {
        _bloc.add(const FetchMomentData());
      } else if (_momentTypesController.index == 2 &&
          !_bloc.state.reqLatestState.isLoaded) {
        _bloc.add(const FetchLatestMomentData(type: '5'));
      }
    });
    if (_bloc.state.isAddMoment == false) {
      _bloc.add(const ChangeRankIconEvent(isAddMoment: true));
    }
    _controller.addListener(() {
      _bloc.add(ChangeRankIconEvent(
          isAddMoment: _controller.index == 0 ? true : false));

      if (!di<ExploreBloc>().state.reqStateUsers.isLoaded) {
        di<ExploreBloc>().add(const FetchUsersEvent());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _momentTypesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      child: BlocBuilder<MomentBloc, MomentStates>(
        bloc: _bloc,
        buildWhen: (prev, curr) =>
        prev.isAddMoment != curr.isAddMoment ||
            prev.reqState != curr.reqState ||
            prev.reqFollowState != curr.reqFollowState ||
            prev.reqLatestState != curr.reqLatestState ||
            prev.moments != curr.moments ||
            prev.followMoments != curr.followMoments ||
            prev.latestMoments != curr.latestMoments ||
            prev.isPaginatingMoment != curr.isPaginatingMoment ||
            prev.isPaginatingFollowMoment != curr.isPaginatingFollowMoment ||
            prev.isPaginatingLatestMoment != curr.isPaginatingLatestMoment,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorManager.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      // Only the standalone MomentPage (own tab bar visible)
                      // keeps the full 15.hBox top gap. Inside the Moments
                      // hub (showOwnTabBar: false) there is no tab bar to
                      // clear here, and the owner asked for the
                      // Follow/Recommend/Latest bar below to rise up even
                      // further than the previous 4.hBox pass — so that case
                      // gets a much smaller top gap instead.
                      widget.showOwnTabBar ? 15.hBox : 6.hBox,
                      if (widget.showOwnTabBar)
                        _MomentTabBar(controller: _controller),
                      const Spacer(),
                    ],
                  ),
                  // Was 4.hBox (before that 20.hBox) — still not high enough
                  // per owner feedback, brought flush against the row above.
                  0.hBox,
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MomentTypesTabBar(
                              controller: _momentTypesController,
                            ),
                            10.hBox,
                            Expanded(
                              child: TabBarView(
                                controller: _momentTypesController,
                                children: [
                                  HandlingDataWidget(
                                    title: StringManager.noMomentsFound.tr(),
                                    subTitle: StringManager
                                        .noMomentsFoundSubTitle
                                        .tr(),
                                    reqState: state.reqFollowState,
                                    // Light-black text + a filled brand-gradient
                                    // Refresh button (was the default black
                                    // text / plain outline button) — matches
                                    // every other page in Moment now.
                                    titleStyle: context.bodyLarge.w600
                                        .colorExt(
                                        ColorManager.momentPostTextColor),
                                    subTitleStyle: context.bodyMedium.copyWith(
                                      color: ColorManager.momentPostTextColor
                                          .withValues(alpha: 0.7),
                                      height: 1.30,
                                    ),
                                    buttonBackgroundColors:
                                    ColorManager.brandGradientColors,
                                    buttonBorderColor:
                                    ColorManager.transparent,
                                    onTap: () {
                                      di<MomentBloc>()
                                          .add(const FetchFollowMomentData());
                                    },
                                    child: MomentTabViewBody(
                                      entity: state.followMoments,
                                      type: MomentType.follow,
                                      reqState: state.reqFollowState,
                                      isPaginating:
                                      state.isPaginatingFollowMoment,
                                    ),
                                  ),
                                  HandlingDataWidget(
                                    title: StringManager.noMomentsFound.tr(),
                                    subTitle: StringManager
                                        .noMomentsFoundSubTitle
                                        .tr(),
                                    reqState: state.reqState,
                                    titleStyle: context.bodyLarge.w600
                                        .colorExt(
                                        ColorManager.momentPostTextColor),
                                    subTitleStyle: context.bodyMedium.copyWith(
                                      color: ColorManager.momentPostTextColor
                                          .withValues(alpha: 0.7),
                                      height: 1.30,
                                    ),
                                    buttonBackgroundColors:
                                    ColorManager.brandGradientColors,
                                    buttonBorderColor:
                                    ColorManager.transparent,
                                    onTap: () {
                                      di<MomentBloc>()
                                          .add(const FetchMomentData());
                                    },
                                    child: MomentTabViewBody(
                                      entity: state.moments,
                                      type: MomentType.recommend,
                                      reqState: state.reqState,
                                      isPaginating: state.isPaginatingMoment,
                                    ),
                                  ),
                                  HandlingDataWidget(
                                    title: StringManager.noMomentsFound.tr(),
                                    subTitle: StringManager
                                        .noMomentsFoundSubTitle
                                        .tr(),
                                    titleStyle: context.bodyLarge.w600
                                        .colorExt(
                                        ColorManager.momentPostTextColor),
                                    subTitleStyle: context.bodyMedium.copyWith(
                                      color: ColorManager.momentPostTextColor
                                          .withValues(alpha: 0.7),
                                      height: 1.30,
                                    ),
                                    buttonBackgroundColors:
                                    ColorManager.brandGradientColors,
                                    buttonBorderColor:
                                    ColorManager.transparent,
                                    onTap: () {
                                      di<MomentBloc>()
                                          .add(const FetchLatestMomentData());
                                    },
                                    reqState: state.reqLatestState,
                                    child: MomentTabViewBody(
                                      entity: state.latestMoments,
                                      type: MomentType.latest,
                                      reqState: state.reqLatestState,
                                      isPaginating:
                                      state.isPaginatingLatestMoment,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const MeetPage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: _controller.index == 0
                ? GestureDetector(
              onTap: () {
                di<MomentBloc>().add(const InitializeFormEvent());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMomentScreen(),
                  ),
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // Home-page gradient (was the flat panel-driven
                  // ColorManager.primary) — requested to match the
                  // add-moment button's colour to the Home page's own
                  // background.
                  gradient: ColorManager.homeBackgroundGradient,
                ),
                child: CircleAvatar(
                  backgroundColor: ColorManager.transparent,
                  radius: 30.r,
                  child: Image.asset(
                    AssetsManager.sendIcon,
                    height: 38,
                    width: 38,
                    fit: BoxFit.fill,
                    color: ColorManager.white,
                  ),
                ),
              ),
            )
                : null,
          );
        },
      ),
    );
  }
}