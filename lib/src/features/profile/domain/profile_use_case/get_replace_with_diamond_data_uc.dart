import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';

class GetReplaceWithGoldUC extends UseCaseWithoutParams<ReplaceWithGoldModel>{
  final ProfileBaseRepository _repo;
  GetReplaceWithGoldUC( this._repo);
  @override
  ResultFuture<ReplaceWithGoldModel> call() async {
    final result = await _repo.getReplaceWithDiamondData();
    return result;
  }
}
