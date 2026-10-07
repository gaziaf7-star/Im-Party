import 'package:general/src/features/tasks/tasks.dart';

import '../../../../core/index.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(this._getTasksProgressUseCase, this._collectTaskPointsUseCase)
      : super(const TasksState()) {
    on<GetTasksProgressEvent>(_onGetProgress);
    on<CollectTaskPointsEvent>(_onCollect);
  }

  final GetTasksProgressUseCase _getTasksProgressUseCase;
  final CollectTaskPointsUseCase _collectTaskPointsUseCase;

  Future<void> _onGetProgress(
    GetTasksProgressEvent event,
    Emitter<TasksState> emit,
  ) async {
    // A pull-to-refresh keeps the current list on screen; only the first load
    // shows the full-page spinner.
    if (!event.isRefresh) {
      emit(state.copyWith(reqStateProgress: RequestState.loading));
    }

    final result = await _getTasksProgressUseCase.call();

    result.fold(
      (l) => emit(state.copyWith(
        reqStateProgress: handleErrorResponse(l),
        errorProgress: NetworkExceptions.getErrorMessage(l),
      )),
      (r) => emit(state.copyWith(
        reqStateProgress: handleLoadedResponse<List<DailyTaskModel>>(
          r.data?.tasks,
        ),
        progress: r.data,
      )),
    );
  }

  Future<void> _onCollect(
    CollectTaskPointsEvent event,
    Emitter<TasksState> emit,
  ) async {
    // Guard against a second tap on the same row while the first is in flight:
    // the backend would answer "already collected" and the user would see a
    // failure toast for a claim that actually worked.
    if (state.collectingTaskId != null) return;

    emit(state.copyWith(
      collectingTaskId: event.taskId,
      reqStateCollect: RequestState.loading,
    ));

    final result = await _collectTaskPointsUseCase.call(event.taskId);

    result.fold(
      (l) => emit(state.copyWith(
        reqStateCollect: handleErrorResponse(l),
        errorCollect: NetworkExceptions.getErrorMessage(l),
        clearCollectingTaskId: true,
      )),
      (r) {
        emit(state.copyWith(
          reqStateCollect: RequestState.loaded,
          collectMessage: r.message,
          collectResult: r.data,
          // Mark the row claimed locally so the button settles immediately
          // instead of waiting on the refetch below.
          progress: _markClaimed(event.taskId, r.data?.totalPoints),
          clearCollectingTaskId: true,
        ));

        // The day may have unlocked the next one, and points changed — pull the
        // authoritative view rather than guessing at it.
        add(const GetTasksProgressEvent(isRefresh: true));
      },
    );
  }

  TasksProgressModel? _markClaimed(int taskId, int? totalPoints) {
    final current = state.progress;
    if (current == null) return null;

    return TasksProgressModel(
      totalPoints: totalPoints ?? current.totalPoints,
      days: current.days,
      tasks: current.tasks
          .map((task) => task.id == taskId
              ? task.copyWith(isCompleted: true, isCollect: true)
              : task)
          .toList(),
    );
  }
}
