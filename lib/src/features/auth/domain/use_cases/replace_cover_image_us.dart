import '../../../../core/index.dart';
import '../../auth.dart';

class ReplaceCoverImageUseCase extends UseCaseWithParams<BaseResponse<String>,
    ReplaceCoverImageParametersUC> {
  final BaseAuthenticationRepository repo;

  const ReplaceCoverImageUseCase({required this.repo});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repo.replaceCoverImage(params: params);
  }
}
