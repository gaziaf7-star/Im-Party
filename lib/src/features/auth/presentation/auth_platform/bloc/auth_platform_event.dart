part of 'auth_platform_bloc.dart';

sealed class AuthPlatformEvent extends Equatable {
  const AuthPlatformEvent();
  @override
  List<Object?> get props => [];
}

class SignInGoogleEvent extends AuthPlatformEvent {
  final BuildContext context;
  final bool isAddAccount;
  const SignInGoogleEvent({required this.context,this.isAddAccount=false});

    @override
  List<Object?> get props => [context];
}

/// Quick login — no credential, no account picker.
class SignInGuestEvent extends AuthPlatformEvent {
  final BuildContext context;
  const SignInGuestEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class SignInAppleEvent extends AuthPlatformEvent {
  final BuildContext context;
  const SignInAppleEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class SignInHuaweiEvent extends AuthPlatformEvent {
  final BuildContext context;
  const SignInHuaweiEvent({required this.context});

  @override
  List<Object?> get props => [context];
}