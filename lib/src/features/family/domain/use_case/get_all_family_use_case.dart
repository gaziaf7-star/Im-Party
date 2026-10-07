import '../../../../../reels_viewer/reels_viewer.dart';
import '../../family.dart';

class GetAllFamilyUseCase extends UseCaseWithoutParams<BaseResponse<List<FamilyRankModel>>>{
  final BaseFamilyRepository baseFamilyRepository;
  const GetAllFamilyUseCase({required this.baseFamilyRepository});

  @override
  ResultFuture <BaseResponse<List<FamilyRankModel>>> call() async{
    return await baseFamilyRepository.getAllFamily();
    }
}