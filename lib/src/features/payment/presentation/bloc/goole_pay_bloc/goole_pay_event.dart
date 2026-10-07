import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class BaseGooglePayEvent extends Equatable {
  const BaseGooglePayEvent();

  @override
  List<Object> get props => [];
}

class GooglePayEvent extends BaseGooglePayEvent {
  final String purchaseToken, productId;

  /// The Play purchase to complete once the backend has credited the coins.
  final PurchaseDetails? purchase;

  const GooglePayEvent({
    required this.purchaseToken,
    required this.productId,
    this.purchase,
  });
}
