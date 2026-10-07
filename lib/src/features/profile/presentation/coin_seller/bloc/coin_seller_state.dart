part of 'coin_seller_bloc.dart';

class CoinSellerState extends Equatable {
  // Profile / balance card
  final CoinSellerProfileModel? profile;
  final RequestState reqStateProfile;
  final String? messageProfile;

  // Transfer
  final RequestState reqStateTransfer;
  final String? messageTransfer;

  // History (paginated)
  final List<CoinSellerHistoryItemModel> history;
  final RequestState reqStateHistory;
  final String? messageHistory;
  final int currentPage;
  final int lastPage;
  final bool isPaginating;

  // Active history filters
  final String? fromDate;
  final String? toDate;
  final String? searchKey;

  const CoinSellerState({
    this.profile,
    this.reqStateProfile = RequestState.idle,
    this.messageProfile,
    this.reqStateTransfer = RequestState.idle,
    this.messageTransfer,
    this.history = const [],
    this.reqStateHistory = RequestState.idle,
    this.messageHistory,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isPaginating = false,
    this.fromDate,
    this.toDate,
    this.searchKey,
  });

  bool get hasMoreHistory => currentPage < lastPage;

  CoinSellerState copyWith({
    CoinSellerProfileModel? profile,
    RequestState? reqStateProfile,
    String? messageProfile,
    RequestState? reqStateTransfer,
    String? messageTransfer,
    List<CoinSellerHistoryItemModel>? history,
    RequestState? reqStateHistory,
    String? messageHistory,
    int? currentPage,
    int? lastPage,
    bool? isPaginating,
    String? fromDate,
    String? toDate,
    String? searchKey,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearSearchKey = false,
  }) {
    return CoinSellerState(
      profile: profile ?? this.profile,
      reqStateProfile: reqStateProfile ?? this.reqStateProfile,
      messageProfile: messageProfile ?? this.messageProfile,
      reqStateTransfer: reqStateTransfer ?? this.reqStateTransfer,
      messageTransfer: messageTransfer ?? this.messageTransfer,
      history: history ?? this.history,
      reqStateHistory: reqStateHistory ?? this.reqStateHistory,
      messageHistory: messageHistory ?? this.messageHistory,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isPaginating: isPaginating ?? this.isPaginating,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      searchKey: clearSearchKey ? null : (searchKey ?? this.searchKey),
    );
  }

  @override
  List<Object?> get props => [
    profile,
    reqStateProfile,
    messageProfile,
    reqStateTransfer,
    messageTransfer,
    history,
    reqStateHistory,
    messageHistory,
    currentPage,
    lastPage,
    isPaginating,
    fromDate,
    toDate,
    searchKey,
  ];
}