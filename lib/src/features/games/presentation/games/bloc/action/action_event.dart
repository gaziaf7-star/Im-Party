part of 'action_bloc.dart';

sealed class ActionEvent extends Equatable {
  final String userId;
  const ActionEvent({this.userId =''});

  @override
  List<Object> get props => [userId];
}

class IgnoreUserEvent extends ActionEvent{
  const IgnoreUserEvent({required super.userId});
}

class LikeUserEvent extends ActionEvent{
  const LikeUserEvent({required super.userId});
}
