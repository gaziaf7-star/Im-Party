import 'package:general/src/features/tasks/tasks.dart';

import '../../../../core/index.dart';

abstract class BaseTasksRemotelyDataSource {
  Future<BaseResponse<TasksProgressModel>> getTasksProgress();

  Future<BaseResponse<CollectTaskResultModel>> collectTaskPoints({
    required int taskId,
  });
}

class TasksRemotelyDataSource extends BaseTasksRemotelyDataSource {
  TasksRemotelyDataSource({required this.dioFactory});

  final DioFactory dioFactory;

  @override
  Future<BaseResponse<TasksProgressModel>> getTasksProgress() async {
    final response = await dioFactory.get(EndPoints.taskDays);

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) =>
          TasksProgressModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponse<CollectTaskResultModel>> collectTaskPoints({
    required int taskId,
  }) async {
    final response = await dioFactory.post(EndPoints.collectTask(taskId));

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) =>
          CollectTaskResultModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
