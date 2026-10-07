
import 'package:general/src/features/payment/data/model/coins_model.dart';
import 'package:general/src/features/payment/domain/base_repo/payment_base_repo.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';

class GetCoinsUseCase extends UseCaseWithParams<BaseResponse<List<PaymentGatewayModel>>,String?> {
  final PaymentBaseRepository paymentBaseRepository;

  GetCoinsUseCase({required this.paymentBaseRepository});

  @override
  ResultFuture <BaseResponse<List<PaymentGatewayModel>>> call(params) async{
    final result = paymentBaseRepository.getCoins(params);
    return result;
  }
}
