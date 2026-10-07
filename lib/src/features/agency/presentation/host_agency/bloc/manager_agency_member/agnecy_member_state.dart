

part of 'agnecy_member_bloc.dart';
class AgencyMemberState extends Equatable {
  final RequestState requestState;
  final List<AgencyMemberModel>? data;
  final String? error;

  const AgencyMemberState({
    this.requestState = RequestState.idle,
    this.data,
    this.error,
  });

  AgencyMemberState copyWith({
    RequestState? requestState,
    List<AgencyMemberModel>? data,
    String? error,
  }) {
    return AgencyMemberState(
      requestState: requestState ?? this.requestState,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [requestState, data, error];
}
