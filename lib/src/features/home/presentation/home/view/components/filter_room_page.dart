import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/carousel_widget.dart';

class FilterRoomPage extends StatefulWidget {
  const FilterRoomPage({super.key, required this.param});

  final FilterRoomsParam param;

  @override
  State<FilterRoomPage> createState() => _FilterRoomPageState();
}

class _FilterRoomPageState extends State<FilterRoomPage> {
  final bloc = di<HomeBloc>();

  @override
  void initState() {
    di<HomeBloc>().add(
      FilterPopularRoomsEvent(
        countryId: widget.param.countryId,
      ),
    );

    di<GetCarouselBloc>().add(
      GetCountryCarouselEvent(
        isLoading: true,
        countryId: widget.param.countryId.toString(),
      ),
    );
    bloc.add(const FilterAddListenerEvent());
    super.initState();
  }

  @override
  void dispose() {
    di<GetCarouselBloc>().add(const ResetCountryCarouselEvent());
    bloc.add(const FilterRemoveListenerEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.param.title,
        titleStyle: context.titleLarge.w600.copyWith(fontSize: 16.sp),
        backgroundColor: ColorManager.scaffoldBgAlt,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          di<HomeBloc>().add(
            FilterPopularRoomsEvent(countryId: widget.param.countryId),
          );
          di<GetCarouselBloc>().add(GetCountryCarouselEvent(
              isLoading: true, countryId: widget.param.countryId.toString()));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingSymmetric(horizontal: 15),
                child: const CarouselWidget(type: "noEvent", source: 'country'),
              ),
            ),
            SliverPadding(padding: EdgeInsets.only(top: 10.h)),
            BlocBuilder<HomeBloc, HomeState>(
              bloc: di<HomeBloc>(),
              buildWhen: (prev, curr) =>
                  prev.reqStateFilter != curr.reqStateFilter ||
                  prev.filteredRooms != curr.filteredRooms,
              builder: (context, state) {
                return SliverToBoxAdapter(
                  child: HandlingDataWidget(
                    reqState: state.reqStateFilter,
                    title: StringManager.noRooms.tr(),
                    subTitle: StringManager.noRoomsMsg.tr(),
                    child: ListView.separated(
                      itemCount: state.filteredRooms.length,
                      padding: context.paddingZero(),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => 10.hBox,
                      itemBuilder: (context, index) {
                        return MultiTapCard(
                          onTap: () {
                            di<RoomStateManager>().navigateToRoom(
                              RoomEntryRequest(
                                context: context,
                                roomData: state.filteredRooms[index],
                                isLive: state.filteredRooms[index].streamType == "live",
                              ),
                            );
                          },
                          child: CardLiveWidget(
                            roomEntity: state.filteredRooms[index],
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
