import 'package:general/src/core/index.dart';
import 'package:general/src/features/tasks/tasks.dart';

class CollectTaskPointsUseCase
    extends UseCaseWithParams<BaseResponse<CollectTaskResultModel>, int> {
  CollectTaskPointsUseCase(this._repo);

  final TasksBaseRepository _repo;

  @override
  ResultFuture<BaseResponse<CollectTaskResultModel>> call(int params) {
    return _repo.collectTaskPoints(taskId: params);
  }
}
