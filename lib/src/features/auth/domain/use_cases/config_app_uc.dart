
import 'package:general/src/features/auth/data/model/config_model.dart';
import 'package:general/src/features/auth/domain/repository/base_auth_repository.dart';
import 'package:general/src/features/chats/chats.dart';

class GetConfigAppUseCase extends  UseCaseWithParams<ConfigModel, ConfigModelBody>  {
  final BaseAuthenticationRepository repo;

  GetConfigAppUseCase({required this.repo});

  @override
  ResultFuture<ConfigModel>  call(ConfigModelBody params) async {
    final result = await repo.configApp(params);
    return result;
  }
}
