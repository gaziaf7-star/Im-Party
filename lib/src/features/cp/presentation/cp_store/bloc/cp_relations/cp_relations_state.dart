part of 'cp_relations_bloc.dart';

class CpRelationsStates extends Equatable {
  final RequestState userStates;
  final RequestState cpRelationRespondState;
  final CpRelationsModel? data;
  final String errorMessage;
  final String cpRelationRespondMessage;
  final String message;
  final Map<String, String> updatedMessageStatuses;
  final String? loadingMessageId;
  final String? loadingStatus;

  const CpRelationsStates({
    this.data,
    this.userStates = RequestState.idle,
    this.cpRelationRespondState = RequestState.idle,
    this.cpRelationRespondMessage = '',
    this.errorMessage = '',
    this.message = '',
    this.loadingMessageId = '',
    this.loadingStatus = '',
    this.updatedMessageStatuses = const {},
  });

  CpRelationsStates copyWith({
    RequestState? userStates,
    RequestState? cpRelationRespondState,
    CpRelationsModel? data,
    String? errorMessage,
    String? cpRelationRespondMessage,
    String? message,
    String? loadingMessageId,
    String? loadingStatus,
    Map<String, String>? updatedMessageStatuses,
  }) {
    return CpRelationsStates(
      data: data ?? this.data,
      userStates: userStates ?? this.userStates,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      cpRelationRespondMessage:
          cpRelationRespondMessage ?? this.cpRelationRespondMessage,
      cpRelationRespondState:
          cpRelationRespondState ?? this.cpRelationRespondState,
      loadingMessageId: loadingMessageId ?? this.loadingMessageId,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      updatedMessageStatuses:
          updatedMessageStatuses ?? this.updatedMessageStatuses,
    );
  }

  @override
  List<Object?> get props => [
        data,
        userStates,
        errorMessage,
        message,
        cpRelationRespondState,
        cpRelationRespondMessage,
        loadingMessageId,
        loadingStatus,
        updatedMessageStatuses,
      ];
}
