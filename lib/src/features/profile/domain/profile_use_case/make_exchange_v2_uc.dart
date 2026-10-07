import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';

class MakeExchangeV2UC extends UseCaseWithParams<String, MakeDiamondExchangeParams> {
  final ProfileBaseRepository _repo;
  MakeExchangeV2UC(this._repo);

  @override
  ResultFuture<String> call(MakeDiamondExchangeParams params) async {
    return _repo.makeExchangeV2(params);
  }
}