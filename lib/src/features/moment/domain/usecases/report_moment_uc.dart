import 'package:general/src/features/moment/domain/repository/base_moment_repository.dart';

import '../../../../core/index.dart';

class ReportMomentUC extends UseCaseWithParams<BaseResponse<String>, ReportMomentParam> {
  BaseMomentRepository baseRepositoryMoment;
  ReportMomentUC({required this.baseRepositoryMoment});

  @override
  ResultFuture<BaseResponse<String>> call(ReportMomentParam params,) async {
    final result = await baseRepositoryMoment.reportMoment(params);
    return result;
  }
}
