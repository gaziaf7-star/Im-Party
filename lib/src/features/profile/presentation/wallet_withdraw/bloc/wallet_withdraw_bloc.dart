import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/profile/data/model/wallet_withdraw_models.dart';
import 'package:general/src/features/profile/domain/profile_use_case/wallet_withdraw_use_cases.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

part 'wallet_withdraw_event.dart';
part 'wallet_withdraw_state.dart';

class WalletWithdrawBloc extends Bloc<WalletWithdrawEvent, WalletWithdrawState> {
  WalletWithdrawBloc({required this.useCases}) : super(WalletWithdrawState(earnedCoins: MyDataModel.getInstance().myStore?.earnedCoins ?? 0)) {
    on<LoadWalletWithdrawEvent>(_load);
    on<RefreshPaymentMethodsEvent>(_payments);
    on<LoadResellersEvent>(_resellers);
    on<LoadHistoryEvent>(_history);
    on<SavePaymentMethodEvent>(_savePayment);
    on<DeletePaymentMethodEvent>(_deletePayment);
    on<SubmitWalletWithdrawEvent>(_submit);
    on<LoadIncomingWithdrawEvent>(_incoming);
    on<ProcessIncomingWithdrawEvent>(_process);
    on<ClearWalletWithdrawMessageEvent>((event, emit) => emit(state.copyWith(clearMessage: true)));
  }
  final WalletWithdrawUseCases useCases;

  String _error(dynamic error) => NetworkExceptions.getErrorMessage(error);

  Future<void> _load(LoadWalletWithdrawEvent event, Emitter<WalletWithdrawState> emit) async {
    emit(state.copyWith(initialState: RequestState.loading));
    final statusFuture = useCases.status();
    final methodsFuture = useCases.methods();
    final paymentsFuture = useCases.paymentMethods();
    final historyFuture = useCases.history();
    final statusResult = await statusFuture;
    final methodsResult = await methodsFuture;
    final paymentsResult = await paymentsFuture;
    final historyResult = await historyFuture;
    var next = state;
    var failed = false;
    statusResult.fold((e) { failed = true; next = next.copyWith(message: _error(e), isError: true); }, (v) => next = next.copyWith(systemOn: v.isOn));
    methodsResult.fold((e) { failed = true; next = next.copyWith(message: _error(e), isError: true); }, (v) => next = next.copyWith(methods: v));
    paymentsResult.fold((e) { failed = true; next = next.copyWith(message: _error(e), isError: true); }, (v) => next = next.copyWith(paymentMethods: v));
    historyResult.fold((e) { failed = true; next = next.copyWith(message: _error(e), isError: true); }, (page) { next = next.copyWith(history: page.items, historyPage: page.currentPage, historyLastPage: page.lastPage); });
    emit(next.copyWith(initialState: failed ? RequestState.error : RequestState.loaded));
    // Was StringManager.isCoinSeller alone -- that flag comes from a
    // `coin_seller` field the /my-data response doesn't actually send for
    // this backend, so it was always false and this never fired. The
    // reliable signal (also what the Coin Seller menu tile itself checks,
    // third_card_body.dart) is `user_types` containing 7.
    if (StringManager.isCoinSeller || StringManager.userType[7] == true) {
      add(const LoadIncomingWithdrawEvent());
    }
  }

  Future<void> _payments(RefreshPaymentMethodsEvent event, Emitter<WalletWithdrawState> emit) async {
    emit(state.copyWith(paymentState: RequestState.loading));
    final result = await useCases.paymentMethods();
    result.fold((e) => emit(state.copyWith(paymentState: RequestState.error, message: _error(e), isError: true)), (v) => emit(state.copyWith(paymentState: RequestState.loaded, paymentMethods: v)));
  }

  Future<void> _savePayment(SavePaymentMethodEvent event, Emitter<WalletWithdrawState> emit) async {
    if (state.paymentState.isLoading) return;
    emit(state.copyWith(paymentState: RequestState.loading, clearMessage: true));
    final result = event.id == null
        ? await useCases.addPayment(AddPaymentMethodParams(methodName: event.methodName, methodAccount: event.methodAccount))
        : await useCases.editPayment(EditPaymentMethodParams(id: event.id.toString(), methodName: event.methodName, methodAccount: event.methodAccount));
    result.fold((e) => emit(state.copyWith(paymentState: RequestState.error, message: _error(e), isError: true)), (v) { emit(state.copyWith(paymentState: RequestState.loaded, message: v, isError: false)); add(const RefreshPaymentMethodsEvent()); });
  }

  Future<void> _deletePayment(DeletePaymentMethodEvent event, Emitter<WalletWithdrawState> emit) async {
    if (state.paymentState.isLoading) return;
    emit(state.copyWith(paymentState: RequestState.loading, clearMessage: true));
    final result = await useCases.deletePayment(event.id.toString());
    result.fold((e) => emit(state.copyWith(paymentState: RequestState.error, message: _error(e), isError: true)), (v) { emit(state.copyWith(paymentState: RequestState.loaded, message: v, isError: false)); add(const RefreshPaymentMethodsEvent()); });
  }

  Future<void> _resellers(LoadResellersEvent event, Emitter<WalletWithdrawState> emit) async {
    if (state.resellerState.isLoading || state.resellers.isNotEmpty) return;
    emit(state.copyWith(resellerState: RequestState.loading));
    final result = await useCases.resellers();
    result.fold((e) => emit(state.copyWith(resellerState: RequestState.error, message: _error(e), isError: true)), (v) => emit(state.copyWith(resellerState: RequestState.loaded, resellers: v)));
  }

  Future<void> _history(LoadHistoryEvent event, Emitter<WalletWithdrawState> emit) async {
    if (state.historyState.isLoading) return;
    final pageNumber = event.loadMore ? state.historyPage + 1 : 1;
    if (event.loadMore && state.historyPage >= state.historyLastPage) return;
    emit(state.copyWith(historyState: RequestState.loading));
    final result = await useCases.history(status: event.status, receivedType: event.receivedType, page: pageNumber);
    result.fold((e) => emit(state.copyWith(historyState: RequestState.error, message: _error(e), isError: true)), (page) => emit(state.copyWith(historyState: RequestState.loaded, history: event.loadMore ? [...state.history, ...page.items] : page.items, historyPage: page.currentPage, historyLastPage: page.lastPage, historyStatus: event.status, historyReceivedType: event.receivedType, clearHistoryStatus: event.status == null, clearHistoryReceivedType: event.receivedType == null)));
  }

  Future<void> _submit(SubmitWalletWithdrawEvent event, Emitter<WalletWithdrawState> emit) async {
    if (state.submitState.isLoading) return;
    emit(state.copyWith(submitState: RequestState.loading, clearMessage: true));
    final result = await useCases.create(CreateWithdrawRequestParams(methodId: event.methodId.toString(), amount: event.amount, receivedType: event.receivedType, resellerId: event.resellerId?.toString()));
    result.fold((e) => emit(state.copyWith(submitState: RequestState.error, message: _error(e), isError: true)), (v) { emit(state.copyWith(submitState: RequestState.loaded, earnedCoins: v.earnedCoins ?? state.earnedCoins, message: v.message, isError: false)); add(LoadHistoryEvent(status: state.historyStatus, receivedType: state.historyReceivedType)); if (di.isRegistered<MyStoreBloc>()) di<MyStoreBloc>().add(const GetMyStoreEvent()); });
  }

  Future<void> _incoming(LoadIncomingWithdrawEvent event, Emitter<WalletWithdrawState> emit) async {
    if (!(StringManager.isCoinSeller || StringManager.userType[7] == true)) return;
    emit(state.copyWith(incomingState: RequestState.loading));
    final result = await useCases.incoming();
    result.fold((e) => emit(state.copyWith(incomingState: RequestState.error, message: _error(e), isError: true)), (v) => emit(state.copyWith(incomingState: RequestState.loaded, incoming: v)));
  }

  Future<void> _process(ProcessIncomingWithdrawEvent event, Emitter<WalletWithdrawState> emit) async {
    if (state.processState.isLoading) return;
    emit(state.copyWith(processState: RequestState.loading, processingRequestId: event.requestId));
    final result = event.accept ? await useCases.accept(event.requestId.toString()) : await useCases.reject(event.requestId.toString());
    result.fold((e) => emit(state.copyWith(processState: RequestState.error, message: _error(e), isError: true, clearProcessingId: true)), (v) { emit(state.copyWith(processState: RequestState.loaded, message: v, isError: false, clearProcessingId: true)); add(const LoadIncomingWithdrawEvent()); });
  }
}
