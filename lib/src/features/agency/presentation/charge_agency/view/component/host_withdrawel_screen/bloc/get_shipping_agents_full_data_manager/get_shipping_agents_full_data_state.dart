part of'get_shipping_agents_full_data_bloc.dart';


class GetShippingAgentsFullDataModelState extends Equatable {
  final RequestState status;
  final List<ShippingAgentsFullDataEntity> data;
  final String? error;
  final CountryEntity? selectedCountry;
  final PaymentsGetwaysEntity? selectedPayment;
  final bool? isShowCountry;
  final bool? isShowPayment;
  final bool? isNullCountry, isNullPayment;
  final int currentPage;
  final int lastPage;
  final bool isPaginating;

  bool get hasMore => currentPage < lastPage;

  const GetShippingAgentsFullDataModelState({
    this.status = RequestState.idle,
    this.data = const [],
    this.error,
    this.selectedCountry,
    this.selectedPayment,
    this.isShowCountry = false,
    this.isShowPayment = false,
    this.isNullCountry = false,
    this.isNullPayment = false,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isPaginating = false,
  });

  GetShippingAgentsFullDataModelState copyWith({
    RequestState? status,
    List<ShippingAgentsFullDataEntity>? data,
    CountryEntity? selectedCountry,
    PaymentsGetwaysEntity? selectedPayment,
    String? error,
    bool? isShowCountry,
    bool? isShowPayment,
    bool isNullCountry = false,
    bool isNullPayment = false,
    int? currentPage,
    int? lastPage,
    bool? isPaginating,
  }) {
    return GetShippingAgentsFullDataModelState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
      selectedCountry:
          isNullCountry ? null : selectedCountry ?? this.selectedCountry,
      selectedPayment:
          isNullPayment ? null : selectedPayment ?? this.selectedPayment,
      isShowCountry: isShowCountry ?? this.isShowCountry,
      isShowPayment: isShowPayment ?? this.isShowPayment,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }

  @override
  List<Object?> get props => [
    status, data, error,
    selectedCountry, selectedPayment,
    isShowCountry, isShowPayment,
    currentPage, lastPage, isPaginating,
  ];
}
