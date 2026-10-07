import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class GetFamilyMemberUC extends UseCaseWithParams<
    BaseResponse<FamilyMemberModel>, FamilyParameter> {
  final BaseFamilyRepository baseFamilyRepository;

  const GetFamilyMemberUC({required this.baseFamilyRepository});

  @override
  ResultFuture<BaseResponse<FamilyMemberModel>> call(
      FamilyParameter params) async {
    return await baseFamilyRepository.fetchFamilyMember(params:params);
  }
}
