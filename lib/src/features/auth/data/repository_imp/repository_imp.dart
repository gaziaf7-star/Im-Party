import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/data/model/agency_badge_model.dart';
import 'package:general/src/features/auth/data/model/colors_model.dart';
import 'package:general/src/features/auth/data/model/config_model.dart';
import 'package:general/src/features/auth/data/model/vip_frames_model.dart';
import 'package:general/src/features/auth/data/model/wabbles_model.dart';
import 'package:general/src/features/setting/data/model/switch_account_model.dart';

class AuthenticationRepositoryImp extends BaseAuthenticationRepository {
  final BaseAuthenticationRemoteDataSource _remote;

  AuthenticationRepositoryImp(this._remote);

  @override
  ResultFuture<BaseResponse<SwitchLoginAccountModel>> login(
      AuthParameter authParameter) {
    return execute<BaseResponse<SwitchLoginAccountModel>>(
        () => _remote.login(authParameter));
  }

  @override
  ResultFuture<BaseResponse<SwitchLoginAccountModel>> signInAsGuest() {
    return execute<BaseResponse<SwitchLoginAccountModel>>(
        () => _remote.signInAsGuest());
  }

  @override
  ResultFuture<BaseResponse<List<CountryModel>>> fetchCountries() {
    return execute<BaseResponse<List<CountryModel>>>(
      () => _remote.fetchCountries(),
    );
  }

  @override
  ResultFuture<BaseResponse<List<CountryCategoryModel>>>
      fetchCountryCategories() {
    return execute<BaseResponse<List<CountryCategoryModel>>>(
      () => _remote.fetchCountryCategories(),
    );
  }

  @override
  ResultFuture<BaseResponse<List<CountryModel>>> fetchCountriesByCategory(
      int categoryId) {
    return execute<BaseResponse<List<CountryModel>>>(
      () => _remote.fetchCountriesByCategory(categoryId),
    );
  }

  @override
  ResultFuture<BaseResponse<GoogleModel>> sigInWithGoogle() async {
    return execute<BaseResponse<GoogleModel>>(() => _remote.sigInWithGoogle());
  }

  @override
  ResultFuture<BaseResponse<AppleModel>> sigInWithApple() async {
    return execute<BaseResponse<AppleModel>>(() => _remote.sigInWithApple());
  }

  @override
  ResultFuture<BaseResponse<AuthWithHuaweiModel>> sigInWithHuawei() async {
    return execute<BaseResponse<AuthWithHuaweiModel>>(
        () => _remote.sigInWithHuawei());
  }

  @override
  ResultFuture<BaseResponse<String>> register(
      {required AuthParameterUC params}) {
    return execute<BaseResponse<String>>(
        () => _remote.register(params: params));
  }

  @override
  ResultFuture<BaseResponse<String>> replaceCoverImage(
      {required ReplaceCoverImageParametersUC params}) {
    return execute<BaseResponse<String>>(
        () => _remote.replaceCoverImage(params: params));
  }

  @override
  ResultFuture<BaseResponse<MyDataModel>> addInfo(
      {required InformationParametersUC params}) {
    return execute<BaseResponse<MyDataModel>>(
        () => _remote.addInfo(params: params));
  }

  @override
  ResultFuture<BaseResponse<String>> forgetPassword(
      {required AuthParameterUC params}) {
    return execute<BaseResponse<String>>(
        () => _remote.forgetPassword(params: params));
  }

  @override
  ResultFuture<BaseResponse<String>> changePassword(SendCodeParameter param) {
    return execute<BaseResponse<String>>(() => _remote.changePassword(param));
  }

  @override
  ResultFuture<BaseResponse<String>> changePhone(SendCodeParameter param) {
    return execute<BaseResponse<String>>(() => _remote.changePhone(param));
  }

  @override
  ResultFuture<ConfigModel> configApp(ConfigModelBody param) {
    return execute<ConfigModel>(() => _remote.getConfigApp(param));
  }

  @override
  ResultFuture<BaseResponse<List<VipFramesModel>>> getVipFrames() {
    return execute<BaseResponse<List<VipFramesModel>>>(
        () => _remote.getVipFrames());
  }

  @override
  ResultFuture<List<AgencyBadgeModel>> getAgencyBadges() {
    return execute<List<AgencyBadgeModel>>(() => _remote.getAgencyBadges());
  }

  @override
  ResultFuture<List<WabblesModel>> getWabbles() {
    return execute<List<WabblesModel>>(() => _remote.getWabbles());
  }

  @override
  ResultFuture<BaseResponse<bool>> checkPhone(String phone) {
    return execute<BaseResponse<bool>>(() => _remote.checkPhone(phone));
  }

  @override
  ResultFuture<BaseResponse<ColorsModel>> fetchColors({bool forceRefresh = false}) {
    return execute<BaseResponse<ColorsModel>>(
        () => _remote.fetchColors(forceRefresh: forceRefresh));
  }

  @override
  ResultFuture<BaseResponse<bool>> getRealtimeSettings() {
    return execute<BaseResponse<bool>>(
        () => _remote.getRealtimeSettings());
  }

  @override
  ResultFuture<String> setStorageUrl() {
    return execute<String>(() => _remote.setStorageUrl());
  }

  @override
  ResultFuture<BaseResponse<String>> getFirebaseCustomToken() {
    return execute<BaseResponse<String>>(
        () => _remote.getFirebaseCustomToken());
  }
}
