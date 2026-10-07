import '../../../../core/index.dart';
import '../profile_base_repository/profile_base_repository.dart';



class FetchMyDataUseCase extends UseCaseWithoutParams<BaseResponse<MyDataModel>> {
  final ProfileBaseRepository baseRepositoryProfile;
  const FetchMyDataUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture <BaseResponse<MyDataModel>> call() async {
    final result = await baseRepositoryProfile.getMyData();
    return result;
  }
}
