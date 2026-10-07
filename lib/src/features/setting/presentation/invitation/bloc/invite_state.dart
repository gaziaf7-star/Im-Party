part of 'invite_bloc.dart';

class SendInviteState extends Equatable {

  final TextEditingController codeController;
  final GlobalKey<FormState> formKey;

  final String? successSendInviteCode;
  final RequestState sendInviteCodeRequest;
  final String errorSendInviteMessage;

  final EarnInviteEntity? getMyEarnInviteSuccess;
  final RequestState getMyEarnInviteRequest;
  final String getMyEarnInvitesError;

  final List<InvitationUsersEntity>? getInviteUserSuccess;
  final RequestState getInviteUserRequest;
  final String getInviteUserError;

  final String? explainInviteSuccess;
  final RequestState explainInviteRequest;
  final String explainInviteMessage;

  final String? addInviteSuccess;
  final RequestState addInviteRequest;
  final String addInviteMessage;

  final RequestState extractCoinsRequest;
  final String extractCoinsMessage;

  final RequestState claimBonusRequest;
  final String claimBonusMessage;

  const SendInviteState({
    this.successSendInviteCode = "",
    this.sendInviteCodeRequest = RequestState.empty,
    this.errorSendInviteMessage = "",

    this.getMyEarnInviteSuccess,
    this.getMyEarnInviteRequest = RequestState.empty,
    this.getMyEarnInvitesError = "",

    this.getInviteUserSuccess = const [],
    this.getInviteUserRequest = RequestState.empty,
    this.getInviteUserError = "",

    this.explainInviteSuccess = "",
    this.explainInviteRequest = RequestState.empty,
    this.explainInviteMessage = "",

    required this.codeController,
    required this.formKey,

    this.addInviteSuccess = "",
    this.addInviteRequest = RequestState.empty,
    this.addInviteMessage = "",

    this.extractCoinsRequest = RequestState.empty,
    this.extractCoinsMessage = "",

    this.claimBonusRequest = RequestState.empty,
    this.claimBonusMessage = "",

  });

  SendInviteState copyWith({
    String? successSendInviteCode,
    RequestState? sendInviteCodeRequest,
    String? errorSendInviteMessage,

    EarnInviteEntity? getMyEarnInviteSuccess,
    RequestState? getMyEarnInviteRequest,
    String? getMyEarnInvitesError,

    List<InvitationUsersEntity>? getInviteUserSuccess,
    RequestState? getInviteUserRequest,
    String? getInviteUserError,

    String? explainInviteSuccess,
    RequestState? explainInviteRequest,
    String? explainInviteMessage,

    String? addInviteSuccess,
    RequestState? addInviteRequest,
    String? addInviteMessage,

    RequestState? extractCoinsRequest,
    String? extractCoinsMessage,

    RequestState? claimBonusRequest,
    String? claimBonusMessage,

    String? codeController,

  }) {
    return SendInviteState(
      successSendInviteCode: successSendInviteCode ??
          this.successSendInviteCode,
      sendInviteCodeRequest: sendInviteCodeRequest ??
          this.sendInviteCodeRequest,
      errorSendInviteMessage: errorSendInviteMessage ??
          this.errorSendInviteMessage,

      getMyEarnInviteSuccess: getMyEarnInviteSuccess ??
          this.getMyEarnInviteSuccess,
      getMyEarnInviteRequest: getMyEarnInviteRequest ??
          this.getMyEarnInviteRequest,
      getMyEarnInvitesError: getMyEarnInvitesError ??
          this.getMyEarnInvitesError,

      getInviteUserSuccess: getInviteUserSuccess ?? this.getInviteUserSuccess,
      getInviteUserRequest: getInviteUserRequest ?? this.getInviteUserRequest,
      getInviteUserError: getInviteUserError ?? this.getInviteUserError,

      explainInviteSuccess: explainInviteSuccess ?? this.explainInviteSuccess,
      explainInviteRequest: explainInviteRequest ?? this.explainInviteRequest,
      explainInviteMessage: explainInviteMessage ?? this.explainInviteMessage,

      addInviteSuccess: addInviteSuccess ?? this.addInviteSuccess,
      addInviteRequest: addInviteRequest ?? this.addInviteRequest,
      addInviteMessage: addInviteMessage ?? this.addInviteMessage,

      extractCoinsRequest: extractCoinsRequest ?? this.extractCoinsRequest,
      extractCoinsMessage: extractCoinsMessage ?? this.extractCoinsMessage,

      claimBonusRequest: claimBonusRequest ?? this.claimBonusRequest,
      claimBonusMessage: claimBonusMessage ?? this.claimBonusMessage,

      codeController: this.codeController.copyWith(text: codeController),
      formKey: formKey,

    );
  }

  @override
  List<Object?> get props =>
      [
        codeController,
        formKey,

        successSendInviteCode,
        sendInviteCodeRequest,
        errorSendInviteMessage,

        getMyEarnInviteSuccess,
        getMyEarnInviteRequest,
        getMyEarnInvitesError,

        getInviteUserSuccess,
        getInviteUserRequest,
        getInviteUserError,

        explainInviteSuccess,
        explainInviteRequest,
        explainInviteMessage,

        addInviteSuccess,
        addInviteRequest,
        addInviteMessage,

        extractCoinsRequest,
        extractCoinsMessage,

        claimBonusRequest,
        claimBonusMessage,
      ];
}
