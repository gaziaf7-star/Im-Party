part of 'log_out_bloc.dart';

sealed class BaseLogOutState extends Equatable {
  const BaseLogOutState();

  @override
  List<Object?> get props => [];
}

final class LogOutInitial extends BaseLogOutState {
  const LogOutInitial();
}

final class LogOutLoading extends BaseLogOutState {
  const LogOutLoading();
}

final class LogOutSuccess extends BaseLogOutState {
  final String message;

  const LogOutSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class LogOutError extends BaseLogOutState {
  final String message;
  const LogOutError(this.message);

  @override
  List<Object?> get props => [message];
}
