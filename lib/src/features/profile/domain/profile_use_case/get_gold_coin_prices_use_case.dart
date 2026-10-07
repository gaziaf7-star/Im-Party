
import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../data/model/gold_coin_model.dart';
import '../profile_base_repository/profile_base_repository.dart';

class GetGoldCoinPricesUseCase
    extends UseCaseWithoutParams <BaseResponse<List<GoldCoinsModel>>> {
  final ProfileBaseRepository baseRepositoryProfile;

  const GetGoldCoinPricesUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<List<GoldCoinsModel>>> call() {
    return baseRepositoryProfile.getGoldCoinPrices();
  }
}
