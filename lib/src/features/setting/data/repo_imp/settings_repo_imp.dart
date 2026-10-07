import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_response.dart';
import 'package:general/src/core/base/parameters.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/setting/data/model/earn_invite_model.dart';
import 'package:general/src/features/setting/data/model/get_vip_prev.dart';
import 'package:general/src/features/setting/data/model/invite_user_model.dart';
import 'package:general/src/features/setting/data/model/privacy_policy.dart';
import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';

import '../data_source/remote_data_source.dart';

class SettingsRepositoryImp extends SettingsBaseRepository {
  final BaseRemoteDataSource baseRemoteDataSource;

  SettingsRepositoryImp({required this.baseRemoteDataSource});

  @override
  ResultFuture<BaseResponse<List<GetVipPrevModel>>> getVipPrev() {
    return execute<BaseResponse<List<GetVipPrevModel>>>(
        () => baseRemoteDataSource.getVipPrev());
  }

  @override
  ResultFuture<BaseResponse<String>> prevActive(String type) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.prevActive(type));
  }

  @override
  ResultFuture<BaseResponse<String>> prevDispose(String type) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.prevDispose(type));
  }

  @override
  ResultFuture<BaseResponse<String>> makeProblemReport(
      MakeProblemReportParam param) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.makeProblemReport(param));
  }

  @override
  ResultFuture<BaseResponse<String>> boundNumber(SendCodeParameter param) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.boundNumber(param));
  }

  @override
  ResultFuture<BaseResponse<String>> changePassword(BindAccountParam param) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.changePassword(param));
  }

  @override
  ResultFuture<BaseResponse<String>> changePhone(BindAccountParam param) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.changePhone(param));
  }

  @override
  ResultFuture<String> bindGmail() {
    return execute<String>(() => baseRemoteDataSource.bingGoogle());
  }

  @override
  ResultFuture<PrivacyPolicy> privacyPolicy() {
    return execute<PrivacyPolicy>(() => baseRemoteDataSource.privacyPolicy());
  }

  @override
  ResultFuture<String> deleteAccount() {
    return execute<String>(() => baseRemoteDataSource.deleteAccount());
  }

  @override
  ResultFuture<BaseResponse<String>> logOut() {
    return execute<BaseResponse<String>>(() => baseRemoteDataSource.logOut());
  }

  @override
  ResultFuture<BaseResponse<List<UserModel>>> getBlockList() {
    return execute<BaseResponse<List<UserModel>>>(
        () => baseRemoteDataSource.getBlockList());
  }

  @override
  ResultFuture<BaseResponse<String>> sendInvitationCode(
      {required String sendCode}) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.sendInvitationCode(sendCode: sendCode));
  }

  @override
  ResultFuture<BaseResponse<EarnInviteModel>> getMyEarnInvite() {
    return execute<BaseResponse<EarnInviteModel>>(
        () => baseRemoteDataSource.getMyEarnInvite());
  }

  @override
  ResultFuture<BaseResponse<List<InvitationUsersModel>>> getInviteUserList() {
    return execute<BaseResponse<List<InvitationUsersModel>>>(
        () => baseRemoteDataSource.getInviteUserList());
  }

  @override
  ResultFuture<BaseResponse<String>> explainInvitation() {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.explainInvitation());
  }


  @override
  ResultFuture<BaseResponse<String>> addInvitationCode({required String code}) {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.addInvitationCode(code: code));
  }

  @override
  ResultFuture<BaseResponse<String>> extractInvitationCoins() {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.extractInvitationCoins());
  }

  @override
  ResultFuture<BaseResponse<String>> claimInvitationBonus() {
    return execute<BaseResponse<String>>(
        () => baseRemoteDataSource.claimInvitationBonus());
  }
}
