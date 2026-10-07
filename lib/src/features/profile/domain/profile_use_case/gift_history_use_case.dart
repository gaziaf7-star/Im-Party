import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/gift_history_model.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';


class GiftHistoryUseCase extends UseCaseWithParams<BaseResponse<List<GiftHistoryModel>>,String> {
  ProfileBaseRepository baseRepositoryProfile;
  GiftHistoryUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<List<GiftHistoryModel>>> call(String params)async {
    final result = await baseRepositoryProfile.getGiftHistory(userId: params);
    return result ;
  }
}