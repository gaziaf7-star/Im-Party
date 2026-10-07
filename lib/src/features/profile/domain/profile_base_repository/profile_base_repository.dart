import 'package:general/src/features/auth/data/model/level_model.dart';
import 'package:general/src/features/auth/data/model/user_levels_model.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/profile/data/model/coin_seller_model.dart';
import 'package:general/src/features/profile/data/model/get_badges_model.dart';
import 'package:general/src/features/profile/data/model/top_support.dart';
import 'package:general/src/features/profile/data/model/user_badges_model.dart';
import 'package:general/src/features/profile/data/model/user_intro_model.dart';
import 'package:general/src/features/profile/data/model/user_room_model.dart';
import 'package:general/src/features/profile/profile.dart';
import '../../../../core/index.dart';
import '../../data/model/gold_coin_model.dart';
import '../../data/model/levels_badges_model.dart';
import '../../data/model/levels_model.dart';
import '../../data/model/exchange_settings_model.dart';
import '../../data/model/exchange_log_model.dart';
import '../../data/model/wallet_withdraw_models.dart';

abstract class ProfileBaseRepository {
  ResultFuture<BaseResponse<MyDataModel>> getMyData();
  ResultFuture<BaseResponse<LevelModel>> getMyLevelsData();
  ResultFuture<BaseResponse<List<UserModel>>> getFriendsOrFollowers(
      FFFParameter fffParameter,
      );
  ResultFuture<BaseResponse<String>> makeFollow({String userId});
  ResultFuture<BaseResponse<String>> makeUnFollow({String userId});
  ResultFuture<BaseResponse<List<AllLevels>>> fetchLevels(int type);
  ResultFuture<MyStoreModel> myStore();
  ResultFuture<BaseResponse<List<GoldCoinsModel>>> getGoldCoinPrices();
  ResultFuture<BaseResponse<List<UserModel>>> getVisitors({FFFParameter? page});
  // ResultFuture<BaseResponse<List<ImageData>>>  getUserBadge(String id);
  ResultFuture<String> addBloc({required String userId});
  ResultFuture<String> removeBloc({required String userId});
  ResultFuture<BaseResponse<List<GiftHistoryModel>>> getGiftHistory(
      {required String userId});
  ResultFuture<BaseResponse<List<UserIntroModel>>> getUserIntro(
      {required String userId});
  ResultFuture<BaseResponse<UserModel>> getUserData({
    GetUserDataParameter params,
  });
  ResultFuture<String> userReport({required UserReportParameter userReport});
  ResultFuture<BaseResponse<List<ImageData>>> getUserBadge(String id);
  ResultFuture<BaseResponse<TopSupportModel>> getUserSupporter(String id);
  ResultFuture<BaseResponse<List<BillModel>>> fetchBill(
      {required BillParam param});
  ResultFuture<ReplaceWithGoldModel> getReplaceWithDiamondData();
  ResultFuture<String> exchangeDiamond({required String itemId});

  // New v2 diamond <-> coin exchange system (per request: discard the old
  // fixed-tier flow above for the Wallet Diamond tab's new Exchange button,
  // use these dynamic v2 endpoints instead).
  ResultFuture<ExchangeSettingsModel> getExchangeSettings();
  ResultFuture<String> makeExchangeV2(MakeDiamondExchangeParams params);
  ResultFuture<ExchangeLogModel> getExchangeLogs({int type = 0});

  // New professional withdraw system (Profile > Withdraw).
  ResultFuture<String> makeWalletWithdraw(MakeWalletWithdrawParams params);
  ResultFuture<WithdrawSystemStatus> getWithdrawSystemStatus();
  ResultFuture<List<WithdrawMethod>> getWithdrawMethods();
  ResultFuture<List<UserPaymentMethod>> getPaymentMethods();
  ResultFuture<String> addPaymentMethod(AddPaymentMethodParams params);
  ResultFuture<String> editPaymentMethod(EditPaymentMethodParams params);
  ResultFuture<String> deletePaymentMethod(String id);
  ResultFuture<WithdrawCreateResponse> createWithdrawRequest(CreateWithdrawRequestParams params);
  ResultFuture<List<WithdrawReseller>> getWithdrawResellers();
  ResultFuture<WithdrawPage<WithdrawHistoryItem>> getWithdrawHistory({
    String? status,
    String? receivedType,
    int page = 1,
    int perPage = 20,
  });
  ResultFuture<List<WithdrawHistoryItem>> getIncomingWithdrawRequests();
  ResultFuture<String> acceptIncomingWithdraw(String id);
  ResultFuture<String> rejectIncomingWithdraw(String id);
  ResultFuture<BaseResponse<List<GetBadgesModel>>> fetchBadges({
    required String type,
  });

  ResultFuture<String> pickMyBadges(List<int> ids);
  ResultFuture<BaseResponse<List<ImageData>>> getMyAllBadge({String id});
  ResultFuture<BaseResponse<BadgesModel>> levelsBadges(int type);
  ResultFuture<BaseResponse<RoomLevelBadgesModel>> roomLevelBadges();
  ResultFuture<BaseResponse<UserLevelsModel>> userLevels();
  ResultFuture<BaseResponse<UserRoomsModel>> userRooms(int userId);
  ResultFuture<BaseResponse<UserBadgesModel>> getUserBadges(int userId);
  ResultFuture<BaseResponse<int>> changeCountry(String countryId);

  // Coin Seller (Reseller) system
  ResultFuture<BaseResponse<List<CoinSellerModel>>> getCoinSellerList({
    String? search,
    int page,
    int perPage,
  });
  ResultFuture<BaseResponse<CoinSellerProfileModel>> getCoinSellerProfile();
  ResultFuture<String> transferCoinSeller({
    required String userId,
    required String amount,
    String? note,
  });
  ResultFuture<BaseResponse<List<CoinSellerHistoryItemModel>>>
  getCoinSellerHistory({
    int page,
    String? fromDate,
    String? toDate,
    String? searchKey,
  });
}
