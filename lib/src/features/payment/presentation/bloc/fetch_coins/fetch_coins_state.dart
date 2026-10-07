import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/domain/entities/coins_entity.dart';

class FetchCoinsState extends Equatable {
  final List<PaymentGatewayEntity>? data;
  final RequestState reqState;
  final String error;

  // shipping data
  final List<PaymentGatewayEntity>? shippingData;
  final RequestState shippingReqState;
  final String shippingError;

  final bool isChecked;

  const FetchCoinsState({
    this.data,
    this.reqState = RequestState.loading,
    this.error = "",
    this.shippingData,
    this.shippingReqState = RequestState.loading,
    this.shippingError = "",
    this.isChecked = false,
  });

  FetchCoinsState copyWith({
    List<PaymentGatewayEntity>? data,
    RequestState? reqState,
    String? error,
    List<PaymentGatewayEntity>? shippingData,
    RequestState? shippingReqState,
    String? shippingError,
    bool? isChecked,
  }) {
    return FetchCoinsState(
      data: data ?? this.data,
      reqState: reqState ?? this.reqState,
      error: error ?? this.error,
      shippingData: shippingData ?? this.shippingData,
      shippingReqState: shippingReqState ?? this.shippingReqState,
      shippingError: shippingError ?? this.shippingError,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  List<Object?> get props =>
      [data, reqState, error, shippingData, shippingReqState, shippingError, isChecked];
}
