import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';

class ChangeCountryUC extends UseCaseWithParams<BaseResponse<int>, String> {
  final ProfileBaseRepository repository;
  const ChangeCountryUC({required this.repository});

  @override
  ResultFuture<BaseResponse<int>> call(params) async {
    final result = await repository.changeCountry(params);
    return result;
  }
}
