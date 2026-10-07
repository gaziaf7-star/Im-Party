part of 'countries_bloc.dart';

sealed class CountriesEvent extends Equatable {
  final CountryEntity? countryEntity,
      countryEntityEditInfo,
      countryEntityNearby,
      countryEntityHot,
      countryEntityRelated;

  const CountriesEvent({
    this.countryEntity,
    this.countryEntityEditInfo,
    this.countryEntityNearby,
    this.countryEntityRelated,
    this.countryEntityHot,
  });

  @override
  List<Object?> get props => [
        countryEntity,
        countryEntityEditInfo,
        countryEntityNearby,
        countryEntityRelated,
        countryEntityHot,
      ];
}

final class FetchCountriesEvent extends CountriesEvent {
  final bool? isLoading;

  const FetchCountriesEvent({this.isLoading = true});
}

final class FetchCountryCategoriesEvent extends CountriesEvent {
  const FetchCountryCategoriesEvent();
}

final class FetchCountriesByCategoryEvent extends CountriesEvent {
  final int categoryId;
  const FetchCountriesByCategoryEvent({required this.categoryId});
}

final class FetchHomeCountriesEvent extends CountriesEvent {
  final int categoryId;
  const FetchHomeCountriesEvent({required this.categoryId});
}

final class SelectedCountryEvent extends CountriesEvent {
  final String countryId;
  final bool? isNullCountry;

  const SelectedCountryEvent({
    this.countryId = '',
    super.countryEntity,
    super.countryEntityNearby,
    this.isNullCountry = false,
  });
}

final class SelectedEditInfoCountryEvent extends CountriesEvent {
  const SelectedEditInfoCountryEvent({
    super.countryEntityEditInfo,
  });
}

final class SelectedCountryFollowingEvent extends CountriesEvent {
  const SelectedCountryFollowingEvent({
    super.countryEntityNearby,
  });
}

final class SelectedCountryPopularEvent extends CountriesEvent {
  const SelectedCountryPopularEvent({
    super.countryEntityHot,
  });
}

final class SelectedCountryGlobalEvent extends CountriesEvent {
  const SelectedCountryGlobalEvent({
    super.countryEntityRelated,
  });
}

final class UnSelectedCountryRelatedEvent extends CountriesEvent {
  const UnSelectedCountryRelatedEvent();
}

final class UnSelectedCountryNearbyEvent extends CountriesEvent {
  const UnSelectedCountryNearbyEvent();
}

final class UnSelectedCountryHotEvent extends CountriesEvent {
  const UnSelectedCountryHotEvent();
}

final class UnSelectedCountryEvent extends CountriesEvent {
  const UnSelectedCountryEvent();
}

final class ShowAllCountryEvent extends CountriesEvent {
  final bool showAll;

  const ShowAllCountryEvent({
    required this.showAll,
  });
}
