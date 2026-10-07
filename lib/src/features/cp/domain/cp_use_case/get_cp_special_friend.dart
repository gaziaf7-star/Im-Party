import 'package:general/src/features/cp/cp.dart';
import '../../../../core/index.dart';



class GetRelationsCpSpecialFriendUC extends UseCaseWithoutParams<BaseResponse<List<CpRelationLevelsGiftsModel>>>{
  final CpBaseRepository _repo;
  GetRelationsCpSpecialFriendUC(this._repo);


  @override
  ResultFuture<BaseResponse<List<CpRelationLevelsGiftsModel>>> call() async {
    final result = await _repo.getRelationsCpSpecialFriendLevelsGifts();
    return result;
  }

}