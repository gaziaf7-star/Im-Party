import 'package:firebase_auth/firebase_auth.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/core/index.dart';

part 'firebase_custom_token_event.dart';
part 'firebase_custom_token_state.dart';

class FirebaseCustomTokenBloc
    extends Bloc<FirebaseCustomTokenEvent, FirebaseCustomTokenState> {
  final GetFirebaseCustomTokenUc _getFirebaseCustomTokenUc;

  FirebaseCustomTokenBloc(this._getFirebaseCustomTokenUc)
      : super(const FirebaseCustomTokenState()) {
    on<FetchFirebaseCustomToken>(_fetchFirebaseCustomToken);
  }

  void _fetchFirebaseCustomToken(
    FetchFirebaseCustomToken event,
    Emitter<FirebaseCustomTokenState> emit,
  ) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await _getFirebaseCustomTokenUc();

    result.fold(
      (left) {
        emit(
          state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) async {
        emit(
          state.copyWith(
            reqState: RequestState.loaded,
            token: right.data,
            message: right.message,
          ),
        );
        // SSL/network failures during Firebase sign-in must not crash the splash.
        // Retry once for transient errors (e.g. SSL handshake failure), then stop silently.
        try {
          await FirebaseAuth.instance.signInWithCustomToken(right.data ?? "");
        } catch (_) {
          try {
            await FirebaseAuth.instance.signInWithCustomToken(right.data ?? "");
          } catch (_) {}
        }
      },
    );
  }
}
