part of 'exit_family_bloc.dart';

abstract class BaseExitFamilyEvent extends Equatable {
  const BaseExitFamilyEvent();

  @override
  List<Object?> get props => [];
}

class ExitFamilyEvent extends BaseExitFamilyEvent {
  const ExitFamilyEvent();
}
