part of 'countries_bloc.dart';

class CountriesState extends Equatable {
  final RequestState requestState;
  final RequestState categoriesRequestState;
  final RequestState countriesByCategoryRequestState;
  final RequestState homeCountriesRequestState;
  final String countryId;
  final List<CountryEntity> countries;
  final List<CountryCategoryEntity> categories;
  final List<CountryEntity> countriesByCategory;
  final List<CountryEntity> homeCountries;
  final int? selectedCategoryId;
  final TextEditingController controller, controllerEditInfo;
  final CountryEntity? countryEntity,
      countryEntityHot,
      countryEntityRelated,
      countryEntityNearby,
      countryEntityEditInfo;
  final bool isShowMore;

  const CountriesState({
    this.requestState = RequestState.idle,
    this.categoriesRequestState = RequestState.idle,
    this.countriesByCategoryRequestState = RequestState.idle,
    this.homeCountriesRequestState = RequestState.idle,
    this.countries = const [],
    this.categories = const [],
    this.countriesByCategory = const [],
    this.homeCountries = const [],
    this.selectedCategoryId,
    required this.controller,
    required this.controllerEditInfo,
    this.countryEntity,
    this.countryEntityHot,
    this.countryEntityRelated,
    this.countryEntityNearby,
    this.countryEntityEditInfo,
    this.isShowMore = false,
    this.countryId = '',
  });

  CountriesState copyWith({
    RequestState? requestState,
    RequestState? categoriesRequestState,
    RequestState? countriesByCategoryRequestState,
    RequestState? homeCountriesRequestState,
    List<CountryEntity>? countries,
    List<CountryEntity>? countries2,
    List<CountryCategoryEntity>? categories,
    List<CountryEntity>? countriesByCategory,
    List<CountryEntity>? homeCountries,
    int? selectedCategoryId,
    String? controller,
    String? countryId,
    String? controllerEditInfo,
    CountryEntity? countryEntity,
    CountryEntity? countryEntityHot,
    CountryEntity? countryEntityRelated,
    CountryEntity? countryEntityNearby,
    CountryEntity? countryEntityEditInfo,
    bool isNullCountry = false,
    bool isNullCountryGlobal = false,
    bool isNullCountryPopular = false,
    bool isNullCountryFollowing = false,
    bool? isShowMore,
  }) {
    return CountriesState(
      countryId: countryId ?? this.countryId,
      requestState: requestState ?? this.requestState,
      categoriesRequestState:
          categoriesRequestState ?? this.categoriesRequestState,
      countriesByCategoryRequestState: countriesByCategoryRequestState ??
          this.countriesByCategoryRequestState,
      homeCountriesRequestState:
          homeCountriesRequestState ?? this.homeCountriesRequestState,
      countries: countries ?? this.countries,
      categories: categories ?? this.categories,
      countriesByCategory: countriesByCategory ?? this.countriesByCategory,
      homeCountries: homeCountries ?? this.homeCountries,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      controller: this.controller.copyWith(text: controller),
      controllerEditInfo:
          this.controllerEditInfo.copyWith(text: controllerEditInfo),
      countryEntity: isNullCountry ? null : countryEntity ?? this.countryEntity,
      countryEntityRelated: isNullCountryGlobal
          ? null
          : countryEntityRelated ?? this.countryEntityRelated,
      countryEntityHot: isNullCountryPopular
          ? null
          : countryEntityHot ?? this.countryEntityHot,
      countryEntityNearby: isNullCountryFollowing
          ? null
          : countryEntityNearby ?? this.countryEntityNearby,
      countryEntityEditInfo:
          countryEntityEditInfo ?? this.countryEntityEditInfo,
      isShowMore: isShowMore ?? this.isShowMore,
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        categoriesRequestState,
        countriesByCategoryRequestState,
        homeCountriesRequestState,
        isShowMore,
        countries,
        categories,
        countriesByCategory,
        homeCountries,
        selectedCategoryId,
        controller,
        countryEntity,
        countryEntityHot,
        countryEntityRelated,
        countryEntityEditInfo,
        controllerEditInfo,
        countryId,
      ];
}
