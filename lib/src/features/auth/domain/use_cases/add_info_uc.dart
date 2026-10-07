
import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/base/parameters.dart';
import '../../data/model/my_data_model.dart';
import '../repository/base_auth_repository.dart';

class AddInfoUc
    extends UseCaseWithParams<BaseResponse<MyDataModel>, InformationParametersUC > {
  final BaseAuthenticationRepository _repo;

  const AddInfoUc(this._repo);

  @override

  ResultFuture<BaseResponse<MyDataModel>> call(params) async {
    return await _repo.addInfo(params: params);
  }
}
