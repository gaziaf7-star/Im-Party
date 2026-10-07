part of 'package:general/src/features/home/presentation/home/view/home_page.dart';

class CountriesBody extends StatefulWidget {
  final bool? isFromExplore;

  /// When set, a small grid/list toggle button is rendered right after the
  /// arrow filter button, on the same row -- on request, so it sits at the
  /// country row's right side instead of on its own row underneath.
  final VoidCallback? onToggleGridView;
  final bool isShowGridView;

  const CountriesBody({
    super.key,
    this.isFromExplore = false,
    this.onToggleGridView,
    this.isShowGridView = false,
  });

  @override
  State<CountriesBody> createState() => CountriesBodyState();
}

class CountriesBodyState extends State<CountriesBody> {
  @override
  void initState() {
    super.initState();
    final bloc = di<CountriesBloc>();
    if (!bloc.state.categoriesRequestState.isLoaded) {
      bloc.add(const FetchCountryCategoriesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = di<CountriesBloc>();
    return BlocBuilder<CountriesBloc, CountriesState>(
      bloc: bloc,
      buildWhen: (previous, current) =>
      previous.homeCountries != current.homeCountries ||
          previous.homeCountriesRequestState !=
              current.homeCountriesRequestState ||
          previous.countryEntity != current.countryEntity ||
          previous.countryId != current.countryId,
      builder: (context, state) {
        return Padding(
          padding: context.paddingSymmetric(horizontal: 10),
          child: HandlingDataWidget(
            reqState: state.homeCountriesRequestState,
            title: StringManager.noCountries.tr(),
            subTitle: StringManager.noCountriesMsg.tr(),
            // Was the generic spinning GradientLoader -- a same-size/shape
            // white shimmer row of pill placeholders instead, on request.
            isNeedLoadingWidget: false,
            onTap: () {
              bloc.add(const FetchCountryCategoriesEvent());
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  // Was a fixed 340.w -- with the toggle/arrow buttons now
                  // sharing this row, a fixed width overflowed the row on
                  // narrower screens (the buttons got pushed off the right
                  // edge). Expanded shrinks the scrollable list to whatever
                  // space is actually left.
                  child: SizedBox(
                  height: 40.h,
                  child: state.homeCountriesRequestState.isLoading
                      ? const _CountriesShimmerRow()
                      : ListView.builder(
                    shrinkWrap: true,
                    padding: context.paddingZero(),
                    scrollDirection: Axis.horizontal,
                    // +1 for the Global entry that leads the row. It is not a
                    // country and must not come from the backend list, because
                    // "no filter" has no country_id to send.
                    itemCount: state.homeCountries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CountryWidget(
                          isGlobal: true,
                          // Selected whenever no country filter is applied.
                          isSelected: state.countryId == '',
                          onTap: () {
                            if (state.countryId == '') return;
                            di<CountriesBloc>()
                                .add(const UnSelectedCountryEvent());
                            // countryId omitted, not zero: the room endpoint
                            // treats a present-but-empty country_id as a filter
                            // for country 0 and returns nothing.
                            di<HomeBloc>().add(
                              const FilterPopularRoomsEvent(
                                isLoading: false,
                                isFirstPage: true,
                              ),
                            );
                            di<GetCarouselBloc>()
                                .add(const ResetCountryCarouselEvent());
                          },
                        );
                      }
                      final country = state.homeCountries[index - 1];
                      return CountryWidget(
                        countryEntity: country,
                        onTap: () {

                          // Tapping a country applies an in-place filter
                          // (rooms + banners) on the current page -> no dialog,
                          // no webview.
                          di<CountriesBloc>().add(
                            SelectedCountryEvent(
                              countryId: '${country.id}',
                              countryEntity: country,
                            ),
                          );
                          di<HomeBloc>().add(
                            FilterPopularRoomsEvent(
                              isLoading: false,
                              isFirstPage: true,
                              countryId: country.id,
                            ),
                          );
                          di<GetCarouselBloc>().add(
                            GetCountryCarouselEvent(
                              isLoading: false,
                              countryId: '${country.id}',
                            ),
                          );
                        },
                        isSelected: state.countryEntity?.id == country.id &&
                            state.countryId != '',
                      );
                    },
                  ),
                  ),
                ),
                SizedBox(
                  height: 26.h,
                  child: GestureDetector(
                    onTap: () {
                      // Was bottomDailog(CountriesDialog()) — a slide-up
                      // panel — now a real full page (on request).
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CountryFilterPage(),
                        ),
                      );
                    },
                    child: Container(
                      margin: context.paddingSymmetric(horizontal: 3.0),
                      padding: context.paddingAll(4.0),
                      decoration: BoxDecoration(
                        // Rounded tab-pill look, gold ring + brand gradient --
                        // matching the reference CP-style tab bar (Personal/
                        // Moment/Gift pills), on request.
                        borderRadius: 14.radius,
                        gradient: ColorManager.brandGradient,
                        border: Border.all(
                          color: const Color(0xE6FFD98A),
                          width: 1.6,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: ColorManager.onBrandGradient,
                          size: 12.h,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.onToggleGridView != null) ...[
                  4.wBox,
                  SizedBox(
                    height: 26.h,
                    child: GestureDetector(
                      onTap: widget.onToggleGridView,
                      child: Container(
                        margin: context.paddingSymmetric(horizontal: 3.0),
                        padding: context.paddingAll(4.0),
                        decoration: BoxDecoration(
                          borderRadius: 14.radius,
                          gradient: ColorManager.brandGradient,
                          border: Border.all(
                            color: const Color(0xE6FFD98A),
                            width: 1.6,
                          ),
                        ),
                        child: Icon(
                          widget.isShowGridView
                              ? Icons.grid_view_rounded
                              : Icons.view_list_rounded,
                          color: ColorManager.onBrandGradient,
                          size: 14.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Same height/shape as the real country pills, white shimmer -- shown
/// while the country row is loading, on request (was a generic centered
/// spinner that didn't match the row's own layout at all).
class _CountriesShimmerRow extends StatelessWidget {
  const _CountriesShimmerRow();

  static const List<double> _widths = [70, 55, 65, 50, 75, 60];

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.35),
      highlightColor: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        padding: context.paddingZero(),
        scrollDirection: Axis.horizontal,
        itemCount: _widths.length,
        itemBuilder: (context, index) => Container(
          height: 26.h,
          width: _widths[index].w,
          margin: context.paddingSymmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: 20.radius,
          ),
        ),
      ),
    );
  }
}