import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/data/model/coins_model.dart';

abstract class PaymentBaseRepository {
  ResultFuture<BaseResponse<List<PaymentGatewayModel>>> getCoins(String? type);

  ResultFuture<BaseResponse<String>> googlePay(
      {required String purchaseToken, required String productId});

  ResultFuture<BaseResponse<String>> buyCoins(
      {required String method, required String productId});

  ResultFuture<BaseResponse<String>> redirectPaymentLink(
      String link);
}
