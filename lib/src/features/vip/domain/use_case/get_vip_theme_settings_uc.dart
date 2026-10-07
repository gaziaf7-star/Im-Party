import 'package:general/src/core/index.dart';
import 'package:general/src/features/vip/data/models/vip_theme_setting.dart';
import 'package:general/src/features/vip/domain/repository/vip_base_repository.dart';

class GetVipThemeSettingsUc
    extends UseCaseWithoutParams<BaseResponse<List<VipThemeSetting>>> {
  final VipBaseRepository _repo;

  GetVipThemeSettingsUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<VipThemeSetting>>> call() async {
    return await _repo.getVipThemeSettings();
  }
}
