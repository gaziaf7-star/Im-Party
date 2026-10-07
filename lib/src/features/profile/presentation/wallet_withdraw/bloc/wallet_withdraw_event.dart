part of 'wallet_withdraw_bloc.dart';

sealed class WalletWithdrawEvent extends Equatable {
  const WalletWithdrawEvent();
  @override
  List<Object?> get props => [];
}

class LoadWalletWithdrawEvent extends WalletWithdrawEvent { const LoadWalletWithdrawEvent(); }
class RefreshPaymentMethodsEvent extends WalletWithdrawEvent { const RefreshPaymentMethodsEvent(); }
class LoadResellersEvent extends WalletWithdrawEvent { const LoadResellersEvent(); }
class LoadHistoryEvent extends WalletWithdrawEvent {
  const LoadHistoryEvent({this.status, this.receivedType, this.loadMore = false});
  final String? status;
  final String? receivedType;
  final bool loadMore;
  @override List<Object?> get props => [status, receivedType, loadMore];
}
class SavePaymentMethodEvent extends WalletWithdrawEvent {
  const SavePaymentMethodEvent({this.id, required this.methodName, required this.methodAccount});
  final int? id;
  final String methodName;
  final String methodAccount;
  @override List<Object?> get props => [id, methodName, methodAccount];
}
class DeletePaymentMethodEvent extends WalletWithdrawEvent {
  const DeletePaymentMethodEvent(this.id);
  final int id;
  @override List<Object?> get props => [id];
}
class SubmitWalletWithdrawEvent extends WalletWithdrawEvent {
  const SubmitWalletWithdrawEvent({required this.methodId, required this.amount, required this.receivedType, this.resellerId});
  final int methodId;
  final num amount;
  final String receivedType;
  final int? resellerId;
  @override List<Object?> get props => [methodId, amount, receivedType, resellerId];
}
class LoadIncomingWithdrawEvent extends WalletWithdrawEvent { const LoadIncomingWithdrawEvent(); }
class ProcessIncomingWithdrawEvent extends WalletWithdrawEvent {
  const ProcessIncomingWithdrawEvent({required this.requestId, required this.accept});
  final int requestId;
  final bool accept;
  @override List<Object?> get props => [requestId, accept];
}
class ClearWalletWithdrawMessageEvent extends WalletWithdrawEvent { const ClearWalletWithdrawMessageEvent(); }
