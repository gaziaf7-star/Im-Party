import 'package:general/src/features/family/family.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/room_model.dart';

class FamilyRepositoryImp extends BaseFamilyRepository {
  final BaseFamilyRemoteDataSource baseFamilyRemoteDataSource;

  FamilyRepositoryImp({required this.baseFamilyRemoteDataSource});

  @override
  ResultFuture<BaseResponse<List<FamilyRankModel>>> fetchFamilyRanking(
      String time) {
    return execute<BaseResponse<List<FamilyRankModel>>>(
        () => baseFamilyRemoteDataSource.fetchFamilyRanking(time));
  }

  @override
  ResultFuture<BaseResponse<int>> createFamily(
      {required FamilyParameter params}) {
    return execute<BaseResponse<int>>(
        () => baseFamilyRemoteDataSource.createFamily(params: params));
  }

  @override
  ResultFuture<String> jOinFamily(String familyId) {
    return execute<String>(
        () => baseFamilyRemoteDataSource.joinFamily(familyId));
  }

  @override
  ResultFuture<BaseResponse<ShowFamilyModel>> editFamily(
      {required FamilyParameter params}) {
    return execute<BaseResponse<ShowFamilyModel>>(
        () => baseFamilyRemoteDataSource.editFamily(params: params));
  }

  @override
  ResultFuture<BaseResponse<ShowFamilyModel>> showFamily(String id) {
    return execute<BaseResponse<ShowFamilyModel>>(
        () => baseFamilyRemoteDataSource.showFamily(id));
  }

  @override
  ResultFuture<BaseResponse<List<RoomModel>>> fetchFamilyRoom(String familyId) {
    return execute<BaseResponse<List<RoomModel>>>(
        () => baseFamilyRemoteDataSource.fetchFamilyRoom(familyId));
  }

  @override
  ResultFuture<String> exitFamily() {
    return execute<String>(() => baseFamilyRemoteDataSource.exitFamily());
  }

  @override
  ResultFuture<BaseResponse<FamilyMemberModel>> fetchFamilyMember(
      {required FamilyParameter params}) {
    return execute<BaseResponse<FamilyMemberModel>>(
        () => baseFamilyRemoteDataSource.fetchFamilyMember(params: params));
  }

  @override
  ResultFuture<String> changeUserType(
      {required ChangeFamilyUserTypeParameter params}) {
    return execute<String>(
        () => baseFamilyRemoteDataSource.changeUserType(params: params));
  }

  @override
  ResultFuture<BaseResponse<MemberFamilyDataModel?>> familyTakeAction({required FamilyTakeActionReq params}) {
    return execute<BaseResponse<MemberFamilyDataModel?>>(
        () => baseFamilyRemoteDataSource.familyTakeAction(params: params));
  }

  @override
  ResultFuture<BaseResponse<List<FamilyRequestsModel>>> getFamilyRequest() {
    return execute<BaseResponse<List<FamilyRequestsModel>>>(
        () => baseFamilyRemoteDataSource.getFamilyRequest());
  }

  @override
  ResultFuture<String> removeUserFromFamily(
      {required ChangeFamilyUserTypeParameter params}) {
    return execute<String>(
        () => baseFamilyRemoteDataSource.removeUserFromFamily(params: params));
  }

  @override
  ResultFuture<String> deleteFamily(String id) {
    return execute<String>(() => baseFamilyRemoteDataSource.deleteFamily(id));
  }

  @override
  ResultFuture<BaseResponse<List<FamilyRankModel>>> getAllFamily() {
    return execute<BaseResponse<List<FamilyRankModel>>>(
            () => baseFamilyRemoteDataSource.getAllFamily());
  }
}
