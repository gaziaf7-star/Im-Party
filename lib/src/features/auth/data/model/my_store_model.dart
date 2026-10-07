import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class MyStoreModel extends MyStoreEntity {
  // Constructor
  const MyStoreModel({
    super.earnedCoins,
    super.id,
    super.coupons,
    super.coins,
    super.coinsNew,
    super.diamonds,
    super.agentUsd,
    super.userUsd,
    super.walletBalance,
    super.silverCoin,
    super.pendingDollar,
    super.roomSalary,
    super.withdrawaledUsd,
  });

  factory MyStoreModel.fromJson(Map<String, dynamic> data) {
    return MyStoreModel(
      earnedCoins: data['earned_coins'] is num
          ? data['earned_coins'] as num
          : num.tryParse(data['earned_coins']?.toString() ?? '') ?? 0,
      id: parseValue<int>(data['id'], 0),
      coupons: parseValue<String>(data['coupons'], '0'),
      coins: parseValue<int>(data['coins'], 0),
      coinsNew: parseValue<String>(data['coins_new'], '0'),
      diamonds: parseValue<int>(data['diamonds'], 0),
      agentUsd: parseValue<double>(data['host_usd'], 0.0),
      userUsd: parseValue<double>(data['user_usd'], 0.0),
      walletBalance: parseValue<double>(data['wallet_user_balance'], 0.0),
      silverCoin: parseValue<String>(data['silver_coins'], '0'),
      pendingDollar: parseValue<String>(data['pending_dollar'], '0'),
      roomSalary: parseValue<String>(data['room_salary'], '0'),
      withdrawaledUsd: parseValue<String>(data['paid'], '0'),
    );
  }

  @override
  List<Object?> get props => [
      id,
      earnedCoins,
        coupons,
        coins,
        coinsNew,
        diamonds,
        agentUsd,
        userUsd,
        walletBalance,
        silverCoin,
        pendingDollar,
        roomSalary,
      ];
}
