part of 'show_agency_bloc.dart';

class ShowAgencyState extends Equatable {
  final RequestState requestState;
  final ShowAgencyModel? data;
  final String? error;

  const ShowAgencyState({
    this.requestState = RequestState.idle,
    this.data,
    this.error,
  });

  ShowAgencyState copyWith({
    RequestState? requestState,
    ShowAgencyModel? data,
    String? error,
  }) {
    return ShowAgencyState(
      requestState: requestState ?? this.requestState,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [requestState, data, error];
}
