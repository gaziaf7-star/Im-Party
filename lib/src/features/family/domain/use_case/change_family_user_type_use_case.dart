import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class ChangeFamilyUserTypeUC
    extends UseCaseWithParams<String, ChangeFamilyUserTypeParameter> {
  final BaseFamilyRepository baseFamilyRepository;

  const ChangeFamilyUserTypeUC({required this.baseFamilyRepository});

  @override
  ResultFuture <String> call(params) async{

    return await baseFamilyRepository.changeUserType(params: params);

  }
}
