
import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_use_case.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';

class RemoveBlockUseCase extends UseCaseWithParams<String,String> {
  ProfileBaseRepository baseRepositoryProfile;
  RemoveBlockUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<String> call(String params)async {
    final result = await baseRepositoryProfile.removeBloc(userId: params);
    return result;
  }
  }

