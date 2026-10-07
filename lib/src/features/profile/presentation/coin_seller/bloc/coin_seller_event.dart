part of 'coin_seller_bloc.dart';

abstract class CoinSellerEvent extends Equatable {
  const CoinSellerEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the seller's own balance/stats card
/// (`GET /api/v1/coin-seller/profile`).
class GetCoinSellerProfileEvent extends CoinSellerEvent {
  final bool isLoading;
  const GetCoinSellerProfileEvent({this.isLoading = false});
}

/// Sends coins/diamonds from the seller's balance to a user
/// (`POST /api/v1/coin-seller/transfer`). On success the bloc also
/// refreshes the profile balance and (page 1 of) the history list, so the
/// screen reflects the new balance/entry immediately without a manual
/// pull-to-refresh.
class TransferCoinSellerEvent extends CoinSellerEvent {
  final String userId;
  final String amount;
  final String? note;
  final BuildContext context;

  const TransferCoinSellerEvent({
    required this.userId,
    required this.amount,
    required this.context,
    this.note,
  });

  @override
  List<Object?> get props => [userId, amount, note];
}

/// Loads page 1 of the seller's transfer history
/// (`GET /api/v1/coin-seller/history`), using whatever filters are
/// currently held in state (set via [FilterCoinSellerHistoryEvent]).
class GetCoinSellerHistoryEvent extends CoinSellerEvent {
  final bool isLoading;
  const GetCoinSellerHistoryEvent({this.isLoading = false});
}

/// Infinite-scroll pagination for the history list.
class LoadMoreCoinSellerHistoryEvent extends CoinSellerEvent {
  const LoadMoreCoinSellerHistoryEvent();
}

/// Updates the history filters (date range / search text) and re-fetches
/// page 1 with them applied. Passing null for a field clears that filter.
class FilterCoinSellerHistoryEvent extends CoinSellerEvent {
  final String? fromDate;
  final String? toDate;
  final String? searchKey;
  final bool clearFromDate;
  final bool clearToDate;
  final bool clearSearchKey;

  const FilterCoinSellerHistoryEvent({
    this.fromDate,
    this.toDate,
    this.searchKey,
    this.clearFromDate = false,
    this.clearToDate = false,
    this.clearSearchKey = false,
  });

  @override
  List<Object?> get props => [
    fromDate,
    toDate,
    searchKey,
    clearFromDate,
    clearToDate,
    clearSearchKey,
  ];
}