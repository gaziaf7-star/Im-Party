part of'get_shipping_countries_bloc.dart';

abstract class GetShippingCountriesEvent extends Equatable {
  const GetShippingCountriesEvent();

  @override
  List<Object?> get props => [];
}

class GetGetShippingCountries extends GetShippingCountriesEvent {
  const GetGetShippingCountries();
}
