import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';

class MakeWalletWithdrawUC extends UseCaseWithParams<String, MakeWalletWithdrawParams> {
  final ProfileBaseRepository _repo;
  MakeWalletWithdrawUC(this._repo);

  @override
  ResultFuture<String> call(MakeWalletWithdrawParams params) async {
    return _repo.makeWalletWithdraw(params);
  }
}