import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class RemoveFamilyUserUC extends UseCaseWithParams<String,ChangeFamilyUserTypeParameter>{
  final BaseFamilyRepository baseFamilyRepository;
  const RemoveFamilyUserUC({required this.baseFamilyRepository});

  @override
  ResultFuture<String> call(ChangeFamilyUserTypeParameter params) async{
    return await baseFamilyRepository.removeUserFromFamily(params: params);
  }

}