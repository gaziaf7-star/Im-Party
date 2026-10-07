part of 'log_out_bloc.dart';

sealed class BaseLogOutEvent extends Equatable {
  const BaseLogOutEvent();

  @override
  List<Object?> get props => [];
}
class LogOutEvent extends BaseLogOutEvent {
  const LogOutEvent();

}
