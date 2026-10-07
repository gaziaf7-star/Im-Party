import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class GetGoogleCoinsHistoryUC
    extends UseCaseWithoutParams<BaseResponse<List<UserGoogleCoinsHistoryModel>>> {
  final AgencyBaseRepository repository;

  GetGoogleCoinsHistoryUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<UserGoogleCoinsHistoryModel>>> call() {
    return repository.fetchGoogleCoinsHistory();
  }
}
