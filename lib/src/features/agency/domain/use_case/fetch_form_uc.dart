import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/form_model.dart';

import '../../../../core/index.dart';

class FetchFormUc
    extends UseCaseWithParams<BaseResponse<List<FormModel>>, String> {
  final AgencyBaseRepository repository;

  const FetchFormUc({required this.repository});

  @override
  ResultFuture<BaseResponse<List<FormModel>>> call(params) {
    return repository.fetchFormList(type: params);
  }
}
