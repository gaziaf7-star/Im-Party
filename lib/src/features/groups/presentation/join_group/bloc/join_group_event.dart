part of 'join_group_bloc.dart';

abstract class JoinGroupEvent extends Equatable {
  const JoinGroupEvent();

  @override
  List<Object?> get props => [];
}

class SubmitJoinGroupEvent extends JoinGroupEvent {
  final JoinGroupParams params;
  const SubmitJoinGroupEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class ResetJoinGroupEvent extends JoinGroupEvent {
  const ResetJoinGroupEvent();
}
