import 'package:general/src/features/home/home.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_event.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_top_ranking_manager/fetch_top_ranking_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/daily_prize/bloc/daily_prizes_bloc.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/auth/presentation/country/bloc/countries_bloc.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/widgets/theme2_header_bar.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/widgets/theme2_trending_body.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/widgets/theme2_discover_body.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/widgets/theme2_related_body.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/widgets/theme2_lives_body.dart';

class Theme2HomePage extends StatefulWidget {
  const Theme2HomePage({super.key});

  @override
  State<Theme2HomePage> createState() => _Theme2HomePageState();
}

class _Theme2HomePageState extends State<Theme2HomePage>
    with TickerProviderStateMixin {
  late final TabController _parentTabController;
  final _bloc = di<HomeBloc>();

  @override
  void initState() {
    super.initState();
    _parentTabController = TabController(
      // +1 tab (لايف) appended at index 3 when live is enabled.
      length: ConstantsManager.isShowLive ? 4 : 3,
      vsync: this,
      initialIndex: 1, // ترند = default
    );

    // Phase 1: Critical data
    if (!_bloc.state.reqStatePopular.isLoaded &&
        ConstantsManager.isAudioRoomsEnabled) {
      _bloc.add(const FetchPopularRoomsEvent(isPopularLoading: true));
    }

    if (!di<GetCarouselBloc>().state.reqStateHomeTop.isLoaded) {
      di<GetCarouselBloc>().add(const GetHomeTopCarouselEvent());
    }

    if (ConstantsManager.isAudioRoomsEnabled) {
      _bloc.add(const PopularAddListenerEvent());
    }

    // Phase 2: Secondary data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!di<FetchMyRoomDataBloc>().state.requestState.isLoaded) {
        di<FetchMyRoomDataBloc>().add(const FetchMyRoomDataEvent());
      }
      if (!di<CountriesBloc>().state.categoriesRequestState.isLoaded) {
        di<CountriesBloc>().add(const FetchCountryCategoriesEvent());
      }
      if (!di<DailyPrizesBloc>().state.requestStateGetPrize.isLoaded) {
        di<DailyPrizesBloc>().add(GetDailyPrizesEvent(context: context));
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!di<GetCarouselBloc>().state.reqStateHomeMiddle.isLoaded) {
          di<GetCarouselBloc>().add(const GetHomeMiddleCarouselEvent());
        }
        if (!di<FetchTopUserImageBloc>().state.requestState.isLoaded) {
          di<FetchTopUserImageBloc>().add(const FetchTopUserImageEvent());
        }
      });
    });

    _parentTabController.addListener(_tabListener);
  }

  void _tabListener() {
    // Live<->Discover swapped: Live (when present) is index 2, Discover is the
    // last tab (index 3 when live is shown, otherwise index 2).
    const int liveIndex = 2;
    final int discoverIndex = ConstantsManager.isShowLive ? 3 : 2;
    final int index = _parentTabController.index;

    if (index == 0) {
      // Related tab
      if (!_bloc.state.reqStateFollow.isLoaded) {
        _bloc.add(const FetchFollowRoomsEvent());
        _bloc.add(const FollowAddListenerEvent());
      }
    } else if (index == discoverIndex) {
      // Discover tab — games + discover banners only (rooms removed).
      if (!di<GetCarouselBloc>().state.discoverState.isLoaded) {
        di<GetCarouselBloc>().add(const GetDiscoverCarouselEvent());
      }
      // Load games
      if (!di<ExploreBloc>().state.outerReqStateGames.isLoaded) {
        di<ExploreBloc>().add(const FetchGamesEvent(type: 'outer'));
      }
    } else if (ConstantsManager.isShowLive && index == liveIndex) {
      // Live tab (only present when ConstantsManager.isShowLive)
      if (!_bloc.state.reqStateLive.isLoaded) {
        _bloc.add(const FetchLiveRoomsEvent());
      }
      _bloc.add(const LiveAddListenerEvent());
    }
  }

  @override
  void dispose() {
    _parentTabController.removeListener(_tabListener);
    _parentTabController.dispose();
    if (ConstantsManager.isAudioRoomsEnabled) {
      _bloc.add(const PopularRemoveListenerEvent());
    }
    _bloc.add(const FollowRemoveListenerEvent());
    _bloc.add(const GlobalRemoveListenerEvent());
    if (ConstantsManager.isShowLive) {
      _bloc.add(const LiveRemoveListenerEvent());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      child: Scaffold(
        floatingActionButton: BlocBuilder<FetchUserDataBloc,
            FetchUserDataState>(
          bloc: di<FetchUserDataBloc>(),
          buildWhen: (prev, curr) =>
              prev.userEntity?.isGameAvailable !=
              curr.userEntity?.isGameAvailable,
          builder: (context, state) {
            if (state.userEntity?.isGameAvailable == true) {
              return GestureDetector(
                onTap: () {
                  context.pushNamedRoute(Routes.gamesPage);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorManager.primary,
                  ),
                  child: CircleAvatar(
                    backgroundColor: ColorManager.transparent,
                    radius: 30.r,
                    child: Image.asset(
                      AssetsManager.gameIconHome,
                      height: 38,
                      width: 38,
                      fit: BoxFit.fill,
                      color: ColorManager.buttonTextColor,
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ─── Header: Tabs + Icons ──────────────────────
              Theme2HeaderBar(
                controller: _parentTabController,
                bloc: _bloc,
              ),
              // ─── Tab Content ───────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _parentTabController,
                  children: [
                    // Tab 0: متعلق (Related)
                    Theme2RelatedBody(bloc: _bloc),
                    // Tab 1: ترند (Trending) - Default
                    Theme2TrendingBody(bloc: _bloc),
                    // Tab 2: لايف (Live) — open live rooms (swapped before
                    // Discover; only present when live is enabled).
                    if (ConstantsManager.isShowLive)
                      Theme2LivesBody(bloc: _bloc),
                    // Tab 3 (or 2): إكتشف (Discover) — now the last tab.
                    Theme2DiscoverBody(bloc: _bloc),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
