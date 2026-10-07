

import '../../../../core/index.dart';
import '../../profile.dart';

class GetMyAllBadgeUC extends UseCaseWithParams <BaseResponse<List<ImageData>>,String>{
  final ProfileBaseRepository _repo;
  GetMyAllBadgeUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<ImageData>>> call(params) async {
    final result = await _repo.getMyAllBadge(id: params);
    return result ;
  }
}