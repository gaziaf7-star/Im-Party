import 'package:general/src/core/index.dart';
import 'package:general/src/features/tasks/tasks.dart';

class GetTasksProgressUseCase
    extends UseCaseWithoutParams<BaseResponse<TasksProgressModel>> {
  GetTasksProgressUseCase(this._repo);

  final TasksBaseRepository _repo;

  @override
  ResultFuture<BaseResponse<TasksProgressModel>> call() {
    return _repo.getTasksProgress();
  }
}
