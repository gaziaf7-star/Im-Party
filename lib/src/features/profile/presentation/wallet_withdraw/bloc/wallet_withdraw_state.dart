part of 'wallet_withdraw_bloc.dart';

class WalletWithdrawState extends Equatable {
  const WalletWithdrawState({
    this.initialState = RequestState.idle,
    this.paymentState = RequestState.idle,
    this.submitState = RequestState.idle,
    this.historyState = RequestState.idle,
    this.resellerState = RequestState.idle,
    this.incomingState = RequestState.idle,
    this.processState = RequestState.idle,
    this.systemOn = true,
    this.earnedCoins = 0,
    this.methods = const [],
    this.paymentMethods = const [],
    this.resellers = const [],
    this.history = const [],
    this.incoming = const [],
    this.historyPage = 1,
    this.historyLastPage = 1,
    this.historyStatus,
    this.historyReceivedType,
    this.processingRequestId,
    this.message,
    this.isError = false,
  });
  final RequestState initialState, paymentState, submitState, historyState, resellerState, incomingState, processState;
  final bool systemOn, isError;
  final num earnedCoins;
  final List<WithdrawMethod> methods;
  final List<UserPaymentMethod> paymentMethods;
  final List<WithdrawReseller> resellers;
  final List<WithdrawHistoryItem> history, incoming;
  final int historyPage, historyLastPage;
  final String? historyStatus, historyReceivedType, message;
  final int? processingRequestId;

  WalletWithdrawState copyWith({
    RequestState? initialState, RequestState? paymentState, RequestState? submitState,
    RequestState? historyState, RequestState? resellerState, RequestState? incomingState,
    RequestState? processState, bool? systemOn, bool? isError, num? earnedCoins,
    List<WithdrawMethod>? methods, List<UserPaymentMethod>? paymentMethods,
    List<WithdrawReseller>? resellers, List<WithdrawHistoryItem>? history,
    List<WithdrawHistoryItem>? incoming, int? historyPage, int? historyLastPage,
    String? historyStatus, String? historyReceivedType, int? processingRequestId,
    String? message, bool clearMessage = false, bool clearProcessingId = false,
    bool clearHistoryStatus = false, bool clearHistoryReceivedType = false,
  }) => WalletWithdrawState(
    initialState: initialState ?? this.initialState,
    paymentState: paymentState ?? this.paymentState,
    submitState: submitState ?? this.submitState,
    historyState: historyState ?? this.historyState,
    resellerState: resellerState ?? this.resellerState,
    incomingState: incomingState ?? this.incomingState,
    processState: processState ?? this.processState,
    systemOn: systemOn ?? this.systemOn,
    isError: isError ?? this.isError,
    earnedCoins: earnedCoins ?? this.earnedCoins,
    methods: methods ?? this.methods,
    paymentMethods: paymentMethods ?? this.paymentMethods,
    resellers: resellers ?? this.resellers,
    history: history ?? this.history,
    incoming: incoming ?? this.incoming,
    historyPage: historyPage ?? this.historyPage,
    historyLastPage: historyLastPage ?? this.historyLastPage,
    historyStatus: clearHistoryStatus ? null : historyStatus ?? this.historyStatus,
    historyReceivedType: clearHistoryReceivedType ? null : historyReceivedType ?? this.historyReceivedType,
    processingRequestId: clearProcessingId ? null : processingRequestId ?? this.processingRequestId,
    message: clearMessage ? null : message ?? this.message,
  );

  @override List<Object?> get props => [initialState, paymentState, submitState, historyState, resellerState, incomingState, processState, systemOn, earnedCoins, methods, paymentMethods, resellers, history, incoming, historyPage, historyLastPage, historyStatus, historyReceivedType, processingRequestId, message, isError];
}
