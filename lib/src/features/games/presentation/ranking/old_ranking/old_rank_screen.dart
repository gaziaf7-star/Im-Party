import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/family/domain/entities/family_rank_entity.dart';
import 'package:general/src/features/games/domain/entities/agency_ranking_entity.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/games/presentation/ranking/old_ranking/agency_rank/old_agency_rank_container_widget.dart';
import 'package:general/src/features/games/presentation/ranking/old_ranking/agency_rank/old_top_three_agency_widget.dart';
import 'widgets/old_rank_tab_bar.dart';

part 'components/old_center_shadow_body.dart';
part 'agency_rank/old_rank_agency_body.dart';
part 'components/old_inner_tab_bar.dart';
part 'components/old_rank_body.dart';
part 'components/old_rank_container_widget.dart';
part 'widgets/old_item_rank_top_three.dart';
part 'widgets/old_top_three_widget.dart';
part 'widgets/old_user_info_rank_widget.dart';

class OldRankScreen extends StatefulWidget {
  final int? initialIndex;

  const OldRankScreen({this.initialIndex, super.key});

  @override
  State<OldRankScreen> createState() => OldRankScreenState();
}

class OldRankScreenState extends State<OldRankScreen>
    with TickerProviderStateMixin {
  late final TabController _rankController;
  late final TabController _charmController;
  late final TabController _roomController;
  late final TabController _wealthController;
  late final TabController _gameController;
  late final TabController _agencyController;
  late final TabController _luckyController;
  static late ValueNotifier<int> innerTabNotifier;

  int? _lastTabIndex;
  DateTime? _lastTabChange;
  static const Duration _tabDebounceDuration = Duration(milliseconds: 350);
  final List<VoidCallback> _controllerListeners = [];

  /// Old UI background colors per rank index.
  static const _oldBackgroundColors = <int, Color>{
    0: Color(0xffE0D6FF),
    1: Color(0xffDCB483),
    2: Color(0xffCBEEDB),
  };

  Color _oldBgColor(int index) =>
      _oldBackgroundColors[index] ?? const Color(0xff7468FB);

  @override
  void initState() {
    super.initState();
    innerTabNotifier = ValueNotifier<int>(0);
    _rankController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
    _wealthController = TabController(length: 4, vsync: this);
    _charmController = TabController(length: 4, vsync: this);
    _roomController = TabController(length: 4, vsync: this);
    _gameController = TabController(length: 4, vsync: this);
    _agencyController = TabController(length: 4, vsync: this);
    _luckyController = TabController(length: 4, vsync: this);

    _handleImagesSelection();
    _fetchIfNeeded(widget.initialIndex ?? 0);

    _rankController.addListener(() {
      if (!_rankController.indexIsChanging) {
        final now = DateTime.now();
        if (_lastTabIndex == _rankController.index &&
            _lastTabChange != null &&
            now.difference(_lastTabChange!) < _tabDebounceDuration) {
          return;
        }
        _lastTabIndex = _rankController.index;
        _lastTabChange = now;
        _handleImagesSelection();
        _fetchIfNeeded(_rankController.index);
        switch (_rankController.index) {
          case 0:
            innerTabNotifier.value = _roomController.index;
            break;
          case 1:
            innerTabNotifier.value = _wealthController.index;
            break;
          case 2:
            innerTabNotifier.value = _charmController.index;
            break;
          case 3:
            innerTabNotifier.value = _gameController.index;
            break;
          case 4:
            innerTabNotifier.value = _agencyController.index;
            break;
          case 5:
            innerTabNotifier.value = _luckyController.index;
            break;
        }
      }
    });

    attach(_wealthController);
    attach(_charmController);
    attach(_roomController);
    attach(_gameController);
    attach(_agencyController);
    attach(_luckyController);
  }

  void attach(TabController controller) {
    void listener() {
      if (!controller.indexIsChanging) {
        innerTabNotifier.value = controller.index;
      }
    }

    controller.addListener(listener);
    _controllerListeners.add(listener);
  }

  @override
  void dispose() {
    final controllers = [
      _rankController,
      _wealthController,
      _charmController,
      _roomController,
      _gameController,
      _agencyController,
      _luckyController,
    ];

    // _controllerListeners only tracks inner controllers added via attach()
    final innerControllers = controllers.sublist(1);
    for (int i = 0; i < innerControllers.length; i++) {
      innerControllers[i].removeListener(_controllerListeners[i]);
    }

    for (final c in controllers) {
      c.dispose();
    }

    innerTabNotifier.dispose();
    super.dispose();
  }

  void _handleImagesSelection() {
    di<RankingBloc>()
        .add(HandleInfoCurrentRankEvent(currentIndex: _rankController.index));
  }

  void _fetchIfNeeded(int index) {
    final bloc = di<RankingBloc>();
    switch (index) {
      case 0:
        if (bloc.state.rDState != RequestState.loaded &&
            bloc.state.rDState != RequestState.loading) {
          bloc.add(const FetchRoomsDayEvent());
        }
        if (bloc.state.rWState != RequestState.loaded &&
            bloc.state.rWState != RequestState.loading) {
          bloc.add(const FetchRoomWeeklyEvent());
        }
        if (bloc.state.rMState != RequestState.loaded &&
            bloc.state.rMState != RequestState.loading) {
          bloc.add(const FetchRoomMonthlyEvent());
        }
        if (bloc.state.rhState != RequestState.loaded &&
            bloc.state.rhState != RequestState.loading) {
          bloc.add(const FetchRoomHourEvent());
        }
        break;
      case 1:
        if (bloc.state.cDState != RequestState.loaded &&
            bloc.state.cDState != RequestState.loading) {
          bloc.add(const FetchCoinsDayEvent());
        }
        if (bloc.state.cWState != RequestState.loaded &&
            bloc.state.cWState != RequestState.loading) {
          bloc.add(const FetchCoinsWeeklyEvent());
        }
        if (bloc.state.cMState != RequestState.loaded &&
            bloc.state.cMState != RequestState.loading) {
          bloc.add(const FetchCoinsMonthlyEvent());
        }
        if (bloc.state.chState != RequestState.loaded &&
            bloc.state.chState != RequestState.loading) {
          bloc.add(const FetchCoinsHourEvent());
        }
        break;
      case 2:
        if (bloc.state.dDState != RequestState.loaded &&
            bloc.state.dDState != RequestState.loading) {
          bloc.add(const FetchDiamondsDayEvent());
        }
        if (bloc.state.dWState != RequestState.loaded &&
            bloc.state.dWState != RequestState.loading) {
          bloc.add(const FetchDiamondsWeeklyEvent());
        }
        if (bloc.state.dMState != RequestState.loaded &&
            bloc.state.dMState != RequestState.loading) {
          bloc.add(const FetchDiamondsMonthlyEvent());
        }
        if (bloc.state.dhState != RequestState.loaded &&
            bloc.state.dhState != RequestState.loading) {
          bloc.add(const FetchDiamondsHourEvent());
        }
        break;
      case 3:
        if (bloc.state.gDState != RequestState.loaded &&
            bloc.state.gDState != RequestState.loading) {
          bloc.add(const FetchGamersDayEvent());
        }
        if (bloc.state.gWState != RequestState.loaded &&
            bloc.state.gWState != RequestState.loading) {
          bloc.add(const FetchGamersWeeklyEvent());
        }
        if (bloc.state.gMState != RequestState.loaded &&
            bloc.state.gMState != RequestState.loading) {
          bloc.add(const FetchGamersMonthlyEvent());
        }
        if (bloc.state.ghState != RequestState.loaded &&
            bloc.state.ghState != RequestState.loading) {
          bloc.add(const FetchGamersHourEvent());
        }
        break;
      case 4:
        if (bloc.state.agencyDState != RequestState.loaded &&
            bloc.state.agencyDState != RequestState.loading) {
          bloc.add(const FetchAgencyDayEvent());
        }
        if (bloc.state.agencyWState != RequestState.loaded &&
            bloc.state.agencyWState != RequestState.loading) {
          bloc.add(const FetchAgencyWeeklyEvent());
        }
        if (bloc.state.agencyMState != RequestState.loaded &&
            bloc.state.agencyMState != RequestState.loading) {
          bloc.add(const FetchAgencyMonthlyEvent());
        }
        if (bloc.state.agencyHState != RequestState.loaded &&
            bloc.state.agencyHState != RequestState.loading) {
          bloc.add(const FetchAgencyHourEvent());
        }
        break;
      case 5:
        if (bloc.state.lDState != RequestState.loaded &&
            bloc.state.lDState != RequestState.loading) {
          bloc.add(const FetchLuckyDayEvent());
        }
        if (bloc.state.lWState != RequestState.loaded &&
            bloc.state.lWState != RequestState.loading) {
          bloc.add(const FetchLuckyWeeklyEvent());
        }
        if (bloc.state.lMState != RequestState.loaded &&
            bloc.state.lMState != RequestState.loading) {
          bloc.add(const FetchLuckyMonthlyEvent());
        }
        if (bloc.state.lhState != RequestState.loaded &&
            bloc.state.lhState != RequestState.loading) {
          bloc.add(const FetchLuckyHourEvent());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingBloc, RankingStates>(
      bloc: di<RankingBloc>(),
      builder: (context, state) {
        // Use old background colors
        final bgColor = _oldBgColor(state.index);

        final overlayColor = state.index == 0
            ? const Color(0xffFFC73A).withValues(alpha: 0.4)
            : state.index == 1
                ? const Color(0xffFFE83A).withValues(alpha: 0.4)
                : state.index == 2
                    ? const Color(0xffFDA057).withValues(alpha: 0.4)
                    : const Color(0xff7468FB).withValues(alpha: 0.1);

        final centerShadowColor = state.index == 0
            ? const Color(0xffFFC73A)
            : state.index == 1
                ? const Color(0xffFEE93A)
                : state.index == 2
                    ? const Color(0xffFDA057)
                    : const Color(0xff7468FB);

        return Scaffold(
          backgroundColor: ColorManager.transparent,
          body: Container(
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            decoration: BoxDecoration(color: bgColor),
            child: Stack(
              children: [
                Image.asset(
                  AssetsManager.rankBackground,
                  fit: BoxFit.fill,
                  height: ScreenUtil().screenHeight,
                  width: ScreenUtil().screenWidth,
                  filterQuality: FilterQuality.low,
                ),
                Container(
                  height: ScreenUtil().screenHeight,
                  width: ScreenUtil().screenWidth,
                  color: overlayColor,
                ),
                Positioned(
                  bottom: 320.h,
                  left: 70.h,
                  right: 70.h,
                  child: OldCenterShadowBody(
                    color: centerShadowColor,
                  ),
                ),
                Column(
                  children: [
                    AppBarWidget(
                      title: StringManager.ranking.tr(),
                      backgroundColor: ColorManager.transparent,
                      titleStyle: context.titleLarge.bold
                          .colorExt(ColorManager.white),
                      iconColor: ColorManager.white,
                    ),
                    OldTopTabBar(
                        controller: _rankController, fromRoom: false),
                    Expanded(
                      child: TabBarView(
                        controller: _rankController,
                        children: [
                          OldRankBody(
                            rankController: _rankController,
                            controller: _roomController,
                            reqStateHour: state.rhState,
                            reqStateDay: state.rDState,
                            reqStateWeak: state.rWState,
                            reqStateMonth: state.rMState,
                            usersRankHour: state.usersRankRh,
                            usersRankDay: state.usersRankRD,
                            usersRankWeak: state.usersRankRW,
                            usersRankMonth: state.usersRankRM,
                            index: 0,
                            imageRank: state.imageRank,
                            color: bgColor,
                            onTapHour: () => di<RankingBloc>()
                                .add(const FetchRoomHourEvent()),
                            onTapDay: () => di<RankingBloc>()
                                .add(const FetchRoomsDayEvent()),
                            onTapWeek: () => di<RankingBloc>()
                                .add(const FetchRoomWeeklyEvent()),
                            onTapMonthly: () => di<RankingBloc>()
                                .add(const FetchRoomMonthlyEvent()),
                            isPhoto: _rankController.index != 0,
                          ),
                          OldRankBody(
                            rankController: _rankController,
                            controller: _wealthController,
                            reqStateHour: state.chState,
                            reqStateDay: state.cDState,
                            reqStateWeak: state.cWState,
                            reqStateMonth: state.cMState,
                            usersRankHour: state.usersRankCh,
                            usersRankDay: state.usersRankCD,
                            usersRankWeak: state.usersRankCW,
                            usersRankMonth: state.usersRankCM,
                            index: 1,
                            imageRank: state.imageRank,
                            color: bgColor,
                            onTapHour: () => di<RankingBloc>()
                                .add(const FetchCoinsHourEvent()),
                            onTapDay: () => di<RankingBloc>()
                                .add(const FetchCoinsDayEvent()),
                            onTapWeek: () => di<RankingBloc>()
                                .add(const FetchCoinsWeeklyEvent()),
                            onTapMonthly: () => di<RankingBloc>()
                                .add(const FetchCoinsMonthlyEvent()),
                            isPhoto: _rankController.index != 1,
                          ),
                          OldRankBody(
                            rankController: _rankController,
                            controller: _charmController,
                            reqStateHour: state.dhState,
                            reqStateDay: state.dDState,
                            reqStateWeak: state.dWState,
                            reqStateMonth: state.dMState,
                            usersRankHour: state.usersRankDh,
                            usersRankDay: state.usersRankDD,
                            usersRankWeak: state.usersRankDW,
                            usersRankMonth: state.usersRankDM,
                            index: 2,
                            imageRank: state.imageRank,
                            color: bgColor,
                            onTapHour: () => di<RankingBloc>()
                                .add(const FetchDiamondsHourEvent()),
                            onTapDay: () => di<RankingBloc>()
                                .add(const FetchDiamondsDayEvent()),
                            onTapWeek: () => di<RankingBloc>()
                                .add(const FetchDiamondsWeeklyEvent()),
                            onTapMonthly: () => di<RankingBloc>()
                                .add(const FetchDiamondsMonthlyEvent()),
                            isPhoto: _rankController.index != 2,
                          ),
                          OldRankBody(
                            rankController: _rankController,
                            controller: _gameController,
                            reqStateHour: state.ghState,
                            reqStateDay: state.gDState,
                            reqStateWeak: state.gWState,
                            reqStateMonth: state.gMState,
                            usersRankHour: state.usersRankGh,
                            usersRankDay: state.usersRankGD,
                            usersRankWeak: state.usersRankGW,
                            usersRankMonth: state.usersRankGM,
                            index: 3,
                            imageRank: state.imageRank,
                            color: bgColor,
                            onTapHour: () => di<RankingBloc>()
                                .add(const FetchGamersHourEvent()),
                            onTapDay: () => di<RankingBloc>()
                                .add(const FetchGamersDayEvent()),
                            onTapWeek: () => di<RankingBloc>()
                                .add(const FetchGamersWeeklyEvent()),
                            onTapMonthly: () => di<RankingBloc>()
                                .add(const FetchGamersMonthlyEvent()),
                            isPhoto: _rankController.index != 3,
                          ),
                          OldRankAgencyBody(
                            controller: _agencyController,
                            rankController: _rankController,
                            reqStateHour: state.agencyHState,
                            reqStateDay: state.agencyDState,
                            reqStateWeak: state.agencyWState,
                            reqStateMonth: state.agencyMState,
                            usersAgencyRankHour: state.usersRankAgencyH,
                            usersAgencyRankDay: state.usersRankAgencyD,
                            usersAgencyRankWeek: state.usersRankAgencyW,
                            usersAgencyRankMonth: state.usersRankAgencyM,
                            index: 4,
                            imageRank: state.imageRank,
                            color: bgColor,
                            onTapHour: () => di<RankingBloc>()
                                .add(const FetchAgencyHourEvent()),
                            onTapDay: () => di<RankingBloc>()
                                .add(const FetchAgencyDayEvent()),
                            onTapWeek: () => di<RankingBloc>()
                                .add(const FetchAgencyWeeklyEvent()),
                            onTapMonthly: () => di<RankingBloc>()
                                .add(const FetchAgencyMonthlyEvent()),
                            isPhoto: _rankController.index != 4,
                          ),
                          OldRankBody(
                            rankController: _rankController,
                            controller: _luckyController,
                            reqStateHour: state.lhState,
                            reqStateDay: state.lDState,
                            reqStateWeak: state.lWState,
                            reqStateMonth: state.lMState,
                            usersRankHour: state.usersRankLh,
                            usersRankDay: state.usersRankLD,
                            usersRankWeak: state.usersRankLW,
                            usersRankMonth: state.usersRankLM,
                            index: 5,
                            imageRank: state.imageRank,
                            color: bgColor,
                            onTapHour: () => di<RankingBloc>()
                                .add(const FetchLuckyHourEvent()),
                            onTapDay: () => di<RankingBloc>()
                                .add(const FetchLuckyDayEvent()),
                            onTapWeek: () => di<RankingBloc>()
                                .add(const FetchLuckyWeeklyEvent()),
                            onTapMonthly: () => di<RankingBloc>()
                                .add(const FetchLuckyMonthlyEvent()),
                            isPhoto: _rankController.index != 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
