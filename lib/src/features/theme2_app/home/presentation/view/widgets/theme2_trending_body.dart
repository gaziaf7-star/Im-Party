import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/carousel_widget.dart';
import 'package:general/src/features/auth/presentation/country/bloc/countries_bloc.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/components/theme2_room_card.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/widgets/theme2_filter_row.dart';

class Theme2TrendingBody extends StatefulWidget {
  final HomeBloc bloc;
  const Theme2TrendingBody({super.key, required this.bloc});

  @override
  State<Theme2TrendingBody> createState() => _Theme2TrendingBodyState();
}

class _Theme2TrendingBodyState extends State<Theme2TrendingBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static final _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10.h,
    crossAxisSpacing: 10.w,
    childAspectRatio: 0.75,
  );

  void _onViewToggled() => setState(() {});

  void _navigateToRoom(BuildContext context, RoomEntity room) {
    // Video live is removed: live rooms are not enterable. Ignore the tap.
    if (room.streamType == "live") return;
    if (di<FetchUserDataBloc>().state.reqState.isLoaded) {
      di<RoomStateManager>().navigateToRoom(
        RoomEntryRequest(
          context: context,
          roomData: room,
          isLive: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<CountriesBloc, CountriesState>(
      bloc: di<CountriesBloc>(),
      buildWhen: (prev, curr) => prev.countryEntity != curr.countryEntity,
      builder: (context, countryState) {
        final hasCountryFilter = countryState.countryEntity != null;

        if (hasCountryFilter) {
          return _buildFilteredByCountry(context, countryState);
        }

        return _buildPopularRooms(context);
      },
    );
  }

  /// Shows rooms filtered by the selected country
  Widget _buildFilteredByCountry(
      BuildContext context, CountriesState countryState) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: widget.bloc,
      buildWhen: (prev, curr) =>
          prev.filteredRooms != curr.filteredRooms ||
          prev.reqStateFilter != curr.reqStateFilter ||
          prev.isPaginatingFilter != curr.isPaginatingFilter,
      builder: (context, homeState) {
        final rooms = homeState.filteredRooms;
        final count = rooms.length;
        const firstGridCount = 4;
        final firstItemCount =
            count >= firstGridCount ? firstGridCount : count;
        final secondItemCount =
            count > firstGridCount ? count - firstGridCount : 0;

        return RefreshIndicatorWidget(
          onRefresh: () async {
            final countryId = countryState.countryEntity?.id;
            widget.bloc.add(FilterPopularRoomsEvent(
                isLoading: false, countryId: countryId, isFirstPage: true));
            di<GetCarouselBloc>().add(GetCountryCarouselEvent(
                isLoading: false, countryId: '$countryId'));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: homeState.filterScrollCtrl,
            cacheExtent: 250,
            slivers: [
              SliverToBoxAdapter(
                child: Theme2FilterRow(onViewToggled: _onViewToggled),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingSymmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: const CarouselWidget(
                      type: "noEvent",
                      source: 'country',
                      isNeedLoadingWidget: false,
                    ),
                  ),
                ),
              ),

              if (homeState.reqStateFilter.isLoading ||
                  homeState.reqStateFilter.isError ||
                  count == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: context.paddingSymmetric(horizontal: 10),
                    child: HandlingDataWidget(
                      reqState: homeState.reqStateFilter,
                      title: StringManager.noRooms.tr(),
                      subTitle: StringManager.noRoomsMsg.tr(),
                      onTap: () => widget.bloc.add(FilterPopularRoomsEvent(
                          countryId: countryState.countryEntity?.id,
                          isFirstPage: true)),
                      childEmpty: const SizedBox(),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),

              if (firstItemCount > 0 && homeState.reqStateFilter.isLoaded)
                ConstantsManager.isShowGridView
                    ? SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 10),
                        sliver: SliverGrid.builder(
                          itemCount: firstItemCount,
                          gridDelegate: _gridDelegate,
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: Theme2RoomCard(
                                key: ValueKey('jo_filter_${rooms[index].id}'),
                                roomEntity: rooms[index],
                              ),
                            );
                          },
                        ),
                      )
                    : SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 0),
                        sliver: SliverList.separated(
                          itemCount: firstItemCount,
                          separatorBuilder: (_, __) => 10.hBox,
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: GestureDetector(
                                onTap: () => _navigateToRoom(context, rooms[index]),
                                child: CardLiveWidget(
                                  key: ValueKey('jo_filter_${rooms[index].id}'),
                                  roomEntity: rooms[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

              if (secondItemCount > 0)
                ConstantsManager.isShowGridView
                    ? SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 10),
                        sliver: SliverGrid.builder(
                          itemCount: secondItemCount,
                          gridDelegate: _gridDelegate,
                          itemBuilder: (context, index) {
                            final room = rooms[index + firstGridCount];
                            return RepaintBoundary(
                              child: Theme2RoomCard(
                                key: ValueKey('jo_filter_${room.id}'),
                                roomEntity: room,
                              ),
                            );
                          },
                        ),
                      )
                    : SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 0),
                        sliver: SliverList.separated(
                          itemCount: secondItemCount,
                          separatorBuilder: (_, __) => 10.hBox,
                          itemBuilder: (context, index) {
                            final room = rooms[index + firstGridCount];
                            return RepaintBoundary(
                              child: GestureDetector(
                                onTap: () => _navigateToRoom(context, room),
                                child: CardLiveWidget(
                                  key: ValueKey('jo_filter_${room.id}'),
                                  roomEntity: room,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

              if (homeState.isPaginatingFilter)
                const SliverToBoxAdapter(child: CircleLoadingWidget()),

              SliverToBoxAdapter(child: 80.hBox),
            ],
          ),
        );
      },
    );
  }

  /// Shows all popular rooms (no country filter)
  Widget _buildPopularRooms(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: widget.bloc,
      buildWhen: (prev, curr) =>
          prev.popular != curr.popular ||
          prev.reqStatePopular != curr.reqStatePopular ||
          prev.isPaginatingPopular != curr.isPaginatingPopular,
      builder: (context, homeState) {
        final rooms = homeState.popular;
        final count = rooms.length;
        const firstGridCount = 4;
        final firstItemCount =
            count >= firstGridCount ? firstGridCount : count;
        final secondItemCount =
            count > firstGridCount ? count - firstGridCount : 0;

        return RefreshIndicatorWidget(
          onRefresh: () async {
            widget.bloc.add(const FetchPopularRoomsEvent(
                isPopularLoading: false, isFirstPage: true));
            di<GetCarouselBloc>()
                .add(const GetHomeTopCarouselEvent(isLoading: false));
            di<GetCarouselBloc>()
                .add(const GetHomeMiddleCarouselEvent(isLoading: false));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: homeState.popularScrollCtrl,
            cacheExtent: 250,
            slivers: [
              SliverToBoxAdapter(
                child: Theme2FilterRow(onViewToggled: _onViewToggled),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingSymmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: const CarouselWidget(
                      type: "noEvent",
                      source: 'homeMiddle',
                      isNeedLoadingWidget: false,
                    ),
                  ),
                ),
              ),

              if (homeState.reqStatePopular.isLoading ||
                  homeState.reqStatePopular.isError ||
                  count == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: context.paddingSymmetric(horizontal: 10),
                    child: HandlingDataWidget(
                      reqState: homeState.reqStatePopular,
                      title: StringManager.noRooms.tr(),
                      subTitle: StringManager.noRoomsMsg.tr(),
                      onTap: () => widget.bloc
                          .add(const FetchPopularRoomsEvent(isFirstPage: true)),
                      childEmpty: const SizedBox(),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),

              if (firstItemCount > 0 && homeState.reqStatePopular.isLoaded)
                ConstantsManager.isShowGridView
                    ? SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 10),
                        sliver: SliverGrid.builder(
                          itemCount: firstItemCount,
                          gridDelegate: _gridDelegate,
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: Theme2RoomCard(
                                key: ValueKey('jo_room_${rooms[index].id}'),
                                roomEntity: rooms[index],
                              ),
                            );
                          },
                        ),
                      )
                    : SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 0),
                        sliver: SliverList.separated(
                          itemCount: firstItemCount,
                          separatorBuilder: (_, __) => 10.hBox,
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: GestureDetector(
                                onTap: () => _navigateToRoom(context, rooms[index]),
                                child: CardLiveWidget(
                                  key: ValueKey('jo_room_${rooms[index].id}'),
                                  roomEntity: rooms[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

              if (secondItemCount > 0)
                ConstantsManager.isShowGridView
                    ? SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 10),
                        sliver: SliverGrid.builder(
                          itemCount: secondItemCount,
                          gridDelegate: _gridDelegate,
                          itemBuilder: (context, index) {
                            final room = rooms[index + firstGridCount];
                            return RepaintBoundary(
                              child: Theme2RoomCard(
                                key: ValueKey('jo_room_${room.id}'),
                                roomEntity: room,
                              ),
                            );
                          },
                        ),
                      )
                    : SliverPadding(
                        padding: context.paddingSymmetric(horizontal: 0),
                        sliver: SliverList.separated(
                          itemCount: secondItemCount,
                          separatorBuilder: (_, __) => 10.hBox,
                          itemBuilder: (context, index) {
                            final room = rooms[index + firstGridCount];
                            return RepaintBoundary(
                              child: GestureDetector(
                                onTap: () => _navigateToRoom(context, room),
                                child: CardLiveWidget(
                                  key: ValueKey('jo_room_${room.id}'),
                                  roomEntity: room,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

              if (homeState.isPaginatingPopular)
                const SliverToBoxAdapter(child: CircleLoadingWidget()),

              SliverToBoxAdapter(child: 80.hBox),
            ],
          ),
        );
      },
    );
  }
}
