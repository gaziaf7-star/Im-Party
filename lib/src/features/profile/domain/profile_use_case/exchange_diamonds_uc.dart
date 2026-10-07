import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';


class ExchangeDiamondsUC extends UseCaseWithParams<String,String>{
  final ProfileBaseRepository _repo;
  ExchangeDiamondsUC(this._repo);

  @override
  ResultFuture<String> call(String params) async {
    final result = await _repo.exchangeDiamond(itemId: params);
    return result;
  }
}
