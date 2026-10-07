import '../../../../core/index.dart';
import '../../data/model/levels_model.dart';
import '../profile_base_repository/profile_base_repository.dart';

class AllLevelsUseCase
    extends UseCaseWithParams<BaseResponse<List<AllLevels>>, int> {
  final ProfileBaseRepository baseRepositoryProfile;

  AllLevelsUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<List<AllLevels>>> call(int params) async {
    final result = await baseRepositoryProfile.fetchLevels(params);
    return result;
  }
}
