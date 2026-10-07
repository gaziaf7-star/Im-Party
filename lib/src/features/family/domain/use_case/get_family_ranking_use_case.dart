import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class GetFamilyRankingUC extends UseCaseWithParams <BaseResponse<List<FamilyRankModel>>,String>{
  final BaseFamilyRepository baseFamilyRepository;
const GetFamilyRankingUC({required this.baseFamilyRepository});
  @override
  ResultFuture <BaseResponse<List<FamilyRankModel>>> call(String params) async{
 return await baseFamilyRepository.fetchFamilyRanking(params);
  }
}
