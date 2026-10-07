import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

class GetFamilyRequestsRoomsUC
    extends UseCaseWithoutParams<BaseResponse<List<FamilyRequestsModel>>> {
  final BaseFamilyRepository baseFamilyRepository;

  const GetFamilyRequestsRoomsUC({required this.baseFamilyRepository});

  @override
  ResultFuture<BaseResponse<List<FamilyRequestsModel>>> call() async {
    final result = await baseFamilyRepository.getFamilyRequest();
    return result;
  }
}
