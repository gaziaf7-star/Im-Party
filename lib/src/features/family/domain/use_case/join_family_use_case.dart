import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';


class JoinFamilyUC extends UseCaseWithParams<String,String>{
  final BaseFamilyRepository baseFamilyRepository;
  const JoinFamilyUC({required this.baseFamilyRepository});

  @override
  ResultFuture<String> call(String params) async{
return await baseFamilyRepository.jOinFamily(params);
  }

}