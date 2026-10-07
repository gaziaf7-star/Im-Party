import 'package:general/src/features/tasks/tasks.dart';

import '../../../../core/index.dart';

abstract class TasksBaseRepository {
  ResultFuture<BaseResponse<TasksProgressModel>> getTasksProgress();

  ResultFuture<BaseResponse<CollectTaskResultModel>> collectTaskPoints({
    required int taskId,
  });
}
