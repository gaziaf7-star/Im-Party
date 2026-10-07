
import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_shipping_agents_full_data_manager/get_shipping_agents_full_data_bloc.dart';
import 'package:general/src/features/auth/presentation/country/bloc/countries_bloc.dart';

class CountrySelectWidget extends StatelessWidget {
  const CountrySelectWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetShippingAgentsFullDataModelBloc,
        GetShippingAgentsFullDataModelState>(
      bloc: di<GetShippingAgentsFullDataModelBloc>(),
      buildWhen: (prev, curr) => prev.selectedCountry != curr.selectedCountry,
      builder: (context, state) {
        return BlocBuilder<CountriesBloc, CountriesState>(
          bloc: di<CountriesBloc>(),
          buildWhen: (prev, curr) => prev.countryEntity != curr.countryEntity || prev.countries != curr.countries,
          builder: (context, state) {
            return InkWell(
              onTap: () {
                state.countryEntity == null
                    ? di<GetShippingAgentsFullDataModelBloc>().add(
                    SelectCountry(country: state.countries[0]))
                    //
                    // di<CountriesBloc>().add(
                    //   SelectedCountryEvent(
                    //     countryEntity: state.countries?[0],
                    //   ),
                    // )
                    : null;
                Methods.showCupertinoCountriesPicker(
                  context: context,
                  isFirstOpen: true,
                  onChanged: (value) {




                    di<GetShippingAgentsFullDataModelBloc>().add(
                        SelectCountry(country: state.countries[value]));



                  },
                  children:
                      List.generate(state.countries.length , (index) {
                    return TextWidget(
                      state.countries[index].name ?? "",
                      style: context.bodyLarge,
                    );
                  }),
                );
                // context.pushNamedRoute(Routes.countriesScreen,
                //     arguments: true);

                // if (isWithdrawalScreen == true) {
                //   di<GetShippingAgentsFullDataModelBloc>().add(const ShowCountries());
                //
                //
                // } else {
                //   di<UpdateChargeAgencyBloc>().add(const ShowCountriesEvent());
                // }
              },
              child: Container(
                width: ScreenUtil().screenWidth,
                padding: context.paddingSymmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey.withValues(alpha: (0.2 ))))),
                child:
                    TextWidget(
                  ((di<GetShippingAgentsFullDataModelBloc>()
                                  .state
                                  .selectedCountry
                                  ?.name ??
                              '') !=
                          '')
                      ? di<GetShippingAgentsFullDataModelBloc>()
                          .state
                          .selectedCountry!
                          .name!
                      : StringManager.chooseMoneyCountry.tr(),
                      style: context.bodyLarge.colorExt(
                        ColorManager.secondaryText,
                      ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
