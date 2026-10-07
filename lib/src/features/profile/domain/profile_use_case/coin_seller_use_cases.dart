import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/coin_seller_model.dart';
import 'package:general/src/features/profile/profile.dart';

/// Params for [GetCoinSellerListUC] -- the public seller directory
/// (`GET /api/v1/coin-seller/list`).
class GetCoinSellerListParams {
  final String? search;
  final int page;
  final int perPage;

  const GetCoinSellerListParams({
    this.search,
    this.page = 1,
    this.perPage = 20,
  });
}

class GetCoinSellerListUC
    extends UseCaseWithParams<BaseResponse<List<CoinSellerModel>>, GetCoinSellerListParams> {
  final ProfileBaseRepository _repo;
  GetCoinSellerListUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<CoinSellerModel>>> call(
      GetCoinSellerListParams params) {
    return _repo.getCoinSellerList(
      search: params.search,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetCoinSellerProfileUC
    extends UseCaseWithoutParams<BaseResponse<CoinSellerProfileModel>> {
  final ProfileBaseRepository _repo;
  GetCoinSellerProfileUC(this._repo);

  @override
  ResultFuture<BaseResponse<CoinSellerProfileModel>> call() {
    return _repo.getCoinSellerProfile();
  }
}

/// Params for [TransferCoinSellerUC] -- mirrors the exact payload of
/// `POST /api/v1/coin-seller/transfer`: `{"user_id", "amount", "note"}`.
class TransferCoinSellerParams {
  final String userId;
  final String amount;
  final String? note;

  const TransferCoinSellerParams({
    required this.userId,
    required this.amount,
    this.note,
  });
}

class TransferCoinSellerUC
    extends UseCaseWithParams<String, TransferCoinSellerParams> {
  final ProfileBaseRepository _repo;
  TransferCoinSellerUC(this._repo);

  @override
  ResultFuture<String> call(TransferCoinSellerParams params) {
    return _repo.transferCoinSeller(
      userId: params.userId,
      amount: params.amount,
      note: params.note,
    );
  }
}

/// Params for [GetCoinSellerHistoryUC] -- pagination + the `from_date` /
/// `to_date` / `search_key` filters `GET /api/v1/coin-seller/history` takes.
class GetCoinSellerHistoryParams {
  final int page;
  final String? fromDate;
  final String? toDate;
  final String? searchKey;

  const GetCoinSellerHistoryParams({
    this.page = 1,
    this.fromDate,
    this.toDate,
    this.searchKey,
  });
}

class GetCoinSellerHistoryUC extends UseCaseWithParams<
    BaseResponse<List<CoinSellerHistoryItemModel>>, GetCoinSellerHistoryParams> {
  final ProfileBaseRepository _repo;
  GetCoinSellerHistoryUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<CoinSellerHistoryItemModel>>> call(
      GetCoinSellerHistoryParams params) {
    return _repo.getCoinSellerHistory(
      page: params.page,
      fromDate: params.fromDate,
      toDate: params.toDate,
      searchKey: params.searchKey,
    );
  }
}