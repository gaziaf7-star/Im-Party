


part of'get_shipping_countries_bloc.dart';

class GetShippingCountriesState extends Equatable {
  final RequestState status;
  final List<CountryEntity>? data;
  final String? error;

  const GetShippingCountriesState({
    this.status = RequestState.idle,
    this.data,
    this.error,
  });

  GetShippingCountriesState copyWith({
    RequestState? status,
    List<CountryEntity>? data,
    String? error,
  }) {
    return GetShippingCountriesState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
