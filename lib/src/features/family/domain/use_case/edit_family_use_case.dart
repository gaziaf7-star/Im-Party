import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class EditFamilyUC
    extends UseCaseWithParams<BaseResponse<ShowFamilyModel>, FamilyParameter> {
  final BaseFamilyRepository baseFamilyRepository;
  const EditFamilyUC({required this.baseFamilyRepository});
  @override
  ResultFuture<BaseResponse<ShowFamilyModel>> call(
      FamilyParameter params) async {
    final result = await baseFamilyRepository.editFamily(params: params);
    return result;
  }
}
