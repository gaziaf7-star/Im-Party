import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class GetPaymentGetwaysUC
    extends UseCaseWithoutParams<BaseResponse<List<PaymentsGetwaysModel>>> {
  final AgencyBaseRepository repository;

  const GetPaymentGetwaysUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<PaymentsGetwaysModel>>> call() {
    return repository.fetchPaymentsGetWaysData();
  }
}
