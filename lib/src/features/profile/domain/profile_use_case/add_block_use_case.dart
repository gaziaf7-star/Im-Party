
import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';


class AddBlockUseCase extends UseCaseWithParams <String,String> {
  ProfileBaseRepository baseRepositoryProfile;
  AddBlockUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<String> call(String params)async {
    final result = await baseRepositoryProfile.addBloc(userId: params);
    return result;
  }
}
