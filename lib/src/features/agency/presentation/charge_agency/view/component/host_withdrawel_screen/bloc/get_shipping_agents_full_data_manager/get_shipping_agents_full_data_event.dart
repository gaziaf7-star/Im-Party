part of 'get_shipping_agents_full_data_bloc.dart';

abstract class GetShippingAgentsFullDataModelEvent extends Equatable {
  const GetShippingAgentsFullDataModelEvent();

  @override
  List<Object?> get props => [];
}

class GetAgentsFullData extends GetShippingAgentsFullDataModelEvent {
  final FetchShippingAgentsFullDataModelParam? param;
  final bool? isFirstLoading;

  const GetAgentsFullData({this.param, this.isFirstLoading=false});

  @override
  List<Object?> get props => [param, isFirstLoading];
}

class ShowPayments extends GetShippingAgentsFullDataModelEvent {

  const ShowPayments();

}
// Show/Unshow Countries
class ShowCountries extends GetShippingAgentsFullDataModelEvent {

  const ShowCountries();

}

// Select/Unselect Payment
class SelectPayment extends GetShippingAgentsFullDataModelEvent {
  final PaymentsGetwaysEntity? paymentMethod;

  const SelectPayment({required this.paymentMethod});

  @override
  List<Object?> get props => [paymentMethod];
}


// Select/Unselect Country
class SelectCountry extends GetShippingAgentsFullDataModelEvent {
  final CountryEntity? country;

  const SelectCountry({required this.country});

  @override
  List<Object?> get props => [country];
}
class LoadMoreAgentsFullData extends GetShippingAgentsFullDataModelEvent {
  const LoadMoreAgentsFullData();
}

class ClearSelection extends GetShippingAgentsFullDataModelEvent {

  const ClearSelection();

  @override
  List<Object?> get props => [];
}
