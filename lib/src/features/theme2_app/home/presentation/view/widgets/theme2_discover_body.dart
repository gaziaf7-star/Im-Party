import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/carousel_widget.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/games/presentation/games/view/widgets/games_grid_widget.dart';

class Theme2DiscoverBody extends StatefulWidget {
  final HomeBloc bloc;

  const Theme2DiscoverBody({
    super.key,
    required this.bloc,
  });

  @override
  State<Theme2DiscoverBody> createState() => _Theme2DiscoverBodyState();
}

class _Theme2DiscoverBodyState extends State<Theme2DiscoverBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicatorWidget(
      onRefresh: () async {
        di<GetCarouselBloc>().add(
          const GetDiscoverCarouselEvent(isLoading: false),
        );

        di<ExploreBloc>().add(
          const FetchGamesEvent(
            isGamesLoading: false,
            type: 'outer',
          ),
        );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: widget.bloc.state.globalScrollCtrl,
        cacheExtent: 250,
        slivers: [
          SliverToBoxAdapter(
            child: BlocConsumer<FetchUserDataBloc, FetchUserDataState>(
              bloc: di<FetchUserDataBloc>(),
              listenWhen: (prev, curr) =>
                  prev.userEntity?.isGameAvailable !=
                  curr.userEntity?.isGameAvailable,
              listener: (context, userState) {
                if ((userState.userEntity?.isGameAvailable ?? false) &&
                    !di<ExploreBloc>().state.outerReqStateGames.isLoaded) {
                  di<ExploreBloc>().add(const FetchGamesEvent(type: 'outer'));
                }
              },
              buildWhen: (prev, curr) =>
                  prev.userEntity?.isGameAvailable !=
                  curr.userEntity?.isGameAvailable,
              builder: (context, userState) {
                if (!(userState.userEntity?.isGameAvailable ?? false)) {
                  return const SizedBox.shrink();
                }
                return BlocBuilder<ExploreBloc, ExploreState>(
                  bloc: di<ExploreBloc>(),
                  buildWhen: (prev, curr) =>
                      prev.outerReqStateGames != curr.outerReqStateGames ||
                      prev.outerGames != curr.outerGames,
                  builder: (context, state) {
                    final hasGames =
                        (state.outerGames?.fullGames?.isNotEmpty ?? false);
                    // No games -> hide the whole section (title included) so
                    // there is no full-screen empty placeholder / overflow.
                    if (!hasGames) return const SizedBox.shrink();
                    return Padding(
                      padding: context.paddingSymmetric(
                          horizontal: 10, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                context.pushNamedRoute(Routes.gamesPage),
                            child: TextWidget(
                              StringManager.recommendedGames.tr(),
                              style: context.bodyMedium.bold.size(15),
                            ),
                          ),
                          8.hBox,
                          GamesGridWidget(
                            bloc: di<ExploreBloc>(),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
              child: const DiscoverCarouselList(),
            ),
          ),
          SliverToBoxAdapter(child: 85.hBox),
        ],
      ),
    );
  }
}
