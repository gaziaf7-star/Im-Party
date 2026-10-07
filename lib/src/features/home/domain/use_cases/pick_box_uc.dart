import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/repository/base_home_repository.dart';

class PickBoxUC
    extends UseCaseWithParams<BaseResponse<String> , String> {
  final BaseHomeRepository _repo;

  const PickBoxUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(param) async {
    return await _repo.pickBox(stageId: param);
  }
}
