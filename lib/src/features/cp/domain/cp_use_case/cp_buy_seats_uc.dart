import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';


class CpBuySeatsUseCase extends UseCaseWithParams<String,String> {
     final CpBaseRepository _repo;
  CpBuySeatsUseCase(this._repo);

  
   @override
  ResultFuture<String> call(String params ) async {
    final result = await _repo.buyCpSeats(wareId: params);
    return result;
  }

}
