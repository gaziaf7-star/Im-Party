import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/components/local_countries.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/country_widget_item_dialog.dart';

import '../../../../../../core/index.dart';

/// The country/region filter, opened from the Home page's "world" icon (and
/// the country strip's arrow-forward button).
///
/// Was `CountriesDialog` — a small panel slid up from the bottom edge via
/// `bottomDailog()` (a `showGeneralDialog` + slide animation, visually a
/// bottom sheet). On request this is now a real full page instead: pushed
/// with `Navigator.push`, with a normal back-arrow + "Country" app bar, a
/// plain white background, and no floating panel/rounded-top-corners look.
/// The actual list content/filtering logic underneath (`_buildCountriesList`,
/// `CountryWidgetItemDialog`, the `CountriesBloc`/`HomeBloc` events on tap)
/// is unchanged — only the container around it changed from a dialog to a
/// page.
class CountryFilterPage extends StatelessWidget {
  const CountryFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final countries = LocalCountries.all;
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        iconColor: Colors.black,
        title: StringManager.countries.tr(),
        titleStyle: TextStyle(color: Colors.black),
        backgroundColor: ColorManager.white,
      ),
      body: BlocBuilder<CountriesBloc, CountriesState>(
        bloc: di<CountriesBloc>(),
        buildWhen: (prev, curr) =>
        prev.countryEntity != curr.countryEntity ||
            prev.countryId != curr.countryId,
        builder: (context, state) => _buildCountriesList(context, countries, state),
      ),
    );
  }

  Widget _buildCountriesList(
      BuildContext context,
      List<CountryEntity> countries,
      CountriesState state,
      ) {
    // Was a 2-column GridView of flag+supporters cards — on request this is
    // now a plain single-column list matching the reference image: just the
    // country name and a selection circle per row, with a thin divider
    // between rows.
    return ListView.separated(
      itemCount: countries.length + 1,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: ColorManager.momentPostTextColor.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, index) {
        // Leading "Recommended" entry: clears the country filter so home
        // shows the recommended/trending rooms from ALL countries.
        if (index == 0) {
          return CountryWidgetItemDialog(
            label: StringManager.recommend_.tr(),
            isSelected: state.countryId == '',
            onTap: () {
              context.popRoute();

              // Clear the country filter -> home shows recommended/trending
              // rooms from ALL countries (no specific country).
              di<CountriesBloc>().add(
                const SelectedCountryEvent(
                  countryId: '',
                  isNullCountry: true,
                ),
              );
              di<HomeBloc>().add(
                const FilterPopularRoomsEvent(
                  isLoading: true,
                  isFirstPage: true,
                  countryId: null,
                ),
              );
              di<GetCarouselBloc>().add(const ResetCountryCarouselEvent());
            },
          );
        }

        final country = countries[index - 1];
        return CountryWidgetItemDialog(
          countryEntity: country,
          onTap: () {
            context.popRoute();

            // Tapping a country applies an in-place filter (rooms + banners)
            // on the current page across all themes -> no dialog, no webview.
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
    );
  }
}