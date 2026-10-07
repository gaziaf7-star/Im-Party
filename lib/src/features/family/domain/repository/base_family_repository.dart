import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/home/data/model/room_model.dart';

abstract class BaseFamilyRepository {
  ResultFuture<BaseResponse<int>> createFamily(
      {required FamilyParameter params});

  ResultFuture<String> jOinFamily(String familyId);

  ResultFuture<BaseResponse<ShowFamilyModel>> editFamily(
      {required FamilyParameter params});

  ResultFuture<BaseResponse<ShowFamilyModel>> showFamily(String id);

  ResultFuture<BaseResponse<List<RoomModel>>> fetchFamilyRoom(String familyId);

  ResultFuture<String> exitFamily();

  ResultFuture<BaseResponse<FamilyMemberModel>> fetchFamilyMember(
      {required FamilyParameter params});
  ResultFuture<String> changeUserType(
      {required ChangeFamilyUserTypeParameter params});

  ResultFuture<BaseResponse<MemberFamilyDataModel?>> familyTakeAction({required FamilyTakeActionReq params});
  ResultFuture<BaseResponse<List<FamilyRequestsModel>>> getFamilyRequest();
  ResultFuture<String> deleteFamily(String id);
  ResultFuture<String> removeUserFromFamily(
      {required ChangeFamilyUserTypeParameter params});
  ResultFuture<BaseResponse<List<FamilyRankModel>>> fetchFamilyRanking(
      String time);
  ResultFuture<BaseResponse<List<FamilyRankModel>>> getAllFamily();
}
