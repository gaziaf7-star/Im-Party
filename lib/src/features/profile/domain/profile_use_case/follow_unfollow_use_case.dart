

import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../profile_base_repository/profile_base_repository.dart';

class MakeFollowUseCase extends UseCaseWithParams<BaseResponse<String>,String> {
  final ProfileBaseRepository profileBaseRepository;

  MakeFollowUseCase({required this.profileBaseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(String params) async {
    final result =await profileBaseRepository.makeFollow(userId: params);
    return result;
  }

  }

class MakeUnFollowUseCase extends UseCaseWithParams<BaseResponse<String>,String> {
  final ProfileBaseRepository profileBaseRepository;

  MakeUnFollowUseCase({required this.profileBaseRepository});


  @override
  ResultFuture<BaseResponse<String>> call(String params) async {
    final result =await profileBaseRepository.makeUnFollow(userId: params);
    return result;
  }
}