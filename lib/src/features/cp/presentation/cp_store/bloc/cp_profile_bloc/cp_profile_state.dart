part of 'cp_profile_bloc.dart';

class CpProfileStates extends Equatable {
  final RequestState reqStates;
  final CpProfileModel? data;
  final String errorMessage;
  final String message;
  final String? loadedUserId;

  final RequestState buyCpReqStates;
  final String buyCpErrorMessage;
  final String buyCpMessage;

  const CpProfileStates({
    this.data,
    this.reqStates = RequestState.idle,
    this.errorMessage = '',
    this.message = '',
    this.loadedUserId,
    this.buyCpReqStates = RequestState.idle,
    this.buyCpErrorMessage = '',
    this.buyCpMessage = '',
  });

  CpProfileStates copyWith({
    RequestState? reqStates,
    CpProfileModel? data,
    String? errorMessage,
    String? message,
    String? loadedUserId,
    RequestState? buyCpReqStates,
    String? buyCpErrorMessage,
    String? buyCpMessage,
  }) {
    return CpProfileStates(
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      loadedUserId: loadedUserId ?? this.loadedUserId,
      buyCpReqStates: buyCpReqStates ?? this.buyCpReqStates,
      reqStates: reqStates ?? this.reqStates,
      buyCpErrorMessage: buyCpErrorMessage ?? this.buyCpErrorMessage,
      buyCpMessage: buyCpMessage ?? this.buyCpMessage,
    );
  }

  @override
  List<Object?> get props => [
        data,
        reqStates,
        errorMessage,
        message,
        loadedUserId,
        buyCpReqStates,
        buyCpErrorMessage,
        buyCpMessage,
      ];
}
