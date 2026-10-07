import 'package:general/src/core/base/base_use_case.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/parameters.dart';
import '../base_repo/settings_base_repository.dart';


class MakeProblemReportUseCase extends UseCaseWithParams<BaseResponse<String>,MakeProblemReportParam> {
  final SettingsBaseRepository baseRepository;

  const MakeProblemReportUseCase({required this.baseRepository});





  @override
  ResultFuture <BaseResponse<String>>call(params) {
return baseRepository.makeProblemReport(params);
  }
}
