import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/components/local_countries.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/country_widget_item_dialog.dart';

import '../../../../../../core/index.dart';

class CountriesDialog extends StatelessWidget {
  const CountriesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final countries = LocalCountries.all;
    return Container(
      height: 350.h,
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        // Match the app body: paint the panel body gradient instead of a flat
        // white/transparent sheet, so the dialog blends with the home scaffold.
        gradient: ColorManager.bodyBackgroundGradient,
        borderRadius: BorderRadius.only(
          topLeft: 10.radiusCircular,
          topRight: 10.radiusCircular,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.paddingSymmetric(horizontal: 10, vertical: 15),
            child: TextWidget(
              StringManager.countries.tr(),
              style: context.bodyMedium.w600.colorExt(ColorManager.textPrimary),
            ),
          ),
          Expanded(
            child: BlocBuilder<CountriesBloc, CountriesState>(
              bloc: di<CountriesBloc>(),
              buildWhen: (prev, curr) =>
                  prev.countryEntity != curr.countryEntity ||
                  prev.countryId != curr.countryId,
              builder: (context, state) =>
                  _buildCountriesList(context, countries, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesList(
    BuildContext context,
    List<CountryEntity> countries,
    CountriesState state,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      padding: context.paddingAll(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.40,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
      ),
      itemCount: countries.length + 1,
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
