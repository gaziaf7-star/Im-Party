import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/domain/base_repo/payment_base_repo.dart';

class BuyCoinsUseCase extends UseCaseWithParams<BaseResponse<String>, BuyCoinsParam> {
  final PaymentBaseRepository paymentBaseRepository;

  BuyCoinsUseCase({required this.paymentBaseRepository});

  @override
  ResultFuture <BaseResponse<String>> call(BuyCoinsParam params) async{
    final result = paymentBaseRepository.buyCoins(method: params.method, productId: params.productId);
    return result;
  }
}

class BuyCoinsParam extends Equatable {
  final String method, productId;

  const BuyCoinsParam({
    this.method = '',
    this.productId = '',
  });

  @override
  List<Object?> get props => [method, productId];
}