import 'package:general/src/core/index.dart';

class GooglePayState extends Equatable {
  final String? data;
  final RequestState reqState;
  final String error;

  const GooglePayState({
    this.data,
    this.reqState = RequestState.loading,
    this.error = "",
  });

  GooglePayState copyWith({
    String? data,
    RequestState? reqState,
    String? error,
  }) {
    return GooglePayState(
      data: data ?? this.data,
      reqState: reqState ?? this.reqState,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [data, reqState, error];
}
