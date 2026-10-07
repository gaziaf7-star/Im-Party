import 'package:general/src/core/index.dart';

abstract class BaseBuyCoinsEvent extends Equatable {
  const BaseBuyCoinsEvent();

  @override
  List<Object?> get props => [];
}

class BuyCoinsEvent extends BaseBuyCoinsEvent {
  final BuildContext context;
  final String method, productId;

  const BuyCoinsEvent({
    required this.method,
    required this.productId,
    required this.context,
  });
}

class ChangeValueEvent extends BaseBuyCoinsEvent {
  final int? value;
  final int? controllerIndex;
  final bool? changeText;
  const ChangeValueEvent({this.value, this.changeText, this.controllerIndex});

  @override
  List<Object?> get props => [value, controllerIndex];
}

class RedirectLinkEvent extends BaseBuyCoinsEvent {
  final String? link;
  const RedirectLinkEvent({
    this.link,
  });

  @override
  List<Object?> get props => [link];
}
