import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/presentation/bloc/goole_pay_bloc/goole_pay_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/goole_pay_bloc/goole_pay_event.dart';

class PurchaseService {
  final InAppPurchase connection = InAppPurchase.instance;

  ProductDetailsResponse? result;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// Purchase tokens currently being sent to the backend (dedupes the same
  /// purchase delivered twice by the stream).
  final Set<String> _inFlight = <String>{};

  /// Subscribe to the Play purchase stream exactly once (getCoins runs on
  /// every screen open and used to add another listener each time).
  void listenToPurchases() {
    if (_purchaseSub != null) return;
    _purchaseSub = connection.purchaseStream.listen(
      handlePurchaseUpdates,
      onError: (error) {
        Methods.printLog("⚠️ Purchase stream error: $error");
      },
    );
  }

  void markDone(String purchaseToken) => _inFlight.remove(purchaseToken);

  /// Tell Play the purchase is consumed, only after the backend credited it.
  Future<void> completeAfterCredit(PurchaseDetails? purchase) async {
    if (purchase == null) return;
    await acknowledgePurchase(purchase);
  }

  Future<void> handlePurchaseUpdates(List<PurchaseDetails> detailsList) async {
    for (PurchaseDetails purchaseDetails in detailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        Methods.safeShowToast(isLoading: true);
      } else {
        // Navigator.pop(navKey.currentState!.context);
      }
      // `restored` = a purchase Play re-delivered because it was never
      // completed (e.g. the backend credit failed last time) -> retry it.
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final token = purchaseDetails.verificationData.serverVerificationData;
        if (!_inFlight.add(token)) continue;
        {
          if (Platform.isAndroid) {
            // completePurchase happens in GooglePayBloc after the backend
            // answers status == 1.
            di<GooglePayBloc>().add(GooglePayEvent(
                purchaseToken: token,
                productId: purchaseDetails.productID,
                purchase: purchaseDetails));
          } else {
            // di<PayBloc>(
            //         getIt<NavigationService>().navigatorKey.currentContext!)
            //     .add(ApplePayNow(
            //         data: purchaseDetails
            //             .verificationData.serverVerificationData
            //             .toString()));
          }
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        Methods.printLog("status error: ${purchaseDetails.error?.message}");
      }
    }
  }

  Future<void> acknowledgePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    } catch (e) {
      Methods.printLog("acknowledge_purchase error $e");
    }
  }

  /// Check if the billing service is available
  Future<bool> checkAvailability() async {
    try {
      final bool available = await connection.isAvailable();
      if (!available) {
        Methods.printLog("⚠️ In-app purchase service not available");
      }
      return available;
    } catch (e) {
      Methods.printLog("⚠️ Error checking billing availability: $e");
      return false;
    }
  }

  /// Get user-friendly error message based on exception
  String _getErrorMessage(dynamic error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'storekit_duplicate_product_object':
        case 'purchase_pending':
          return 'A purchase is already in progress. Please wait.';
        case 'billing_unavailable':
        case 'service_unavailable':
          return 'Google Play billing is not available. Please check that Google Play is enabled and up-to-date on your device.';
        case 'developer_error':
          return 'Configuration error. Please try again later.';
        case 'item_already_owned':
          return 'You already own this item.';
        case 'user_canceled':
          return 'Purchase was cancelled.';
        default:
          return 'Purchase failed: ${error.message ?? error.code}';
      }
    }
    return 'Something went wrong. Please check that Google Play is enabled on your device and try again.';
  }

  Future<void> buyProduct(ProductDetails? product) async {
    if (product == null) {
      Methods.safeShowToast(
        message: 'Product not available',
        isError: true,
      );
      return;
    }

    // Check if billing is available before attempting purchase
    final bool isAvailable = await checkAvailability();
    if (!isAvailable) {
      Methods.safeShowToast(
        message:
            'Google Play is not available on this device. Please check that Google Play is enabled and up-to-date.',
        isError: true,
      );
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      await connection.buyConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      Methods.printLog("Purchase PlatformException: ${e.code} - ${e.message}");
      Methods.safeShowToast(
        message: _getErrorMessage(e),
        isError: true,
      );
    } catch (e) {
      Methods.printLog("Purchase error: $e");
      Methods.safeShowToast(
        message: _getErrorMessage(e),
        isError: true,
      );
    }
  }
}
