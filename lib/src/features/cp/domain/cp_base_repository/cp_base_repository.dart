import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/cp/data/model/cp_model.dart';
import '../../../../core/index.dart';

abstract class CpBaseRepository {
  ResultFuture<BaseResponse<List<CpRelationLevelsGiftsModel>>>
      getRelationsCpLevelsGifts();
  ResultFuture<BaseResponse<List<CpRelationLevelsGiftsModel>>>
      getRelationsCpSpecialFriendLevelsGifts();
  ResultFuture<BaseResponse<CpRelationsModel>> getCpRelations();
  ResultFuture<String> cpRequest({required CpRequestParam param});
  ResultFuture<String> buyCpSeats({required String wareId});
  ResultFuture<BaseResponse<CpProfileModel>> getCpProfile(
      {required String userId});
  ResultFuture<BaseResponse<String>> cpRequestRespond(CpRequestRespondParam param);
  ResultFuture<BaseResponse<CpModel>> fetchRankingCp({
    required TopParameter params,
  });
}
