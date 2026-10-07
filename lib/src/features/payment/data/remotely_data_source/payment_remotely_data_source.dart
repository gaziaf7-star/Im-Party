import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/data/model/coins_model.dart';
import 'package:general/src/features/payment/presentation/view/in_app_purchases.dart';

abstract class BasePaymentRemotelyDataSource {
  Future<BaseResponse<List<PaymentGatewayModel>>> getCoins(String? type);
  Future<BaseResponse<String>> googlePay(
      {required String purchaseToken, required String productId});

  Future<BaseResponse<String>> buyCoins(
      {required String productId, required String method});

  Future<BaseResponse<String>> redirectPaymentLink(String link);
}

class PaymentRemotelyDataSource extends BasePaymentRemotelyDataSource {
  final DioFactory dioFactory;

  PaymentRemotelyDataSource({required this.dioFactory});

  @override
  Future<BaseResponse<List<PaymentGatewayModel>>> getCoins(String? type) async {
    final response = await dioFactory.get(
      EndPoints.getCoins,
      queryParameters: {if (type != null) 'type': type},
    );

    List<PaymentGatewayModel> data = (response.data['data'] as List<dynamic>)
        .map((element) => PaymentGatewayModel.fromJson(element))
        .toList();

    PaymentGatewayModel? googlePay = data.firstWhere(
      (item) => item.title == "google_pay",
      orElse: () => const PaymentGatewayModel(),
    );

    Set<String> idSet = {};

    if (googlePay.id != null) {
      // Query BOTH id shapes -- the buyCoins response for the same coin
      // package has been observed returning the bare numeric id ("2") in
      // one test and the "coin_N" Play Console SKU format ("coin_1") in
      // another. Querying only the bare id meant queryProductDetails found
      // nothing for a "coin_N"-style SKU, so PurchaseService.result stayed
      // empty and the purchase could never be matched/started -- querying
      // a nonexistent id costs nothing (it just lands in notFoundIDs), so
      // this covers whichever convention Play Console is actually using
      // without needing to know it in advance.
      idSet = googlePay.coins
              ?.expand((coin) => [
                    coin.id.toString(),
                    'coin_${coin.id}',
                    'iamparty_coin_${coin.id}',
                  ])
              .toSet() ??
          {};
    }

    getGoogleAndAppleProducts(idSet)
        .then((value) => di<PurchaseService>().result = value)
        .catchError((error) {
      Methods.printLog(
          "⚠️ Ignored get_google_and_apple_products error: $error");
      return ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [],
      );
    });

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => PaymentGatewayModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> googlePay({
    required String purchaseToken,
    required String productId,
  }) async {
    final response = await dioFactory.post(
      EndPoints.googlePay,
      data: {
        "purchaseToken": purchaseToken,
        "productId": productId,
      },
    );

    // Backend credits the coins and replies `status: 1` on success.
    final body = response.data;
    final bool credited = response.statusCode == 200 &&
        body is Map &&
        (body['status']?.toString() == '1' || body['success'] == true);
    final String msg =
        (body is Map ? body['message'] : null)?.toString() ?? '';
    return BaseResponse(success: credited, message: msg, data: msg);
  }

  Future<ProductDetailsResponse> getGoogleAndAppleProducts(
      Set<String> productsId) async {
    try {
      ProductDetailsResponse response = ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [],
      );

      final bool available =
          await di<PurchaseService>().connection.isAvailable();

      if (!available) {
        Methods.printLog(
            "⚠️ In-app purchase not available - Google Play Services may be disabled, outdated, or unavailable on this device");
        return response;
      }

      Methods.printLog("✅ In-app purchase service is available");
      response = await di<PurchaseService>()
          .connection
          .queryProductDetails(productsId);

      if (response.notFoundIDs.isNotEmpty) {
        Methods.printLog(
            "⚠️ Products not found in store: ${response.notFoundIDs.join(', ')}");
      }
      if (response.error != null) {
        Methods.printLog("⚠️ Product query error: ${response.error?.message}");
      }

      di<PurchaseService>().listenToPurchases();

      return response;
    } on PlatformException catch (e) {
      Methods.printLog(
          "⚠️ PlatformException in getGoogleAndAppleProducts: ${e.code} - ${e.message}");
      return ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [],
      );
    } on DioError catch (e) {
      throw ArgumentError.value(e, 'error', 'get_googel_and_apple_products');
    } catch (e) {
      Methods.printLog("⚠️ Unexpected error in getGoogleAndAppleProducts: $e");
      return ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [],
      );
    }
  }

  @override
  Future<BaseResponse<String>> buyCoins(
      {required String productId, required String method}) async {
    final response = await dioFactory.post(
      EndPoints.buyCoins,
      data: {
        // "pay_method": method,
        "coin_id": productId,
      },
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => json ?? "",
    );
  }

  @override
  Future<BaseResponse<String>> redirectPaymentLink(String link) async {
    final response = await dioFactory.get(
      link,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => json ?? "",
    );
  }
}
