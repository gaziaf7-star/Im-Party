part of 'create_group_bloc.dart';

abstract class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object?> get props => [];
}

class SubmitCreateGroupEvent extends CreateGroupEvent {
  final CreateGroupParams params;
  const SubmitCreateGroupEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class ResetCreateGroupEvent extends CreateGroupEvent {
  const ResetCreateGroupEvent();
}
