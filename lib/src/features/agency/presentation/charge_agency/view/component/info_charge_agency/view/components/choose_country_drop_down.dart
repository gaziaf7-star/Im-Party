part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';

class ChooseCountryDropDown extends StatefulWidget {
  // static ValueNotifier<List<int>> selectedCountry = ValueNotifier([]);
  final bool isWithdrawalScreen;
  final List<CountryEntity> countriesList;

  const ChooseCountryDropDown({
    super.key,
    this.isWithdrawalScreen = false,
    this.countriesList = const [],
  });

  @override
  State<ChooseCountryDropDown> createState() => _ChooseCountryDropDownState();
}

class _ChooseCountryDropDownState extends State<ChooseCountryDropDown> {
  final _countriesBloc = di<GetShippingCountriesBloc>();
  @override
  void initState() {

    if (!_countriesBloc.state.status.isLoaded) {
      _countriesBloc.add(const GetGetShippingCountries());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth * 0.9,
      height: 150.h,
      child: BlocBuilder<GetShippingCountriesBloc, GetShippingCountriesState>(
        bloc: _countriesBloc,
        buildWhen: (prev, curr) => prev.status != curr.status || prev.data != curr.data,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.status,
            title: StringManager.noPaymentsTitle.tr(),
            subTitle: StringManager.noCountriesSubTitle.tr(),
            child: ListView.separated(
              padding: context.paddingSymmetric(vertical: 20),
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.withValues(alpha: (0.4)),
                thickness: 0.5,
                height: 15.h,
                endIndent: 20.w,
                indent: 20.w,
              ),
              itemBuilder: (context, index) {
                return RowBuilderWidget(
                  onTap: () {
                    if (widget.isWithdrawalScreen == true) {
                      di<GetShippingAgentsFullDataModelBloc>().add(
                          SelectCountry(
                              country: _countriesBloc.state.data?[index]));
                    } else {
                      di<UpdateChargeAgencyBloc>().add(SelectCountryEvent(
                          country: _countriesBloc.state.data?[index]));
                    }
                  },
                  country: _countriesBloc.state.data?[index],
                  // isWithdrawalScreen: true,
                );
              },
              itemCount: _countriesBloc.state.data?.length ?? 0,
            ),
          );
        },
      ),
    );
  }
}
