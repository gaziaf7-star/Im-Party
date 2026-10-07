import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/domain/entities/third_party_entity.dart';

part 'auth_platform_event.dart';
part 'auth_platform_state.dart';

class AuthPlatformBloc extends Bloc<AuthPlatformEvent, AuthPlatformState> {
  final SignInWithGoogleUC signInWithGoogleUC;
  final SignInWithAppleUC signInWithAppleUC;
  final SignInWithHuaweiUC signInWithHuaweiUC;
  final GuestLoginUC guestLoginUC;

  AuthPlatformBloc({
    required this.signInWithGoogleUC,
    required this.signInWithAppleUC,
    required this.signInWithHuaweiUC,
    required this.guestLoginUC,
  }) : super(
    const AuthPlatformState(),
  ) {
    on<SignInGoogleEvent>(_googleEvent);
    on<SignInAppleEvent>(_appleEvent);
    on<SignInHuaweiEvent>(_huaweiEvent);
    on<SignInGuestEvent>(_guestEvent);
  }
  // Events
  Future<void> _googleEvent(
      SignInGoogleEvent event,
      Emitter<AuthPlatformState> emit,
      ) async {
    emit(state.copyWith(requestStateGoogle: RequestState.loading));

    final Either<NetworkExceptions, BaseResponse<GoogleModel>> result;
    try {
      result = await signInWithGoogleUC.call();
    } catch (error, stack) {
      // Was a bare `catch (_)` -- silently swallowed the REAL native
      // exception (e.g. a GoogleSignIn PlatformException/ApiException code
      // like DEVELOPER_ERROR/10, a cancel, a network failure) with nothing
      // logged anywhere, which is why "Google sign-in failed, please try
      // again" on a real user's Play Store install couldn't be diagnosed --
      // there was no trace of the actual cause anywhere. Now recorded to
      // Crashlytics (non-fatal, won't affect crash-free rate) so the exact
      // exception shows up there for the next failed attempt.
      Methods.printLog("❌ Google sign-in threw: $error");
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'Google Sign-In failed (AuthPlatformBloc._googleEvent)',
        fatal: false,
      );
      emit(state.copyWith(requestStateGoogle: RequestState.error));
      return;
    }
    result.fold(
          (failure) {
        emit(
          state.copyWith(
            msgErrorGoogle: NetworkExceptions.getErrorMessage(failure),
            requestStateGoogle: RequestState.error,
          ),
        );
        Methods.showToast(
          navKey.currentContext,
          message: state.msgErrorGoogle,
          isError: true,
        );
      },
          (success) async {
        emit(
          state.copyWith(
            userDataWithGoogle: success.data,
            requestStateGoogle: RequestState.loaded,
          ),
        );
        Methods.identifyUserForCrashlytics();
        Methods.showToast(
          navKey.currentContext,
          message: success.message,
        );
        await Methods.saveUserToken(token_: success.data?.data.authToken);
        if (event.context.mounted) {
          if (success.data?.data.isFirst == true) {
            // Seed the form with what Google gave us (name, avatar)...
            di<AddInformationBloc>().add(
              ThirdPartyEvent(
                kThirdPartyEntity: ThirdPartyEntity(
                  data: state.userDataWithGoogle,
                  type: 'google',
                ),
              ),
            );
            // ...then OPEN the page. This used to dispatch AddInformationEvent,
            // which is the SUBMIT handler: with no form on screen its
            // `formKey.currentState` is null, `validate()` returns null, the
            // guard `== false` is not met, and it posted an empty name, gender
            // and birthday. The registration page was never shown at all.
            // The helper already clears the stack by default.
            event.context.pushNamedAndRemoveUntil(Routes.addInformation);
          } else {
            event.context.pushNamedAndRemoveUntil(Routes.layout);
          }
        }

        await Methods.saveUserLoginAccountIdToken(
          token: success.data?.data.authToken ?? '',
          accountId: success.data?.data.id.toString() ?? '',
        );
      },
    );
  }

  /// Quick login.
  ///
  /// Shorter than the social flows because there is nothing to negotiate: the
  /// server answers with the same {id, is_first, auth_token} envelope, so the
  /// only decision left is whether this is a brand-new guest who still needs the
  /// profile step.
  Future<void> _guestEvent(
      SignInGuestEvent event,
      Emitter<AuthPlatformState> emit,
      ) async {
    emit(state.copyWith(requestStateGuest: RequestState.loading));

    final result = await guestLoginUC.call();

    await result.fold(
          (failure) async {
        emit(state.copyWith(requestStateGuest: RequestState.error));
        Methods.showToast(
          navKey.currentContext,
          message: NetworkExceptions.getErrorMessage(failure),
          isError: true,
        );
      },
          (success) async {
        emit(state.copyWith(requestStateGuest: RequestState.loaded));
        Methods.identifyUserForCrashlytics();

        final token = success.data?.authToken;
        await Methods.saveUserToken(token_: token);
        await Methods.saveUserLoginAccountIdToken(
          token: token ?? '',
          accountId: success.data?.id.toString() ?? '',
        );

        if (!event.context.mounted) return;
        // A returning guest goes straight in; a brand-new one still picks a
        // name and avatar, exactly like a first Google sign-in.
        if (success.data?.isFirst == true) {
          // Same correction as the Google path: show the page, do not submit it.
          event.context.pushNamedAndRemoveUntil(Routes.addInformation);
        } else {
          event.context.pushNamedAndRemoveUntil(Routes.layout);
        }
      },
    );
  }

  void _appleEvent(
      SignInAppleEvent event, Emitter<AuthPlatformState> emit) async {
    emit(state.copyWith(requestStateApple: RequestState.loading));

    final result = await signInWithAppleUC.call();
    result.fold(
          (failure) => emit(
        state.copyWith(
          msgErrorApple: NetworkExceptions.getErrorMessage(failure),
          requestStateApple: RequestState.error,
        ),
      ),
          (success) async {
        emit(
          state.copyWith(
            userDataWithApple: success.data,
            requestStateApple: RequestState.loaded,
          ),
        );

        Methods.identifyUserForCrashlytics();
        Methods.showToast(event.context, message: StringManager.success);
        await Methods.saveUserToken(token_: success.data?.data.authToken);
        if (event.context.mounted) {
          if (success.data?.data.isFirst == true) {
            event.context.pushNamedRoute(Routes.register,
                arguments: ThirdPartyEntity(
                    data: state.userDataWithApple?.data, type: 'apple'));
          } else {
            event.context.pushNamedAndRemoveUntil(Routes.layout);
          }
        }
        await Methods.saveUserLoginAccountIdToken(
          token: success.data?.data.authToken ?? '',
          accountId: success.data?.data.id.toString() ?? '',
        );
      },
    );
  }

  void _huaweiEvent(
      SignInHuaweiEvent event, Emitter<AuthPlatformState> emit) async {
    emit(state.copyWith(requestStateHuawei: RequestState.loading));

    final result = await signInWithHuaweiUC.call();
    result.fold(
          (failure) => emit(
        state.copyWith(
          msgErrorHuawei: NetworkExceptions.getErrorMessage(failure),
          requestStateHuawei: RequestState.error,
        ),
      ),
          (success) async {
        emit(
          state.copyWith(
            userDataWithHuawei: success.data,
            requestStateHuawei: RequestState.loaded,
          ),
        );
        Methods.identifyUserForCrashlytics();
        Methods.showToast(event.context, message: StringManager.success);
        await Methods.saveUserToken(token_: success.data?.data.authToken);
        if (event.context.mounted) {
          if (success.data?.data.isFirst == true) {
            event.context.pushNamedRoute(Routes.register,
                arguments: ThirdPartyEntity(
                    data: state.userDataWithHuawei?.data, type: 'huawei'));
          } else {
            event.context.pushNamedAndRemoveUntil(Routes.layout);
          }
        }
        await Methods.saveUserLoginAccountIdToken(
          token: success.data?.data.authToken ?? '',
          accountId: success.data?.data.id.toString() ?? '',
        );
      },
    );
  }
}