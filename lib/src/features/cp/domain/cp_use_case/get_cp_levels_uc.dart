
import 'package:general/src/features/cp/cp.dart';
import '../../../../core/index.dart';

class GetCpLevelsGiftsUC extends UseCaseWithoutParams<BaseResponse<List<CpRelationLevelsGiftsModel>>>{
  final CpBaseRepository _repo;
  GetCpLevelsGiftsUC(this._repo);


  @override
  ResultFuture<BaseResponse<List<CpRelationLevelsGiftsModel>>> call() async {
    final result = await _repo.getRelationsCpLevelsGifts();
    return result;
  }

}