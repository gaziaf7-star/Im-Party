import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/data/model/agency_badge_model.dart';
import 'package:general/src/features/auth/data/model/config_model.dart';
import 'package:general/src/features/auth/data/model/vip_frames_model.dart';
import 'package:general/src/features/auth/data/model/wabbles_model.dart';
import 'package:general/src/features/setting/data/model/switch_account_model.dart';

import '../../data/model/colors_model.dart';

abstract class BaseAuthenticationRepository {
  ResultFuture<BaseResponse<SwitchLoginAccountModel>> login(
      AuthParameter authParameter);

  /// Quick login — no credential; the device is the identity.
  ResultFuture<BaseResponse<SwitchLoginAccountModel>> signInAsGuest();
  ResultFuture<BaseResponse<List<CountryModel>>> fetchCountries();
  ResultFuture<BaseResponse<GoogleModel>> sigInWithGoogle();
  ResultFuture<BaseResponse<AppleModel>> sigInWithApple();
  ResultFuture<BaseResponse<AuthWithHuaweiModel>> sigInWithHuawei();
  ResultFuture<BaseResponse<String>> register({
    required AuthParameterUC params,
  });
  ResultFuture<BaseResponse<String>> forgetPassword({
    required AuthParameterUC params,
  });
  ResultFuture<BaseResponse<String>> replaceCoverImage({
    required ReplaceCoverImageParametersUC params,
  });
  ResultFuture<BaseResponse<MyDataModel>> addInfo({
    required InformationParametersUC params,
  });
  ResultFuture<BaseResponse<String>> changePassword(SendCodeParameter param);
  ResultFuture<BaseResponse<String>> changePhone(SendCodeParameter param);
  ResultFuture<ConfigModel> configApp(ConfigModelBody param);
  ResultFuture<BaseResponse<List<VipFramesModel>>> getVipFrames();
  ResultFuture<List<AgencyBadgeModel>> getAgencyBadges();
  ResultFuture<List<WabblesModel>> getWabbles();
  ResultFuture<BaseResponse<bool>> checkPhone(String phone);
  ResultFuture<BaseResponse<ColorsModel>> fetchColors({bool forceRefresh});
  ResultFuture<BaseResponse<bool>> getRealtimeSettings();

  ResultFuture<BaseResponse<List<CountryCategoryModel>>>
      fetchCountryCategories();

  ResultFuture<BaseResponse<List<CountryModel>>> fetchCountriesByCategory(
      int categoryId);

  ResultFuture<String> setStorageUrl();

  ResultFuture<BaseResponse<String>> getFirebaseCustomToken();
}
