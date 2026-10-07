import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/domain/base_repo/payment_base_repo.dart';

class GooglePayUseCase extends UseCaseWithParams<BaseResponse<String>, GooglePayParam> {
  final PaymentBaseRepository paymentBaseRepository;

  GooglePayUseCase({required this.paymentBaseRepository});

  @override
  ResultFuture <BaseResponse<String>> call(GooglePayParam params) async{
    final result = paymentBaseRepository.googlePay(purchaseToken: params.purchaseToken, productId: params.productId);
    return result;
  }
}

class GooglePayParam extends Equatable {
  final String purchaseToken, productId;

  const GooglePayParam({
    this.purchaseToken = '',
    this.productId = '',
  });

  @override
  List<Object?> get props => [purchaseToken, productId];
}