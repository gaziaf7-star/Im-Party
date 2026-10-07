import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';

import '../../data/model/get_badges_model.dart';

class GetBadgesUC extends UseCaseWithParams<BaseResponse<List<GetBadgesModel>>,String>{
  final ProfileBaseRepository _repo;
  GetBadgesUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<GetBadgesModel>>> call(String params) async {
    final result = await _repo.fetchBadges(type: params);
    return result;
  }
}
