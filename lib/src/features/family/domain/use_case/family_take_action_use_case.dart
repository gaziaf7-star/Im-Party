import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class FamilyTakeActionUC extends UseCaseWithParams<BaseResponse<MemberFamilyDataModel?>,FamilyTakeActionReq>{
  final BaseFamilyRepository baseFamilyRepository;
  const FamilyTakeActionUC({required this.baseFamilyRepository});

  @override
  ResultFuture<BaseResponse<MemberFamilyDataModel?>> call(FamilyTakeActionReq params) async{
    return await baseFamilyRepository.familyTakeAction(params: params);
  }

}