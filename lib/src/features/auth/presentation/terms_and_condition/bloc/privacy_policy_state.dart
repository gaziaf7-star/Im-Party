part of'privacy_policy_bloc.dart';


class PrivacyPolicyState extends Equatable {
  final String? errorPrivacy;
  final RequestState requestState;
  final PrivacyPolicy? messagePrivacy;


  const PrivacyPolicyState({
    this.errorPrivacy,
    this.requestState = RequestState.loading,
    this.messagePrivacy ,
  });

  PrivacyPolicyState copyWith({
    String? errorPrivacy,
    RequestState? requestState,
    PrivacyPolicy? messagePrivacy,
  }) {
    return PrivacyPolicyState(
      errorPrivacy: errorPrivacy ?? this.errorPrivacy,
      requestState:
      requestState ?? this.requestState,
      messagePrivacy:
      messagePrivacy ?? this.messagePrivacy,
    );
  }

  @override
  List<Object?> get props =>
      [
        errorPrivacy,
        requestState,
        messagePrivacy,
      ];
}