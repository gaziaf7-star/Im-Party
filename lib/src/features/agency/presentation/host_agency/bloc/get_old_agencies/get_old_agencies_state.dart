part of 'get_old_agencies_bloc.dart';


class GetOldAgenciesState extends Equatable {
  final List<OldAgencyEntity> data;
  final RequestState state;
  final String message;

  const GetOldAgenciesState({
    this.data = const [],
    this.state = RequestState.idle,
    this.message = '',
  });

  GetOldAgenciesState copyWith({
    List<OldAgencyEntity>? data,
    RequestState? state,
    String? message,
  }) {
    return GetOldAgenciesState(
      data: data ?? this.data,
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [data, state, message];
}

