import 'package:general/src/core/index.dart';

import '../../home.dart';

class DailyPrizesUseCase extends UseCaseWithoutParams<BaseResponse<DailyPrizesModel>> {

  final BaseHomeRepository _repo;


  DailyPrizesUseCase( this._repo);

  @override
  ResultFuture<BaseResponse<DailyPrizesModel>> call() async{
    final result = await _repo.fetchDailyPrizes() ;
    return result ;
  }

}