// part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';
//
//
// class CountriesOuterBody extends StatefulWidget {
//   const CountriesOuterBody({super.key});
//
//   @override
//   State<CountriesOuterBody> createState() => CountriesOuterBodyState();
// }
//
// class CountriesOuterBodyState extends State<CountriesOuterBody> {
//   final _countriesBloc = di<GetShippingCountriesBloc>();
//   static final ValueNotifier<CountryEntity> country =
//       ValueNotifier(const CountryEntity(id: 0));
//   @override
//   void initState() {
//     if (!_countriesBloc.state.status.isLoaded) {
//       _countriesBloc.add(const GetGetShippingCountries());
//     }
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GetShippingCountriesBloc, GetShippingCountriesState>(
//       bloc: _countriesBloc,
//       builder: (context, state) {
//         return HandlingDataWidget(
//             reqState: state.status,
//             title: StringManager.noPaymentsTitle.tr(),
//             subTitle: StringManager.noCountriesSubTitle.tr(),
//             child: ValueListenableBuilder(
//               valueListenable: country,
//               builder: (context, value, _) =>
//                   ExpandableWidget<CountryEntity>(
//                 data: state.data ??
//                     [] /*  [
//                 GetCountryEntity(id: 0, name: "Egypt"),
//                 GetCountryEntity(id: 1, name: "Saudi"),
//                               ] */
//                 ,
//                 title: country.value.name != null
//                     ? '${country.value.name}'
//                     : StringManager.chooseYourCountry.tr(),
//                 // isSelected: country.value.name != null,
//                 // isShowSearch: true,
//                 borderColor: ColorManager.lightOrange.withValues(alpha:0.8),
//                 backgroundColor: ColorManager.scaffoldBg,
//                 borderRadius: 50.radius,
//
//                 titlleColor: Colors.grey,
//                 maxHeight: 120.h,
//                 onSelectedValue: (value) {
//                   country.value = value;
//                 },
//               ),
//             ));
//       },
//     );
//   }
// }
