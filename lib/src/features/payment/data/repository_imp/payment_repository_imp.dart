import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/data/model/coins_model.dart';
import 'package:general/src/features/payment/data/remotely_data_source/payment_remotely_data_source.dart';
import 'package:general/src/features/payment/domain/base_repo/payment_base_repo.dart';

class PaymentRepositoryImp extends PaymentBaseRepository {
  final BasePaymentRemotelyDataSource basePaymentRemotelyDataSource;

  PaymentRepositoryImp({required this.basePaymentRemotelyDataSource});

  @override
  ResultFuture<BaseResponse<List<PaymentGatewayModel>>> getCoins(String? type) async {
    return execute<BaseResponse<List<PaymentGatewayModel>>>(
      () => basePaymentRemotelyDataSource.getCoins(type),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> googlePay(
      {required String purchaseToken, required String productId}) async {
    return execute<BaseResponse<String>>(
      () => basePaymentRemotelyDataSource.googlePay(
          purchaseToken: purchaseToken, productId: productId),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> buyCoins(
      {required String productId, required String method}) async {
    return execute<BaseResponse<String>>(
      () => basePaymentRemotelyDataSource.buyCoins(
          productId: productId, method: method),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> redirectPaymentLink(
      String link) async {
    return execute<BaseResponse<String>>(
      () => basePaymentRemotelyDataSource.redirectPaymentLink(
          link),
    );
  }
}
