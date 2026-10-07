part of 'package:general/src/features/home/presentation/home/view/home_page.dart';

class _DiscoverViewBody extends StatefulWidget {
  const _DiscoverViewBody({required this.bloc});

  final HomeBloc bloc;

  @override
  State<_DiscoverViewBody> createState() => _DiscoverViewBodyState();
}

class _DiscoverViewBodyState extends State<_DiscoverViewBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (!di<GetCarouselBloc>().state.discoverState.isLoaded) {
      di<GetCarouselBloc>().add(const GetDiscoverCarouselEvent());
    }
    // Fire the games fetch explicitly (parity with theme2). The BlocConsumer
    // listenWhen below never fires because /my-data is already loaded before
    // this widget builds, so isGameAvailable never "changes".
    if ((di<FetchUserDataBloc>().state.userEntity?.isGameAvailable ?? false) &&
        !di<ExploreBloc>().state.outerReqStateGames.isLoaded) {
      di<ExploreBloc>().add(const FetchGamesEvent(type: 'outer'));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return RefreshIndicatorWidget(
      onRefresh: () async {
        di<GetCarouselBloc>()
            .add(const GetDiscoverCarouselEvent(isLoading: false));
        di<ExploreBloc>().add(
          const FetchGamesEvent(isGamesLoading: false, type: 'outer'),
        );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: widget.bloc.state.globalScrollCtrl,
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
                      prev.outerGames != curr.outerGames ||
                      prev.outerReqStateGames != curr.outerReqStateGames,
                  builder: (context, state) {
                  final hasGames =
                      (state.outerGames?.fullGames?.isNotEmpty ?? false);
                  // No games -> hide the whole section (title included) so
                  // there is no full-screen empty placeholder / overflow.
                  if (!hasGames) return const SizedBox.shrink();
                  return Padding(
                    padding:
                        context.paddingSymmetric(horizontal: 10, vertical: 5),
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
        ],
      ),
    );
  }
}
