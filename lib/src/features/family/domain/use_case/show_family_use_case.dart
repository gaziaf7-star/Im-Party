import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class ShowFamilyUC
    extends UseCaseWithParams<BaseResponse<ShowFamilyModel>, String> {
  final BaseFamilyRepository baseFamilyRepository;
  const ShowFamilyUC({required this.baseFamilyRepository});

  @override
  ResultFuture<BaseResponse<ShowFamilyModel>> call(String params) async {
    return await baseFamilyRepository.showFamily(params);
  }
}
