part of 'auth_platform_bloc.dart';

class AuthPlatformState extends Equatable {
  final GoogleEntity? userDataWithGoogle;
  final RequestState requestStateGoogle;
  final RequestState requestStateGuest;
  final String msgErrorGoogle;

  final AppleEntity? userDataWithApple;
  final RequestState requestStateApple;
  final String msgErrorApple;

  final AuthWithHuaweiModel? userDataWithHuawei;
  final RequestState requestStateHuawei;
  final String msgErrorHuawei;

  const AuthPlatformState({
    this.userDataWithGoogle,
    this.msgErrorGoogle = '',
    this.requestStateGoogle = RequestState.idle,
    this.requestStateGuest = RequestState.idle,
    this.userDataWithApple,
    this.msgErrorApple = '',
    this.requestStateApple = RequestState.idle,
    this.userDataWithHuawei,
    this.msgErrorHuawei = '',
    this.requestStateHuawei = RequestState.idle,
  });

  AuthPlatformState copyWith({
    GoogleEntity? userDataWithGoogle,
    RequestState? requestStateGoogle,
    RequestState? requestStateGuest,
    String? msgErrorGoogle,
    AppleEntity? userDataWithApple,
    RequestState? requestStateApple,
    String? msgErrorApple,
    AuthWithHuaweiModel? userDataWithHuawei,
    RequestState? requestStateHuawei,
    String? msgErrorHuawei,
  }) =>
      AuthPlatformState(
        userDataWithGoogle: userDataWithGoogle ?? this.userDataWithGoogle,
        requestStateGoogle: requestStateGoogle ?? this.requestStateGoogle,
        requestStateGuest: requestStateGuest ?? this.requestStateGuest,
        msgErrorGoogle: msgErrorGoogle ?? this.msgErrorGoogle,
        userDataWithApple: userDataWithApple ?? this.userDataWithApple,
        requestStateApple: requestStateApple ?? this.requestStateApple,
        msgErrorApple: msgErrorApple ?? this.msgErrorApple,
        userDataWithHuawei: userDataWithHuawei ?? this.userDataWithHuawei,
        requestStateHuawei: requestStateHuawei ?? this.requestStateHuawei,
        msgErrorHuawei: msgErrorHuawei ?? this.msgErrorHuawei,
      );

  @override
  List<Object?> get props => [
        userDataWithGoogle,
        msgErrorGoogle,
        requestStateGoogle,
        requestStateGuest,
        userDataWithApple,
        msgErrorApple,
        requestStateApple,
        userDataWithHuawei,
        msgErrorHuawei,
        requestStateHuawei,
      ];
}
