import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class GetSettingUC
    extends UseCaseWithoutParams<BaseResponse<SettingModel>> {
  final AgencyBaseRepository repository;

  const GetSettingUC({required this.repository});

  @override
  ResultFuture<BaseResponse<SettingModel>> call() {
    return repository.fetchSettings();
  }
}


