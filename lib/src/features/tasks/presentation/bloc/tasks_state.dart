part of 'tasks_bloc.dart';

class TasksState extends Equatable {
  const TasksState({
    this.progress,
    this.collectResult,
    this.reqStateProgress = RequestState.idle,
    this.reqStateCollect = RequestState.idle,
    this.errorProgress = '',
    this.errorCollect = '',
    this.collectMessage = '',
    this.collectingTaskId,
  });

  final TasksProgressModel? progress;
  final CollectTaskResultModel? collectResult;
  final RequestState reqStateProgress;
  final RequestState reqStateCollect;
  final String? errorProgress;
  final String? errorCollect;
  final String? collectMessage;

  /// Which row is mid-claim, so only that button shows a spinner.
  final int? collectingTaskId;

  List<DailyTaskModel> get tasks => progress?.tasks ?? const [];

  List<TaskDayModel> get days => progress?.days ?? const [];

  int get totalPoints => progress?.totalPoints ?? 0;

  TasksState copyWith({
    TasksProgressModel? progress,
    CollectTaskResultModel? collectResult,
    RequestState? reqStateProgress,
    RequestState? reqStateCollect,
    String? errorProgress,
    String? errorCollect,
    String? collectMessage,
    int? collectingTaskId,

    // `collectingTaskId: null` cannot mean "clear it" in a copyWith, since an
    // omitted argument is also null. This flag says it explicitly.
    bool clearCollectingTaskId = false,
  }) {
    return TasksState(
      progress: progress ?? this.progress,
      collectResult: collectResult ?? this.collectResult,
      reqStateProgress: reqStateProgress ?? this.reqStateProgress,
      reqStateCollect: reqStateCollect ?? this.reqStateCollect,
      errorProgress: errorProgress ?? this.errorProgress,
      errorCollect: errorCollect ?? this.errorCollect,
      collectMessage: collectMessage ?? this.collectMessage,
      collectingTaskId:
          clearCollectingTaskId ? null : collectingTaskId ?? this.collectingTaskId,
    );
  }

  @override
  List<Object?> get props => [
        progress,
        collectResult,
        reqStateProgress,
        reqStateCollect,
        errorProgress,
        errorCollect,
        collectMessage,
        collectingTaskId,
      ];
}
