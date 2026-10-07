import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/agency_more_info_model.dart';
import 'package:general/src/features/agency/data/model/form_model.dart';
import 'package:general/src/features/agency/data/model/hosts_agency_dollars_records_model.dart';
import 'package:general/src/features/agency/data/model/information_agency_model.dart';
import 'package:general/src/features/agency/data/model/old_agency_model.dart';
import 'package:general/src/features/agency/data/model/search_user_agency_model.dart';

import '../../../../core/index.dart';
import '../../../auth/auth.dart';

abstract class BaseAgencyRemoteDataSource {
  Future<BaseResponse<AgencyHostReportModel>> fetchAgencyHostReport(
      AgencyHistoryParam params);

  Future<BaseResponse<AgencySearchModel>> agencySearch(
      {required String id, String? page});

  Future<BaseResponse<List<AgencyHistoryModel>>> fetchAgencyHistory(
      AgencyHistoryParam params);

  Future<BaseResponse<List<AgencyMemberModel>>> fetchAgencyMembers(String type);

  Future<BaseResponse<List<ShowAgencyRequestModel>>> fetchAgencyRequests(
      String type);

  Future<BaseResponse<String>> agencyRequestsAction(
      AgencyRequestsActionParam params);

  Future<BaseResponse<InformationAgencyModel>> fetchInformationAgency(
      AgencyHistoryParam params);

  Future<BaseResponse<String>> kickOutAgency(String userId);

  Future<BaseResponse<List<AgencyMemberChargesHistoryModel>>>
      agencyMemberChargesHistory(String type);

  Future<BaseResponse<String>> leaveAgency();

  Future<BaseResponse<String>> makeUserAdmin(AgencyRequestsActionParam param);

  Future<BaseResponse<ShowAgencyModel>> showAgency(int? id);

  Future<BaseResponse<String>> joinToAgency(JoinAgencyParam params);

  Future<BaseResponse<ChargeModel>> chargeToUsers(ChargeToParam params);

  Future<BaseResponse<ChargeModel>> chargeDollarsForUsers(ChargeToParam params);

  Future<BaseResponse<List<PaymentsGetwaysModel>>> fetchPaymentGetwaysData();

  Future<BaseResponse<List<ShippingAgentRequestModel>>>
      fetchShippingAgentRequests(int type);

  Future<BaseResponse<String>> makeShippingAgentRequestAction(
      ShippingAgentRequestActionParam params);

  Future<BaseResponse<List<CountryModel>>> fetchShippingAgencyCountries();

  Future<BaseResponse<String>> makeShippingAgentToAdminWithdrawelRequest(
      MakeShippingAgentToAdminWithdrawelRequestParam params);

  Future<String> chargeCoinForUsers(ChargeToParam params);

  Future<BaseResponse<List<DetailsChargeAgencyModel>>>
      fetchChargeAgenciesDetails(FetchChargeAgencyDetailsParam params);

  Future<BaseResponse<ChargeAgencyInfoModel>> fetchChargeAgencyInfo(int? id);

  Future<BaseResponse<ChargeAgencyInfoModel>> updateChargeAgency(
      UpdateChargeAgencyParam params);

  Future<BaseResponse<List<HostRequestsModel>>> fetchHostRequests(String type);

  Future<BaseResponse<String>> hostRequestAction(
      AgencyRequestsActionParam params);

  Future<BaseResponse<SettingModel>> fetchSettings();

  Future<BaseResponse<List<UserGoogleCoinsHistoryModel>>>
      fetchGoogleCoinsHistory();

  Future<BaseResponse<List<UerChargeCoinsHistoryModel>>>
      fetchChargeCoinsHistory();

  Future<BaseResponse<String>> sendConfirmationRequest(
      SendConfirmationRequestParam params);

  Future<BaseResponse<List<ShippingAgentsFullDataModel>>>
      fetchShippingAgentsFullDataModel(
          FetchShippingAgentsFullDataModelParam? params);

  Future<BaseResponse<String>> sendWithdrawelRequest(
      SendWithdrawalRequestParam params);

  Future<BaseResponse<InformationAgencyModel>> updateAgencyData(
      UpdateAgencyParam params);

  Future<BaseResponse<MainResponseModel>> searchUserAgency(
      SearchUserAgencyParam param);

  Future<BaseResponse<OverallStatsModel>> fetchMoreInfoAgency(
      AgencyHistoryParam params);

  Future<BaseResponse<HostSAgencyDataModel>> hostSAgencyData(
      AgencyHistoryParam params);

  Future<BaseResponse<List<UserStarModel>>> fetchAgencyStars(
      AgencyHistoryParam param);

  Future<BaseResponse<List<UserStarModel>>> fetchAgencyHeros(
      AgencyHistoryParam param);

  Future<BaseResponse<List<UserStarModel>>> fetchAgencyAdmins(
      AgencyHistoryParam param);

  Future<BaseResponse<List<OldAgencyModel>>> getOldAgenciesIWereIn();

  Future<BaseResponse<List<HostsAgencyDollarsRecordsModel>>>
      hostsAgencyDollarsRecord(FetchHostsAgencyDollarsParam param);

  Future<BaseResponse<List<FormModel>>> fetchFormList({required String type});
}

class AgencyRemotelyDataSource extends BaseAgencyRemoteDataSource {
  final DioFactory _dio;

  AgencyRemotelyDataSource(this._dio);

  @override
  Future<BaseResponse<AgencyHostReportModel>> fetchAgencyHostReport(
      AgencyHistoryParam params) async {
    final response = await _dio.post(
      EndPoints.agencyHostReport,
      data: {"month": params.month, "year": params.year, 'page': params.page},
    );
    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => AgencyHostReportModel.fromJson(json));
  }

  @override
  Future<BaseResponse<AgencySearchModel>> agencySearch(
      {required String id, String? page}) async {
    final response = await _dio.post(
      EndPoints.agencySearch(id: id, page: page),
    );

    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => AgencySearchModel.fromJson(json));
  }

  @override
  Future<BaseResponse<List<AgencyHistoryModel>>> fetchAgencyHistory(
      AgencyHistoryParam params) async {
    final response = await _dio.post(
      EndPoints.agencyHistory,
      data: {"month": params.month, "year": params.year, 'page': params.page},
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => AgencyHistoryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<AgencyMemberModel>>> fetchAgencyMembers(
      String type) async {
    final response = await _dio.post(EndPoints.showAgencyMembers, data: {
      'page': type,
    });
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => AgencyMemberModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<ShowAgencyRequestModel>>> fetchAgencyRequests(
      String type) async {
    final response = await _dio.get(
      EndPoints.agencyMember(type),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => ShowAgencyRequestModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> agencyRequestsAction(
      AgencyRequestsActionParam params) async {
    final response = await _dio.post(EndPoints.agencyRequestsAction,
        data: {'user_id': params.id, "accept": params.action});
    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<InformationAgencyModel>> fetchInformationAgency(
      AgencyHistoryParam params) async {
    final response = await _dio.get(
      EndPoints.showAgencyInformation(
          params.month, params.year, params.agencyId),
    );
    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => InformationAgencyModel.fromJson(json));
  }

  @override
  Future<BaseResponse<String>> kickOutAgency(String userId) async {
    final response =
        await _dio.post(EndPoints.kickOutAgency, data: {"user_id": userId});
    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<String>> leaveAgency() async {
    final response = await _dio.post(
      EndPoints.leaveAgency,
    );
    return response.data['message'];
  }

  @override
  Future<BaseResponse<String>> makeUserAdmin(
      AgencyRequestsActionParam param) async {
    final response = await _dio.post(EndPoints.makeUserAdmin,
        data: {"user_id": param.id, 'type': param.answer});
    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<ShowAgencyModel>> showAgency(int? id) async {
    final response = await _dio.get(
      EndPoints.showAgency(id),
    );
    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => ShowAgencyModel.fromJson(json));
  }

  @override
  Future<BaseResponse<String>> joinToAgency(JoinAgencyParam params) async {
    final response = await _dio.post(EndPoints.joinToAgencies,
        data: {'agency_id': params.agencyId, 'whatsapp': params.whatsAppNum});
    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<ChargeModel>> chargeToUsers(ChargeToParam params) async {
    final response = await _dio.post(EndPoints.chargeTo, data: {
      'to_id': params.userId,
      'usd': params.amount,
      'type': params.userType,
    });
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => ChargeModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<ChargeModel>> chargeDollarsForUsers(
      ChargeToParam params) async {
    final response = await _dio.post(EndPoints.chargeDollarsForUser, data: {
      'id': params.userId,
      'amount': params.amount,
      'type': params.userType,
    });
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => ChargeModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<List<PaymentsGetwaysModel>>>
      fetchPaymentGetwaysData() async {
    final response = await _dio.get(
      EndPoints.shippingAgentsGetways,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => PaymentsGetwaysModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<ShippingAgentRequestModel>>>
      fetchShippingAgentRequests(int type) async {
    final response = await _dio.get(
      EndPoints.getShippingAgentRequests(type),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => ShippingAgentRequestModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> makeShippingAgentRequestAction(
      ShippingAgentRequestActionParam params) async {
    final response = await _dio.post(EndPoints.shippingAgentRequests, data: {
      'request_id': params.requestId,
      'answer': params.actionType,
    });
    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<List<CountryModel>>>
      fetchShippingAgencyCountries() async {
    final response = await _dio.get(
      EndPoints.shippingAgentsCountries,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => CountryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> makeShippingAgentToAdminWithdrawelRequest(
      MakeShippingAgentToAdminWithdrawelRequestParam params) async {
    final response =
        await _dio.post(EndPoints.makeShippingAgentToAdminWithdrawel, data: {
      'amount': params.amount,
      'type': params.type,
    });
    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<String> chargeCoinForUsers(ChargeToParam params) async {
    final response = await _dio.post(EndPoints.chargeCoinForUser, data: {
      'id': params.userId,
      "amount": params.amount,
      "type": params.userType
    });
    return response.data["message"];
  }

  @override
  Future<BaseResponse<List<DetailsChargeAgencyModel>>>
      fetchChargeAgenciesDetails(FetchChargeAgencyDetailsParam params) async {
    final response = await _dio.get(
      EndPoints.getChargeAgencyDetails(params.type, params.page),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => DetailsChargeAgencyModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<ChargeAgencyInfoModel>> fetchChargeAgencyInfo(
      int? id) async {
    final response = await _dio.get(
      EndPoints.getChargeAgency(id),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => ChargeAgencyInfoModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<ChargeAgencyInfoModel>> updateChargeAgency(
      UpdateChargeAgencyParam params) async {
    FormData formData;

    if (params.image == null) {
      formData = FormData.fromMap({
        if (params.name != null) "name": params.name,
        if (params.appOwnerId != null)
          "app_owner_id": params.appOwnerId.toString(),
        if (params.phone != null) "phone": params.phone,
        if (params.paymentIds != null) 'paymentGateways': params.paymentIds,
        if (params.countriesIds != null) "countries": params.countriesIds,
        if (params.agencyId != null) "agency_id": params.agencyId,
      });
    } else {
      File file = params.image!;
      String fileName = file.path.split('/').last;

      formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: fileName),
        if (params.name != null) "name": params.name,
        if (params.appOwnerId != null)
          "app_owner_id": params.appOwnerId.toString(),
        if (params.phone != null) "phone": params.phone,
        if (params.paymentIds != null) 'paymentGateways': params.paymentIds,
        if (params.countriesIds != null) "countries": params.countriesIds,
        if (params.agencyId != null) "agency_id": params.agencyId,
      });
    }

    final response = await _dio.post(
      EndPoints.updateChargeAgency,
      data: formData,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => ChargeAgencyInfoModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<List<HostRequestsModel>>> fetchHostRequests(
      String type) async {
    final response = await _dio.get(
      EndPoints.getHostRequests(type),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => HostRequestsModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> hostRequestAction(
      AgencyRequestsActionParam params) async {
    final response = await _dio.post(
      EndPoints.hostRequestAction,
      data: {"request_id": params.id, "answer": params.answer},
    );
    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<SettingModel>> fetchSettings() async {
    final response = await _dio.get(
      EndPoints.getSettings,
    );
    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => SettingModel.fromJson(json));
  }

  @override
  Future<BaseResponse<List<UserGoogleCoinsHistoryModel>>>
      fetchGoogleCoinsHistory() async {
    final response = await _dio.get(
      EndPoints.googleCoinsHistory,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => UserGoogleCoinsHistoryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<UerChargeCoinsHistoryModel>>>
      fetchChargeCoinsHistory() async {
    final response = await _dio.post(
      EndPoints.chargedCoinsHistory,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => UerChargeCoinsHistoryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> sendConfirmationRequest(
      SendConfirmationRequestParam params) async {
    File file = params.image!;
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "bill_image": await MultipartFile.fromFile(file.path, filename: fileName),
      'request_id': params.requestId,
    });
    final response = await _dio.post(
      EndPoints.shippingAgentTransferConfirmAction,
      data: formData,
    );
    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<String>> sendWithdrawelRequest(
      SendWithdrawalRequestParam params) async {
    Map<String, dynamic> body = {
      'country_id': params.countryId,
      'payment_gateway_id': params.paymentId,
      'agent_id': params.agentId,
      'usd': params.usd,
      'note': params.note,
    };

    final response = await _dio.post(
      EndPoints.makeWithdrawelRequest,
      data: body,
    );
    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<List<ShippingAgentsFullDataModel>>>
      fetchShippingAgentsFullDataModel(
          FetchShippingAgentsFullDataModelParam? params) async {
    Map<String, dynamic> body = {
      'country_id': params?.countryId ?? '',
      'payment_id': params?.paymentId ?? '',
      'page': params?.page ?? 1,
    };
    final response = await _dio.post(
      EndPoints.getShippingAgentsFullData,
      data: body,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => ShippingAgentsFullDataModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<InformationAgencyModel>> updateAgencyData(
      UpdateAgencyParam params) async {
    // Prepare the multipart request data
    Map<String, dynamic> body = {
      'name': params.name ?? '',
      'contents': params.bio ?? '',
    };

    // Use FormData to handle the file upload
    FormData formData = FormData.fromMap(body);

    // Add the file if it exists
    if (params.image != null) {
      formData.files.add(
        MapEntry(
          'img',
          await MultipartFile.fromFile(
            params.image!.path, // Ensure you pass the file path
            filename:
                params.image!.path.split('/').last, // Extract the filename
          ),
        ),
      );
    }
    final response = await _dio.post(
      EndPoints.updateAgencyData(params.agencyId ?? ''),
      data: formData,
      options: Options(headers: {
        'Content-Type': 'multipart/form-data',
        // Explicitly set multipart content type
      }, method: 'POST'),
    );

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => InformationAgencyModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<MainResponseModel>> searchUserAgency(
      SearchUserAgencyParam param) async {
    final response = await _dio.post(EndPoints.searchUserAgency, data: {
      'type': param.type,
      'id': param.id,
    });

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => MainResponseModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<List<UserStarModel>>> fetchAgencyHeros(
      AgencyHistoryParam param) async {
    final response = await _dio.get(
      EndPoints.fetchAgencyHeros(
          param.month, param.year, param.agencyId, param.page ?? ''),
      // data: {"month": param.month, "year": param.year, 'page': param.page},
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => UserStarModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<UserStarModel>>> fetchAgencyStars(
      AgencyHistoryParam param) async {
    final response = await _dio.get(
      EndPoints.fetchAgencyStars(
          param.month, param.year, param.agencyId, param.page ?? ''),

      // data: {"month": param.month, "year": param.year, 'page': param.page},
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => UserStarModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<UserStarModel>>> fetchAgencyAdmins(
      AgencyHistoryParam param) async {
    final response = await _dio.get(
      EndPoints.fetchAgencyAdmins(
          param.month, param.year, param.agencyId, param.page ?? ''),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => UserStarModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<OverallStatsModel>> fetchMoreInfoAgency(
      AgencyHistoryParam params) async {
    final response = await _dio.get(
      EndPoints.fetchAgencyMoreInformation(params.month, params.year,
          params.agencyId, params.page ?? 1.toString()),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => OverallStatsModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<List<AgencyMemberChargesHistoryModel>>>
      agencyMemberChargesHistory(String type) async {
    final response =
        await _dio.post(EndPoints.agencyMemberChargesHistory, data: {
      'type': type,
    });
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => AgencyMemberChargesHistoryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<HostSAgencyDataModel>> hostSAgencyData(
      AgencyHistoryParam params) async {
    final response = await _dio.get(
      EndPoints.hostsAgencyData(params.month, params.year, params.agencyId),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => HostSAgencyDataModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<List<OldAgencyModel>>> getOldAgenciesIWereIn() async {
    final response = await _dio.get(
      EndPoints.getOldAgenciesIWereIn,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => OldAgencyModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<HostsAgencyDollarsRecordsModel>>>
      hostsAgencyDollarsRecord(FetchHostsAgencyDollarsParam param) async {
    final response = await _dio.get(
      EndPoints.hostsAgencyDollarsRecord(param.type, param.page),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => HostsAgencyDollarsRecordsModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<FormModel>>> fetchFormList({
    required String type,
  }) async {
    final response = await _dio.get(
      EndPoints.formList(/* type */ "host_agency"),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => FormModel.fromJson(element))
          .toList(),
    );
  }
}
