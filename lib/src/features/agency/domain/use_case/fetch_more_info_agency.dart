import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/agency_more_info_model.dart';

import '../../../../core/index.dart';

class FetchMoreInfoAgencyUC extends UseCaseWithParams<
    BaseResponse<OverallStatsModel>, AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const FetchMoreInfoAgencyUC({required this.repository});

  @override
  ResultFuture<BaseResponse<OverallStatsModel>> call(params) {
    return repository.fetchMoreInfoAgency(params);
  }
}
class HostSAgencyDataUC extends UseCaseWithParams<
    BaseResponse<HostSAgencyDataModel>, AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const HostSAgencyDataUC({required this.repository});

  @override
  ResultFuture<BaseResponse<HostSAgencyDataModel>> call(params) {
    return repository.hostSAgencyData(params);
  }
}

class FetchAgencyStarsUC extends UseCaseWithParams<
    BaseResponse<List<UserStarModel>>, AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const FetchAgencyStarsUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<UserStarModel>>> call(params) {
    return repository.fetchAgencyStars(params);
  }
}

class FetchAgencyHerosUC extends UseCaseWithParams<
    BaseResponse<List<UserStarModel>>, AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const FetchAgencyHerosUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<UserStarModel>>> call(params) {
    return repository.fetchAgencyHeros(params);
  }
}
class FetchAgencyAdminsUC extends UseCaseWithParams<
    BaseResponse<List<UserStarModel>>, AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const FetchAgencyAdminsUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<UserStarModel>>> call(params) {
    return repository.fetchAgencyAdmins(params);
  }
}
