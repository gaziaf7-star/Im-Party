import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class ExitFamilyUC extends UseCaseWithoutParams<String> {
  final BaseFamilyRepository baseFamilyRepository;
  const ExitFamilyUC({required this.baseFamilyRepository});
  @override
  ResultFuture<String> call() async {
    return await baseFamilyRepository.exitFamily();
  }
}
