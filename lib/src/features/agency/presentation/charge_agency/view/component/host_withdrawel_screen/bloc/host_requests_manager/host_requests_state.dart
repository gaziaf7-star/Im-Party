part of 'host_requests_bloc.dart';
class HostRequestsState extends Equatable {
  final RequestState getListStatus;
  final RequestState makeActionStatus;
  final int dialogsYouHave;
  final List<HostRequestsModel>? hostRequestsModel;
  final String? error;
  final String? message;

  const HostRequestsState({
    this.getListStatus = RequestState.idle,
    this.makeActionStatus = RequestState.idle,
    this.hostRequestsModel,
    this.dialogsYouHave=0,
    this.error,
    this.message,
  });

  HostRequestsState copyWith({
    RequestState? getListStatus,
    RequestState? makeActionStatus,
    List<HostRequestsModel>? hostRequestsModel,
    String? error,
    String? message,
    int? dialogsYouHave,
  }) {
    return HostRequestsState(
      getListStatus: getListStatus ?? this.getListStatus,
      makeActionStatus: makeActionStatus ?? this.makeActionStatus,
      hostRequestsModel: hostRequestsModel ?? this.hostRequestsModel,
      dialogsYouHave: dialogsYouHave ?? this.dialogsYouHave,
      error: error,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    getListStatus, makeActionStatus,dialogsYouHave,
    hostRequestsModel, error, message];
}
