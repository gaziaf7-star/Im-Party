part of 'firebase_custom_token_bloc.dart';

class FirebaseCustomTokenState extends Equatable {
  final RequestState reqState;
  final String? token;
  final String message;

  const FirebaseCustomTokenState({
    this.reqState = RequestState.idle,
    this.token,
    this.message = '',
  });

  FirebaseCustomTokenState copyWith({
    RequestState? reqState,
    String? token,
    String? message,
  }) {
    return FirebaseCustomTokenState(
      reqState: reqState ?? this.reqState,
      token: token ?? this.token,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        reqState,
        token,
        message,
      ];
}
