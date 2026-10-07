import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/wallet_withdraw_models.dart';
import 'package:general/src/features/profile/profile.dart';

class WalletWithdrawUseCases {
  const WalletWithdrawUseCases(this.repository);
  final ProfileBaseRepository repository;

  ResultFuture<WithdrawSystemStatus> status() => repository.getWithdrawSystemStatus();
  ResultFuture<List<WithdrawMethod>> methods() => repository.getWithdrawMethods();
  ResultFuture<List<UserPaymentMethod>> paymentMethods() => repository.getPaymentMethods();
  ResultFuture<String> addPayment(AddPaymentMethodParams params) => repository.addPaymentMethod(params);
  ResultFuture<String> editPayment(EditPaymentMethodParams params) => repository.editPaymentMethod(params);
  ResultFuture<String> deletePayment(String id) => repository.deletePaymentMethod(id);
  ResultFuture<WithdrawCreateResponse> create(CreateWithdrawRequestParams params) => repository.createWithdrawRequest(params);
  ResultFuture<List<WithdrawReseller>> resellers() => repository.getWithdrawResellers();
  ResultFuture<WithdrawPage<WithdrawHistoryItem>> history({String? status, String? receivedType, int page = 1}) => repository.getWithdrawHistory(status: status, receivedType: receivedType, page: page, perPage: 20);
  ResultFuture<List<WithdrawHistoryItem>> incoming() => repository.getIncomingWithdrawRequests();
  ResultFuture<String> accept(String id) => repository.acceptIncomingWithdraw(id);
  ResultFuture<String> reject(String id) => repository.rejectIncomingWithdraw(id);
}
