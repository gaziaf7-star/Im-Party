part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class GetTasksProgressEvent extends TasksEvent {
  const GetTasksProgressEvent({this.isRefresh = false});

  /// Keeps the loaded list visible while refetching.
  final bool isRefresh;

  @override
  List<Object?> get props => [isRefresh];
}

class CollectTaskPointsEvent extends TasksEvent {
  const CollectTaskPointsEvent(this.taskId);

  final int taskId;

  @override
  List<Object?> get props => [taskId];
}
