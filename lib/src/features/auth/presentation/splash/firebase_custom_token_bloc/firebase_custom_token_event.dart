part of 'firebase_custom_token_bloc.dart';

sealed class FirebaseCustomTokenEvent extends Equatable {
  const FirebaseCustomTokenEvent();

  @override
  List<Object?> get props => [];
}

final class FetchFirebaseCustomToken extends FirebaseCustomTokenEvent {
  const FetchFirebaseCustomToken();

  @override
  List<Object?> get props => [];
}
