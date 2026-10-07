import 'package:equatable/equatable.dart';
import 'package:general/src/core/constants/enums.dart';

class BuyVipState extends Equatable {
  final RequestState requestState;
  final String message;

  const BuyVipState({
    this.requestState = RequestState.idle,
    this.message = '',
  });

  BuyVipState copyWith({
    RequestState? requestState,
    String? message,
  }) {
    return BuyVipState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [requestState, message];
}
