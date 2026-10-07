import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/domain/base_repo/payment_base_repo.dart';

class RedirectLinkUseCase extends UseCaseWithParams<BaseResponse<String>, String> {
  final PaymentBaseRepository paymentBaseRepository;

  RedirectLinkUseCase({required this.paymentBaseRepository});

  @override
  ResultFuture <BaseResponse<String>> call(String params) async{
    final result = paymentBaseRepository.redirectPaymentLink(params);
    return result;
  }
}

