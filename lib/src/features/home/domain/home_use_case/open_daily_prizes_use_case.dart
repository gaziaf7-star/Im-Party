import 'package:general/src/core/index.dart';
import '../../home.dart';

class OpenDailyPrizeUC extends UseCaseWithoutParams<String> {

  final BaseHomeRepository _repo;


  OpenDailyPrizeUC( this._repo);

  @override
  ResultFuture<String> call() async{
    final result = await _repo.openDailyPrize() ;
    return result ;
  }

}