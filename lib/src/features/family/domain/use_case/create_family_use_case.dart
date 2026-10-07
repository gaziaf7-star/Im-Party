import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class CreateFamilyUC
    extends UseCaseWithParams<BaseResponse<int>, FamilyParameter> {
  final BaseFamilyRepository baseFamilyRepository;
  const CreateFamilyUC({required this.baseFamilyRepository});
  @override
  ResultFuture<BaseResponse<int>> call(FamilyParameter params) async {
    final result = await baseFamilyRepository.createFamily(params: params);
    return result;
  }
}
