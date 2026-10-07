import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/setting/data/model/earn_invite_model.dart';
import 'package:general/src/features/setting/data/model/invite_user_model.dart';
import 'package:general/src/features/setting/data/model/privacy_policy.dart';
import '../../../../core/index.dart';
import '../model/get_vip_prev.dart';

abstract class BaseRemoteDataSource {
  Future<BaseResponse<List<GetVipPrevModel>>> getVipPrev();

  Future<BaseResponse<String>> prevActive(String type);

  Future<BaseResponse<String>> prevDispose(String type);

  Future<BaseResponse<String>> makeProblemReport(MakeProblemReportParam param);

  Future<BaseResponse<String>> boundNumber(SendCodeParameter param);

  Future<BaseResponse<String>> changePassword(BindAccountParam param);

  Future<BaseResponse<String>> changePhone(BindAccountParam param);

  Future<String> bingGoogle();
  Future<PrivacyPolicy> privacyPolicy();
  Future<String> deleteAccount();

  Future<BaseResponse<String>> logOut();
  Future<BaseResponse<List<UserModel>>> getBlockList();

  Future<BaseResponse<String>> sendInvitationCode({required String sendCode});
  Future<BaseResponse<EarnInviteModel>> getMyEarnInvite();
  Future<BaseResponse<List<InvitationUsersModel>>> getInviteUserList();
  Future<BaseResponse<String>> explainInvitation();
  Future<BaseResponse<String>> addInvitationCode({required String code});
  Future<BaseResponse<String>> extractInvitationCoins();
  Future<BaseResponse<String>> claimInvitationBonus();
}

class RemoteDataSource extends BaseRemoteDataSource {
  final DioFactory? dioFactory;

  RemoteDataSource({this.dioFactory});

  @override
  Future<BaseResponse<List<GetVipPrevModel>>> getVipPrev() async {
    final response = await dioFactory?.get(
      EndPoints.getVipPrev,
    );
    return BaseResponse.fromJson(
      response!.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => GetVipPrevModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> prevActive(String type) async {
    final response = await dioFactory?.post(
      EndPoints.prevsUse(type),
    );

    return BaseResponse.fromJson(
      response?.data,
    );
  }

  @override
  Future<BaseResponse<String>> prevDispose(String type) async {
    final response = await dioFactory?.post(
      EndPoints.prevsUnUse(type),
    );

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<String>> makeProblemReport(
      MakeProblemReportParam param) async {
    FormData formData = FormData.fromMap({
      "img": param.image != null
          ? await MultipartFile.fromFile(param.image!.path,
              filename: param.image!.path.split('/').last)
          : null,
      'txt': param.description,
      'contact': param.contact,
      'user_id': param.userId,
    });
    final response =
        await dioFactory?.post(EndPoints.makeProblemReport, data: formData);

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<String>> boundNumber(SendCodeParameter param) async {
    final body = {
      'phone': param.phone,
      'firebase_id_token': param.firebaseIdToken,
      'password': param.password,
    };
    final response = await dioFactory?.post(EndPoints.boundAccount, data: body);

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<String>> changePassword(BindAccountParam param) async {
    final body = {
      'phone': param.phoneNumber,
      if ((param.firebaseIdToken ?? '').isNotEmpty)
        'firebase_id_token': param.firebaseIdToken,
      'password': param.password,
    };
    final response = await dioFactory?.post(EndPoints.boundAccount, data: body);

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<String>> changePhone(BindAccountParam param) async {
    final body = {
      'phone': param.phoneNumber,
      if ((param.firebaseIdToken ?? '').isNotEmpty)
        'firebase_id_token': param.firebaseIdToken,
      if (param.currentPhone != "" || param.currentPhone != null)
        'current_phone': param.currentPhone,
    };
    final response = await dioFactory?.post(EndPoints.boundAccount, data: body);

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<String> bingGoogle() async {
    final googleSignIn = GoogleSignIn();
    final userModel = await googleSignIn.signIn(); // Only call this once
    if (userModel == null) {
      throw const SiginGoogleException();
    } else {
      final body = {"google_id": userModel.id};
      final response = await dioFactory?.post(
        EndPoints.boundAccount,
        data: body,
      );
      return response?.data['message'];
    }
  }

  @override
  Future<BaseResponse<String>> logOut() async {
    try {
      final google = GoogleSignIn();
      await google.signOut();
      google.disconnect();
    } catch (e) {
      // error
    }
    const MyDataModel().clearInstance();
    final response = await dioFactory?.post(
      EndPoints.logOut,
    );

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<PrivacyPolicy> privacyPolicy() async {
    final response = await dioFactory?.get(
      EndPoints.privacyPolicy,
    );

    return PrivacyPolicy.fromJson(response!.data);
  }

  @override
  Future<String> deleteAccount() async {
    final response = await dioFactory?.get(
      EndPoints.deleteAccount,
    );

    return response!.data['message'];
  }

  @override
  Future<BaseResponse<List<UserModel>>> getBlockList() async {
    final response = await dioFactory?.get(
      EndPoints.blockList,
    );
    return BaseResponse.fromJson(
      response!.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => UserModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> sendInvitationCode(
      {required String sendCode}) async {
    final response = await dioFactory?.get(
      EndPoints.inviteCode(sendCode),
    );

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<EarnInviteModel>> getMyEarnInvite() async {
    final response = await DioFactory().get(EndPoints.invitationEarn);

    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => EarnInviteModel.fromMap(json));
  }

  @override
  Future<BaseResponse<List<InvitationUsersModel>>> getInviteUserList() async {
    final response = await dioFactory?.get(
      EndPoints.invitationUsersEarn,
    );
    return BaseResponse.fromJson(
      response!.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => InvitationUsersModel.fromMap(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> explainInvitation() async {
    final response = await dioFactory?.get(
      EndPoints.explainInvitation,
    );

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<String>> addInvitationCode({required String code}) async {
    final response = await dioFactory?.get(
      EndPoints.addInvitationCode(code),
    );

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<String>> extractInvitationCoins() async {
    final response = await dioFactory?.post(
      EndPoints.invitationExtract,
    );

    return BaseResponse.fromJson(response?.data);
  }

  @override
  Future<BaseResponse<String>> claimInvitationBonus() async {
    final response = await dioFactory?.post(
      EndPoints.invitationClaimBonus,
    );

    return BaseResponse.fromJson(response?.data);
  }
}
