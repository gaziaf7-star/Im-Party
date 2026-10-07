import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/setting/data/model/earn_invite_model.dart';
import 'package:general/src/features/setting/data/model/invite_user_model.dart';
import 'package:general/src/features/setting/data/model/privacy_policy.dart';
import 'package:general/src/core/base/parameters.dart';

import '../../../../core/base/base_response.dart';
import '../../data/model/get_vip_prev.dart';

abstract class SettingsBaseRepository {
  ResultFuture<BaseResponse<List<GetVipPrevModel>>> getVipPrev();
  ResultFuture<BaseResponse<String>> prevActive(String type);
  ResultFuture<BaseResponse<String>> prevDispose(String type);
  ResultFuture<BaseResponse<String>> makeProblemReport(
      MakeProblemReportParam param);
  ResultFuture<BaseResponse<String>> boundNumber(SendCodeParameter param);

  ResultFuture<BaseResponse<String>> changePassword(BindAccountParam param);

  ResultFuture<BaseResponse<String>> changePhone(BindAccountParam param);
  ResultFuture<BaseResponse<String>> logOut();
  ResultFuture<String> bindGmail();
  ResultFuture<String> deleteAccount();
  ResultFuture<PrivacyPolicy> privacyPolicy();
  ResultFuture<BaseResponse<List<UserModel>>> getBlockList();

  ResultFuture<BaseResponse<String>> sendInvitationCode(
      {required String sendCode});

  ResultFuture<BaseResponse<EarnInviteModel>> getMyEarnInvite();

  ResultFuture<BaseResponse<List<InvitationUsersModel>>> getInviteUserList();

  ResultFuture<BaseResponse<String>> explainInvitation();
  ResultFuture<BaseResponse<String>> addInvitationCode({required String code});
  ResultFuture<BaseResponse<String>> extractInvitationCoins();
  ResultFuture<BaseResponse<String>> claimInvitationBonus();
}
