import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/cp/data/model/cp_model.dart';
import '../../../../core/index.dart';


class CpRepositoryImp extends CpBaseRepository {
  final BaseCpRemotelyDataSource baseCpRemotelyDataSource;

  CpRepositoryImp({required this.baseCpRemotelyDataSource});


  @override
  ResultFuture<BaseResponse<CpRelationsModel>> getCpRelations() {
    return execute<BaseResponse<CpRelationsModel>>(
        () => baseCpRemotelyDataSource.getCpRelations());
  }

  @override
  ResultFuture<BaseResponse<String>> cpRequestRespond(CpRequestRespondParam param) {
    return execute<BaseResponse<String>>(
        () => baseCpRemotelyDataSource.cpRequestRespond(param));
  }

  @override
  ResultFuture<String> cpRequest({required CpRequestParam param}) {
    return execute<String>(
        () => baseCpRemotelyDataSource.cpRequest(param: param));
  }

  @override
  ResultFuture<BaseResponse<CpModel>> fetchRankingCp({
    required TopParameter params,
  }) {
    return execute<BaseResponse<CpModel>>(
            () => baseCpRemotelyDataSource.fetchRankingCp(params: params));
  }


  @override
  ResultFuture<String> buyCpSeats({required String wareId}) {
    return execute<String>(
        () => baseCpRemotelyDataSource.buyCpSeats(wareId: wareId));
  }

  @override
  ResultFuture<BaseResponse<CpProfileModel>> getCpProfile(
      {required String userId}) {
    return execute<BaseResponse<CpProfileModel>>(
        () => baseCpRemotelyDataSource.getCpProfile(userId: userId));
  }

  @override
  ResultFuture<BaseResponse<List<CpRelationLevelsGiftsModel>>> getRelationsCpLevelsGifts() {
    return execute<BaseResponse<List<CpRelationLevelsGiftsModel>>>(
        () => baseCpRemotelyDataSource.getRelationsCpLevelsGifts());
  }

  @override
  ResultFuture<BaseResponse<List<CpRelationLevelsGiftsModel>>> getRelationsCpSpecialFriendLevelsGifts() {
    return execute<BaseResponse<List<CpRelationLevelsGiftsModel>>>(
        () => baseCpRemotelyDataSource.getRelationsCpSpecialFriendLevelsGifts());
  }
}
