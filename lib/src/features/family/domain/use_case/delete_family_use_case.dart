import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class DeleteFamilyUC extends UseCaseWithParams<String, String> {
  final BaseFamilyRepository baseFamilyRepository;
  const DeleteFamilyUC({required this.baseFamilyRepository});

  @override
  ResultFuture<String> call(String params) async {
    return await baseFamilyRepository.deleteFamily(params);
  }
}
