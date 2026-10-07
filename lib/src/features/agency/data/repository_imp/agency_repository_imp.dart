import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/agency_more_info_model.dart';
import 'package:general/src/features/agency/data/model/form_model.dart';
import 'package:general/src/features/agency/data/model/hosts_agency_dollars_records_model.dart';
import 'package:general/src/features/agency/data/model/information_agency_model.dart';
import 'package:general/src/features/agency/data/model/old_agency_model.dart';
import 'package:general/src/features/agency/data/model/search_user_agency_model.dart';

import '../../../../core/index.dart';
import '../../../auth/data/model/country_model.dart';

class AgencyRepositoryImp extends AgencyBaseRepository {
  final BaseAgencyRemoteDataSource baseAgencyRemotelyDataSource;

  AgencyRepositoryImp({required this.baseAgencyRemotelyDataSource});

  @override
  ResultFuture<BaseResponse<AgencyHostReportModel>> agencyHostReport(
      AgencyHistoryParam agencyHistoryParam) {
    return execute<BaseResponse<AgencyHostReportModel>>(() =>
        baseAgencyRemotelyDataSource.fetchAgencyHostReport(agencyHistoryParam));
  }

  @override
  ResultFuture<BaseResponse<AgencySearchModel>> agencySearch(
      {required String id, String? page}) async {
    return execute<BaseResponse<AgencySearchModel>>(
        () => baseAgencyRemotelyDataSource.agencySearch(
              id: id,
              page: page,
            ));
  }

  @override
  ResultFuture<BaseResponse<List<AgencyHistoryModel>>> fetchAgencyHistory(
      AgencyHistoryParam agencyHistoryParam) async {
    return execute<BaseResponse<List<AgencyHistoryModel>>>(() =>
        baseAgencyRemotelyDataSource.fetchAgencyHistory(agencyHistoryParam));
  }

  @override
  ResultFuture<BaseResponse<List<AgencyMemberModel>>> agencyMember(
      String type) {
    return execute<BaseResponse<List<AgencyMemberModel>>>(
        () => baseAgencyRemotelyDataSource.fetchAgencyMembers(type));
  }

  @override
  ResultFuture<BaseResponse<List<ShowAgencyRequestModel>>> agencyRequests(
      String type) {
    return execute<BaseResponse<List<ShowAgencyRequestModel>>>(
        () => baseAgencyRemotelyDataSource.fetchAgencyRequests(type));
  }

  @override
  ResultFuture<BaseResponse<String>> agencyRequestsAction(
      AgencyRequestsActionParam agencyRequestsActionParam) {
    return execute<BaseResponse<String>>(() => baseAgencyRemotelyDataSource
        .agencyRequestsAction(agencyRequestsActionParam));
  }

  @override
  ResultFuture<BaseResponse<InformationAgencyModel>> informationAgency(
      AgencyHistoryParam param) {
    return execute<BaseResponse<InformationAgencyModel>>(
        () => baseAgencyRemotelyDataSource.fetchInformationAgency(param));
  }

  @override
  ResultFuture<BaseResponse<String>> kickOutAgency(String userId) {
    return execute<BaseResponse<String>>(
        () => baseAgencyRemotelyDataSource.kickOutAgency(userId));
  }

  @override
  ResultFuture<BaseResponse<String>> leaveAgency() {
    return execute<BaseResponse<String>>(
        () => baseAgencyRemotelyDataSource.leaveAgency());
  }

  @override
  ResultFuture<BaseResponse<String>> makeUserAdmin(
      AgencyRequestsActionParam param) {
    return execute<BaseResponse<String>>(
        () => baseAgencyRemotelyDataSource.makeUserAdmin(param));
  }

  @override
  ResultFuture<BaseResponse<ShowAgencyModel>> showAgency(int? id) {
    return execute<BaseResponse<ShowAgencyModel>>(
        () => baseAgencyRemotelyDataSource.showAgency(id));
  }

  @override
  ResultFuture<BaseResponse<String>> joinToAgency(
      JoinAgencyParam joinAgencyParam) {
    return execute<BaseResponse<String>>(
        () => baseAgencyRemotelyDataSource.joinToAgency(joinAgencyParam));
  }

  @override
  ResultFuture<BaseResponse<ChargeModel>> chargeTo(ChargeToParam param) {
    return execute<BaseResponse<ChargeModel>>(
        () => baseAgencyRemotelyDataSource.chargeToUsers(param));
  }

  @override
  ResultFuture<BaseResponse<ChargeModel>> chargeDollarsForUsers(
      ChargeToParam param) {
    return execute<BaseResponse<ChargeModel>>(
        () => baseAgencyRemotelyDataSource.chargeDollarsForUsers(param));
  }

  @override
  ResultFuture<BaseResponse<List<PaymentsGetwaysModel>>>
      fetchPaymentsGetWaysData() {
    return execute<BaseResponse<List<PaymentsGetwaysModel>>>(
        () => baseAgencyRemotelyDataSource.fetchPaymentGetwaysData());
  }

  @override
  ResultFuture<BaseResponse<List<ShippingAgentRequestModel>>>
      fetchShippingAgentRequests(int type) {
    return execute<BaseResponse<List<ShippingAgentRequestModel>>>(
        () => baseAgencyRemotelyDataSource.fetchShippingAgentRequests(type));
  }

  @override
  ResultFuture<BaseResponse<String>> makeShippingAgentRequestAction(
      ShippingAgentRequestActionParam shippingAgentRequestActionParam) {
    return execute<BaseResponse<String>>(() => baseAgencyRemotelyDataSource
        .makeShippingAgentRequestAction(shippingAgentRequestActionParam));
  }

  @override
  ResultFuture<BaseResponse<List<CountryModel>>> fetchShippingAgentCountries() {
    return execute<BaseResponse<List<CountryModel>>>(
        () => baseAgencyRemotelyDataSource.fetchShippingAgencyCountries());
  }

  @override
  ResultFuture<BaseResponse<String>> makeShippingAgentToAdminWithdrawelRequest(
      MakeShippingAgentToAdminWithdrawelRequestParam param) {
    return execute<BaseResponse<String>>(() => baseAgencyRemotelyDataSource
        .makeShippingAgentToAdminWithdrawelRequest(param));
  }

  @override
  ResultFuture<String> chargeCoinForUsers(ChargeToParam param) {
    return execute<String>(
        () => baseAgencyRemotelyDataSource.chargeCoinForUsers(param));
  }

  @override
  ResultFuture<BaseResponse<List<DetailsChargeAgencyModel>>>
      fetchChargeAgencyDetails(FetchChargeAgencyDetailsParam param) {
    return execute<BaseResponse<List<DetailsChargeAgencyModel>>>(
        () => baseAgencyRemotelyDataSource.fetchChargeAgenciesDetails(param));
  }

  @override
  ResultFuture<BaseResponse<ChargeAgencyInfoModel>> fetchChargeAgency(int? id) {
    return execute<BaseResponse<ChargeAgencyInfoModel>>(
        () => baseAgencyRemotelyDataSource.fetchChargeAgencyInfo(id));
  }

  @override
  ResultFuture<BaseResponse<ChargeAgencyInfoModel>> updateChargeAgency(
      UpdateChargeAgencyParam param) {
    return execute<BaseResponse<ChargeAgencyInfoModel>>(
        () => baseAgencyRemotelyDataSource.updateChargeAgency(param));
  }

  @override
  ResultFuture<BaseResponse<List<HostRequestsModel>>> fetchHostRequests(
      String type) {
    return execute<BaseResponse<List<HostRequestsModel>>>(
        () => baseAgencyRemotelyDataSource.fetchHostRequests(type));
  }

  @override
  ResultFuture<BaseResponse<String>> hostRequestAction(
      AgencyRequestsActionParam param) {
    return execute<BaseResponse<String>>(
        () => baseAgencyRemotelyDataSource.hostRequestAction(param));
  }

  @override
  ResultFuture<BaseResponse<SettingModel>> fetchSettings() {
    return execute<BaseResponse<SettingModel>>(
        () => baseAgencyRemotelyDataSource.fetchSettings());
  }

  @override
  ResultFuture<BaseResponse<List<UserGoogleCoinsHistoryModel>>>
      fetchGoogleCoinsHistory() {
    return execute<BaseResponse<List<UserGoogleCoinsHistoryModel>>>(
      () => baseAgencyRemotelyDataSource.fetchGoogleCoinsHistory(),
    );
  }

  @override
  ResultFuture<BaseResponse<List<UerChargeCoinsHistoryModel>>>
      fetchChargeCoinsHistory() {
    return execute<BaseResponse<List<UerChargeCoinsHistoryModel>>>(
      () => baseAgencyRemotelyDataSource.fetchChargeCoinsHistory(),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> sendConfirmationRequest(
      SendConfirmationRequestParam param) {
    return execute<BaseResponse<String>>(
        () => baseAgencyRemotelyDataSource.sendConfirmationRequest(param));
  }

  @override
  ResultFuture<BaseResponse<String>> sendWithdrawelRequest(
      SendWithdrawalRequestParam param) {
    return execute<BaseResponse<String>>(
        () => baseAgencyRemotelyDataSource.sendWithdrawelRequest(param));
  }

  @override
  ResultFuture<BaseResponse<List<ShippingAgentsFullDataModel>>>
      fetchShippingAgentsFullDataModel(
          FetchShippingAgentsFullDataModelParam? param) {
    return execute<BaseResponse<List<ShippingAgentsFullDataModel>>>(() =>
        baseAgencyRemotelyDataSource.fetchShippingAgentsFullDataModel(param));
  }

  @override
  ResultFuture<BaseResponse<InformationAgencyModel>> updateAgencyData(
      UpdateAgencyParam params) {
    return execute<BaseResponse<InformationAgencyModel>>(
        () => baseAgencyRemotelyDataSource.updateAgencyData(params));
  }

  @override
  ResultFuture<BaseResponse<MainResponseModel>> searchUserAgency(
      SearchUserAgencyParam param) {
    return execute<BaseResponse<MainResponseModel>>(
        () => baseAgencyRemotelyDataSource.searchUserAgency(param));
  }

  @override
  ResultFuture<BaseResponse<OverallStatsModel>> fetchMoreInfoAgency(
      AgencyHistoryParam params) {
    return execute<BaseResponse<OverallStatsModel>>(
        () => baseAgencyRemotelyDataSource.fetchMoreInfoAgency(params));
  }

  @override
  ResultFuture<BaseResponse<List<UserStarModel>>> fetchAgencyHeros(
      AgencyHistoryParam param) {
    return execute<BaseResponse<List<UserStarModel>>>(
        () => baseAgencyRemotelyDataSource.fetchAgencyHeros(param));
  }

  @override
  ResultFuture<BaseResponse<List<UserStarModel>>> fetchAgencyStars(
      AgencyHistoryParam param) {
    return execute<BaseResponse<List<UserStarModel>>>(
        () => baseAgencyRemotelyDataSource.fetchAgencyStars(param));
  }

  @override
  ResultFuture<BaseResponse<List<UserStarModel>>> fetchAgencyAdmins(
      AgencyHistoryParam param) {
    return execute<BaseResponse<List<UserStarModel>>>(
        () => baseAgencyRemotelyDataSource.fetchAgencyAdmins(param));
  }

  @override
  ResultFuture<BaseResponse<List<AgencyMemberChargesHistoryModel>>>
      agencyMemberChargesHistory(String type) {
    return execute<BaseResponse<List<AgencyMemberChargesHistoryModel>>>(
        () => baseAgencyRemotelyDataSource.agencyMemberChargesHistory(type));
  }

  @override
  ResultFuture<BaseResponse<HostSAgencyDataModel>> hostSAgencyData(
      AgencyHistoryParam params) {
    return execute<BaseResponse<HostSAgencyDataModel>>(
        () => baseAgencyRemotelyDataSource.hostSAgencyData(params));
  }

  @override
  ResultFuture<BaseResponse<List<OldAgencyModel>>> getOldAgenciesIWereIn() {
    return execute<BaseResponse<List<OldAgencyModel>>>(
        () => baseAgencyRemotelyDataSource.getOldAgenciesIWereIn());
  }

  @override
  ResultFuture<BaseResponse<List<HostsAgencyDollarsRecordsModel>>>
      hostsAgencyDollarsRecord(FetchHostsAgencyDollarsParam param) {
    return execute<BaseResponse<List<HostsAgencyDollarsRecordsModel>>>(
        () => baseAgencyRemotelyDataSource.hostsAgencyDollarsRecord(param));
  }

  @override
  ResultFuture<BaseResponse<List<FormModel>>> fetchFormList(
      {required String type}) {
    return execute<BaseResponse<List<FormModel>>>(
        () => baseAgencyRemotelyDataSource.fetchFormList(type: type));
  }
}
