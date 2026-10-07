import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/setting/data/model/switch_account_model.dart';

/// Quick login: sign in with no credential at all.
///
/// The handset's stable device id IS the identity, so the same phone always
/// resolves to the same account and a guest keeps their coins, level and
/// backpack without ever giving an email or a phone number. Signing in with
/// Google later binds that same account rather than starting a new one.
class GuestLoginUC extends UseCaseWithoutParams<
    BaseResponse<SwitchLoginAccountModel>> {
  final BaseAuthenticationRepository _repo;

  const GuestLoginUC(this._repo);

  @override
  ResultFuture<BaseResponse<SwitchLoginAccountModel>> call() =>
      _repo.signInAsGuest();
}
