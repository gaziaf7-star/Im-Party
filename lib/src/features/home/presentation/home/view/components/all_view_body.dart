part of 'package:general/src/features/home/presentation/home/view/home_page.dart';

class _AllViewBody extends StatefulWidget {
  const _AllViewBody({required this.bloc});

  final HomeBloc bloc;

  @override
  State<_AllViewBody> createState() => _AllViewBodyState();
}

class _AllViewBodyState extends State<_AllViewBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Cache grid delegates
  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.9,
  );

  static const _listGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 5,
    crossAxisSpacing: 5,
    childAspectRatio: 0.9,
  );

  /// How many party rows show before the live strip and the second banner
  /// interrupt the list.
  static const int _roomsBeforeInterlude = 4;

  @override
  void initState() {
    super.initState();
    // The banner that breaks up the party list uses the `live` carousel slot,
    // and GetLiveCarouselEvent was only ever dispatched from the Live tab — so
    // on this tab the slot had no data and the banner silently rendered nothing.
    // Ask for it here too, once.
    if (!di<GetCarouselBloc>().state.liveState.isLoaded) {
      di<GetCarouselBloc>().add(const GetLiveCarouselEvent(isLoading: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Country selection drives an in-place filter: when a country is selected
    // the body shows the filtered rooms + country banners, otherwise it shows
    // the popular rooms + home banners (same layout, switched data source).
    return BlocBuilder<CountriesBloc, CountriesState>(
      bloc: di<CountriesBloc>(),
      buildWhen: (prev, curr) => prev.countryEntity != curr.countryEntity,
      builder: (context, countryState) {
        final hasCountryFilter = countryState.countryEntity != null;
        return _buildBody(context, hasCountryFilter, countryState);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool hasCountryFilter,
    CountriesState countryState,
  ) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: widget.bloc,
      buildWhen: (previous, current) =>
          previous.popular != current.popular ||
          previous.reqStatePopular != current.reqStatePopular ||
          previous.isPaginatingPopular != current.isPaginatingPopular ||
          previous.filteredRooms != current.filteredRooms ||
          previous.reqStateFilter != current.reqStateFilter ||
          previous.isPaginatingFilter != current.isPaginatingFilter,
      builder: (context, homeState) {
        final popular =
            hasCountryFilter ? homeState.filteredRooms : homeState.popular;
        final isPaginating = hasCountryFilter
            ? homeState.isPaginatingFilter
            : homeState.isPaginatingPopular;
        final scrollCtrl = hasCountryFilter
            ? homeState.filterScrollCtrl
            : homeState.popularScrollCtrl;
        final middleCarouselSource =
            hasCountryFilter ? 'country' : 'homeMiddle';
        final total = popular.length;

        // Pre-calculate top rooms count
        final topCount = ConstantsManager.isShowGridView ? 4 : 3;
        final topThreeRooms =
            total <= topCount ? popular : popular.take(topCount).toList();

        // Calculate item count for the rooms list (rooms after top 3 + 1 for carousel)
        final roomsItemCount = total <= topCount ? 0 : (total - topCount);

        return RefreshIndicatorWidget(
          onRefresh: () async {
            if (hasCountryFilter) {
              final countryId = countryState.countryEntity?.id;
              widget.bloc.add(FilterPopularRoomsEvent(
                isLoading: false,
                isFirstPage: true,
                countryId: countryId,
              ));
              di<GetCarouselBloc>().add(GetCountryCarouselEvent(
                isLoading: false,
                countryId: '$countryId',
              ));
              return;
            }
            di<CountriesBloc>()
                .add(const FetchCountryCategoriesEvent());
            di<GetCarouselBloc>()
                .add(const GetHomeTopCarouselEvent(isLoading: false));
            di<GetCarouselBloc>()
                .add(const GetHomeMiddleCarouselEvent(isLoading: false));
            di<CountriesBloc>().add(const UnSelectedCountryHotEvent());
            widget.bloc.add(
              const FetchPopularRoomsEvent(
                isPopularLoading: true,
                isFirstPage: true,
              ),
            );
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollCtrl,
            slivers: [
              SliverToBoxAdapter(
                child: 3.hBox,
              ),
              // Wide banner. Height is derived from the available width and the
              // artwork's aspect ratio (HomeBannerMetrics) rather than a fixed
              // design height, so the image covers its box exactly instead of
              // leaving a strip of page showing underneath. Same side inset as
              // the card row below, so the two line up on both edges.
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingSymmetric(
                    horizontal: HomeBannerMetrics.edge,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(HomeBannerMetrics.radius),
                    child: CarouselWidget(
                      type: "event",
                      source: 'homeTop',
                      height: HomeBannerMetrics.bannerHeight(),
                    ),
                  ),
                ),
              ),
              // Section order, top to bottom:
              //   wide banner -> pair of half cards -> country filter ->
              //   featured top-three -> room list
              // The star-ranking strip (SRRCarouselWidget) used to sit here,
              // between the banner and the rooms, which pushed the country
              // filter and the room list below the fold. It is reached from the
              // ranking button in the header instead.
              SliverToBoxAdapter(
                child: SizedBox(height: HomeBannerMetrics.gapBannerToCards),
              ),
              // Two fixed slots, each sliding through its own share of the
              // home_middle items. When a country filter is on, that slot is
              // reused for the country banner, which is a single full-width
              // image — so keep the old carousel for that case.
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingSymmetric(
                    horizontal: HomeBannerMetrics.edge,
                  ),
                  child: middleCarouselSource == 'homeMiddle'
                      // Was HomeMiddlePair (the 2 promo banners) -- replaced
                      // with the Gift/CP/Family ranking cards row, on request.
                      ? const HomeRankingCardsRow()
                      : CarouselWidget(
                          type: "noEvent",
                          source: middleCarouselSource,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: HomeBannerMetrics.gapCardsToFilter),
              ),
              SliverAppBar(
                toolbarHeight: 30.h,
                collapsedHeight: 35.h,
                expandedHeight: 30.h,
                backgroundColor: ColorManager.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: CountriesBody(
                    // Moved onto the country row itself, right after the
                    // arrow filter button, on request -- was its own row
                    // underneath.
                    isShowGridView: ConstantsManager.isShowGridView,
                    onToggleGridView: () {
                      setState(() {
                        ConstantsManager.isShowGridView =
                            !ConstantsManager.isShowGridView;
                      });
                      HiveManager().saveData(
                        KeysManager.USER_BOX,
                        KeysManager.IS_SHOW_GRID_VIEW_KEY,
                        ConstantsManager.isShowGridView,
                      );
                    },
                  ),
                ),
                pinned: false,
                floating: false,
                primary: false,
              ),
              SliverToBoxAdapter(
                child: 10.hBox,
              ),

              ConstantsManager.isShowGridView
                  ? BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
                      bloc: di<FetchUserDataBloc>(),
                      buildWhen: (previous, current) =>
                          previous.reqState != current.reqState,
                      builder: (context, userState) {
                        final isLoaded =
                            userState.reqState == RequestState.loaded;
                        return SliverPadding(
                          padding: context.paddingOnly(
                            bottom: 10.h,
                            end: 8.w,
                            top: 10.h,
                            start: 8.w,
                          ),
                          sliver: SliverGrid.builder(
                            itemCount: topThreeRooms.length,
                            gridDelegate: _gridDelegate,
                            itemBuilder: (context, index) => RepaintBoundary(
                              child: MultiTapCard(
                                onTap: () {
                                  if (isLoaded) {
                                    di<RoomStateManager>().navigateToRoom(
                                      RoomEntryRequest(
                                        context: context,
                                        roomData: topThreeRooms[index],
                                        isLive: false,
                                      ),
                                    );
                                  }
                                },
                                child: NewRoomCardWidget(
                                  roomEntity: topThreeRooms[index],
                                  isShowSVGA: true,
                                  rank: index + 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : SliverToBoxAdapter(
                      child: TopThreeRoomBody(rooms: topThreeRooms),
                    ),
              if (Platform.isIOS) SliverToBoxAdapter(child: 10.hBox),
              // The country filter and the middle carousel both moved above the
              // featured block; only the spacing before the room list is left.
              SliverToBoxAdapter(
                child: 10.hBox,
              ),
              // Use SliverList instead of ListView inside SliverToBoxAdapter for better performance
              if (roomsItemCount > 0)
                ConstantsManager.isShowGridView
                    ? BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
                        bloc: di<FetchUserDataBloc>(),
                        buildWhen: (previous, current) =>
                            previous.reqState != current.reqState,
                        builder: (context, userState) {
                          final isLoaded =
                              userState.reqState == RequestState.loaded;
                          return SliverPadding(
                            padding: context.paddingOnly(
                              bottom: 70.h,
                              end: 10.w,
                              start: 10.w,
                            ),
                            sliver: SliverGrid.builder(
                              itemCount: roomsItemCount,
                              gridDelegate: _listGridDelegate,
                              itemBuilder: (context, index) {
                                final roomIndex = index + topCount;
                                if (roomIndex >= total) {
                                  return const SizedBox.shrink();
                                }

                                final room = popular[roomIndex];
                                return RepaintBoundary(
                                  child: MultiTapCard(
                                    onTap: () {
                                      if (isLoaded) {
                                        di<RoomStateManager>().navigateToRoom(
                                          RoomEntryRequest(
                                            context: context,
                                            roomData: room,
                                            isLive: false,
                                          ),
                                        );
                                      }
                                    },
                                    child: NewRoomCardWidget(
                                      roomEntity: room,
                                      isShowSVGA: false,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
                        bloc: di<FetchUserDataBloc>(),
                        buildWhen: (previous, current) =>
                            previous.reqState != current.reqState,
                        builder: (context, userState) {
                          final isLoaded =
                              userState.reqState == RequestState.loaded;
                          return SliverPadding(
                            padding: context.paddingOnly(bottom: 70),
                            sliver: SliverList.separated(
                              itemCount: roomsItemCount,
                              separatorBuilder: (context, index) => 10.hBox,
                              itemBuilder: (context, index) {
                                final roomIndex = index + topCount;
                                if (roomIndex >= total) {
                                  return const SizedBox.shrink();
                                }

                                final room = popular[roomIndex];
                                final card = RepaintBoundary(
                                  child: MultiTapCard(
                                    onTap: () {
                                      if (isLoaded) {
                                        di<RoomStateManager>().navigateToRoom(
                                          RoomEntryRequest(
                                            context: context,
                                            roomData: room,
                                            isLive: room.streamType == "live",
                                          ),
                                        );
                                      }
                                    },
                                    child: CardLiveWidget(
                                      roomEntity: room,
                                      index: roomIndex,
                                      // All text on this card forced black,
                                      // on request.
                                      forceBlackText: true,
                                    ),
                                  ),
                                );

                                // After the fourth party row the feed breaks for
                                // one panel banner, sized and inset exactly like
                                // the one at the top of the page, then carries on
                                // with the rest of the rooms.
                                //
                                // Rendered inline in this item rather than as its
                                // own sliver so the list keeps one index space
                                // and one set of separators.
                                if (index != _roomsBeforeInterlude - 1) {
                                  return card;
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    card,
                                    SizedBox(
                                        height: HomeBannerMetrics
                                            .gapBannerToCards),
                                    Padding(
                                      padding: context.paddingSymmetric(
                                        horizontal: HomeBannerMetrics.edge,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            HomeBannerMetrics.radius),
                                        child: CarouselWidget(
                                          type: "noEvent",
                                          source: 'live',
                                          height: HomeBannerMetrics
                                              .bannerHeight(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      )
              else
                SliverPadding(
                  padding: context.paddingOnly(bottom: 70),
                  sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
              if (isPaginating)
                const SliverToBoxAdapter(
                  child: CircleLoadingWidget(),
                ),
            ],
          ),
        );
      },
    );
  }
}
