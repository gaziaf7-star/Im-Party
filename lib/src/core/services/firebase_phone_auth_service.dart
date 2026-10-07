import 'package:firebase_auth/firebase_auth.dart';
import 'package:general/src/core/services/firebase_config_store.dart';

/// Wraps [FirebaseAuth] phone verification for the single unified OTP path.
///
/// SMS is sent by Firebase (no backend send call). After the user types the
/// SMS code, [confirmCode] signs in with the credential and returns the
/// Firebase ID token string, which the app then forwards to the backend as
/// `firebase_id_token` on the downstream auth flow.
///
/// White-label gate: Firebase phone auth only runs when the panel-driven
/// runtime config has `phoneAuthEnabled = true` ([FirebaseConfigStore]). A
/// client whose Firebase project has no phone provider configured will have the
/// flag off, and this service short-circuits with a readable error instead of
/// throwing an unconfigured-provider exception from the SDK.
class FirebasePhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Whether the active client has Firebase phone auth enabled (panel config).
  bool get isEnabled => FirebaseConfigStore.instance.phoneAuthEnabled;

  /// The latest verificationId returned by Firebase in [codeSent]. Kept here so
  /// the confirm step (handled by a different bloc) can build the credential.
  String? _verificationId;

  String? get verificationId => _verificationId;

  /// Starts phone verification. Firebase sends the SMS.
  ///
  /// - [onCodeSent] fires with the verificationId once the SMS is dispatched.
  /// - [onAutoVerified] fires on Android instant/auto verification with a ready
  ///   Firebase ID token (no manual code entry needed).
  /// - [onError] fires with a readable message on failure.
  Future<void> startVerification({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    void Function(String idToken)? onAutoVerified,
  }) async {
    if (!isEnabled) {
      onError('Phone verification is not available right now.');
      return;
    }
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            final idToken = await userCredential.user?.getIdToken();
            if (idToken != null && onAutoVerified != null) {
              onAutoVerified(idToken);
            }
          } on FirebaseAuthException catch (e) {
            onError(_messageFromException(e));
          } catch (_) {
            onError('Verification failed. Please try again.');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_messageFromException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      onError(_messageFromException(e));
    } catch (_) {
      onError('Failed to send the verification code. Please try again.');
    }
  }

  /// Confirms the SMS [smsCode] against [verificationId], signs in and returns
  /// the Firebase ID token string. Falls back to the last stored
  /// verificationId when one is not passed explicitly.
  Future<String> confirmCode({
    String? verificationId,
    required String smsCode,
  }) async {
    if (!isEnabled) {
      throw const FormatException('Phone verification is not available.');
    }
    final id = verificationId ?? _verificationId;
    if (id == null || id.isEmpty) {
      throw const FormatException('Missing verificationId.');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: id,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw const FormatException('Failed to obtain Firebase ID token.');
    }
    return idToken;
  }

  String _messageFromException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid.';
      case 'invalid-verification-code':
        return 'The verification code is incorrect.';
      case 'invalid-verification-id':
        return 'The verification session expired. Please resend the code.';
      case 'session-expired':
        return 'The code has expired. Please resend a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Verification failed. Please try again.';
    }
  }
}
