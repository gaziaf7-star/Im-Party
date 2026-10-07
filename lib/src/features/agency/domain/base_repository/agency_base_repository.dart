import 'package:general/src/core/base/base_response.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/agency_more_info_model.dart';
import 'package:general/src/features/agency/data/model/form_model.dart';
import 'package:general/src/features/agency/data/model/information_agency_model.dart';
import 'package:general/src/features/agency/data/model/old_agency_model.dart';
import 'package:general/src/features/agency/data/model/search_user_agency_model.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/base/parameters.dart';
import '../../../auth/data/model/country_model.dart';
import '../../data/model/hosts_agency_dollars_records_model.dart';

abstract class AgencyBaseRepository {
  ResultFuture<BaseResponse<AgencyHostReportModel>> agencyHostReport(
      AgencyHistoryParam agencyHistoryParam);

  ResultFuture<BaseResponse<AgencySearchModel>> agencySearch(
      {required String id, String? page});
  

  ResultFuture<BaseResponse<List<AgencyHistoryModel>>> fetchAgencyHistory(
      AgencyHistoryParam agencyHistoryParam);

  ResultFuture<BaseResponse<List<AgencyMemberModel>>> agencyMember(String type);

  ResultFuture<BaseResponse<List<ShowAgencyRequestModel>>> agencyRequests(
      String type);

  ResultFuture<BaseResponse<String>> agencyRequestsAction(
      AgencyRequestsActionParam agencyRequestsActionParam);

  ResultFuture<BaseResponse<InformationAgencyModel>> informationAgency(
      AgencyHistoryParam param);

  ResultFuture<BaseResponse<String>> kickOutAgency(String userId);

  ResultFuture<BaseResponse<String>> leaveAgency();

  ResultFuture<BaseResponse<String>> makeUserAdmin(AgencyRequestsActionParam param);

  ResultFuture<BaseResponse<ShowAgencyModel>> showAgency(int? id);

  ResultFuture<BaseResponse<String>> joinToAgency(
      JoinAgencyParam joinAgencyParam);

  ResultFuture<BaseResponse<ChargeModel>> chargeTo(ChargeToParam param);

  ResultFuture<BaseResponse<ChargeModel>> chargeDollarsForUsers(
      ChargeToParam param);
  ResultFuture<BaseResponse<List<PaymentsGetwaysModel>>>
  fetchPaymentsGetWaysData();
  ResultFuture<BaseResponse<List<ShippingAgentRequestModel>>>
  fetchShippingAgentRequests(int type);
  ResultFuture<BaseResponse<String>> makeShippingAgentRequestAction(
      ShippingAgentRequestActionParam shippingAgentRequestActionParam);
  ResultFuture<BaseResponse<List<CountryModel>>> fetchShippingAgentCountries();
  ResultFuture<BaseResponse<String>> makeShippingAgentToAdminWithdrawelRequest(
      MakeShippingAgentToAdminWithdrawelRequestParam
      param);
  ResultFuture<String> chargeCoinForUsers(ChargeToParam param);

  ResultFuture<BaseResponse<List<DetailsChargeAgencyModel>>> fetchChargeAgencyDetails(
      FetchChargeAgencyDetailsParam param);

  ResultFuture<BaseResponse<ChargeAgencyInfoModel>> fetchChargeAgency(int? id);


  ResultFuture<BaseResponse<ChargeAgencyInfoModel>> updateChargeAgency(
      UpdateChargeAgencyParam param);


  ResultFuture<BaseResponse<List<HostRequestsModel>>> fetchHostRequests(String type);

  ResultFuture<BaseResponse<String>> hostRequestAction(
      AgencyRequestsActionParam param);
  ResultFuture<BaseResponse<SettingModel>> fetchSettings();

  ResultFuture<BaseResponse<String>> sendConfirmationRequest(
      SendConfirmationRequestParam param);
  ResultFuture<BaseResponse<List<UserGoogleCoinsHistoryModel>>> fetchGoogleCoinsHistory();
  ResultFuture<BaseResponse<List<UerChargeCoinsHistoryModel>>>
  fetchChargeCoinsHistory();

  ResultFuture<BaseResponse<List<ShippingAgentsFullDataModel>>> fetchShippingAgentsFullDataModel(
      FetchShippingAgentsFullDataModelParam? param);

  ResultFuture<BaseResponse<String>> sendWithdrawelRequest(SendWithdrawalRequestParam param);
  ResultFuture<BaseResponse<InformationAgencyModel>> updateAgencyData(UpdateAgencyParam params);

  ResultFuture<BaseResponse<MainResponseModel>> searchUserAgency(SearchUserAgencyParam param);
  ResultFuture<BaseResponse<OverallStatsModel>> fetchMoreInfoAgency(
      AgencyHistoryParam params);

  ResultFuture<BaseResponse<List<UserStarModel>>> fetchAgencyStars(
      AgencyHistoryParam param);

  ResultFuture<BaseResponse<List<UserStarModel>>> fetchAgencyHeros(
      AgencyHistoryParam param);

  ResultFuture<BaseResponse<List<UserStarModel>>> fetchAgencyAdmins(AgencyHistoryParam param);
  ResultFuture<BaseResponse<List<AgencyMemberChargesHistoryModel>>>
  agencyMemberChargesHistory(String type);
  ResultFuture<BaseResponse<HostSAgencyDataModel>> hostSAgencyData(AgencyHistoryParam params);
  ResultFuture<BaseResponse<List<OldAgencyModel>>> getOldAgenciesIWereIn();
  ResultFuture<BaseResponse<List<HostsAgencyDollarsRecordsModel>>> hostsAgencyDollarsRecord(FetchHostsAgencyDollarsParam param);

  ResultFuture<BaseResponse<List<FormModel>>> fetchFormList({required String type});
}