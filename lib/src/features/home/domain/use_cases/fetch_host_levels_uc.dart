import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/host_level_model.dart';
import 'package:general/src/features/home/domain/repository/base_home_repository.dart';

class FetchHostLevelsUc
    extends UseCaseWithoutParams<BaseResponse<HostLevelsModel>> {
  final BaseHomeRepository _repo;

  const FetchHostLevelsUc(this._repo);

  @override
  ResultFuture<BaseResponse<HostLevelsModel>> call() async {
    return await _repo.fetchHostLevels();
  }
}
