import '../../../../core/index.dart';
import '../../auth.dart';

class ChangeNumberUseCase extends UseCaseWithParams<BaseResponse<String>, SendCodeParameter> {
  final BaseAuthenticationRepository repo;

  const ChangeNumberUseCase({required this.repo });

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repo.changePhone(params);
  }
}