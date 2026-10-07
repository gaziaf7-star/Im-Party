import 'package:general/src/features/tasks/tasks.dart';

import '../../../../core/index.dart';

class TasksRepositoryImp extends TasksBaseRepository {
  TasksRepositoryImp({required this.baseTasksRemotelyDataSource});

  final BaseTasksRemotelyDataSource baseTasksRemotelyDataSource;

  @override
  ResultFuture<BaseResponse<TasksProgressModel>> getTasksProgress() {
    return execute<BaseResponse<TasksProgressModel>>(
        () => baseTasksRemotelyDataSource.getTasksProgress());
  }

  @override
  ResultFuture<BaseResponse<CollectTaskResultModel>> collectTaskPoints({
    required int taskId,
  }) {
    return execute<BaseResponse<CollectTaskResultModel>>(
        () => baseTasksRemotelyDataSource.collectTaskPoints(taskId: taskId));
  }
}
