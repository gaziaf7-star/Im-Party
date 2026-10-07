import 'package:general/src/features/room/data/model/extra_profile_data_model.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';
import 'package:general/src/core/index.dart';

class ExtraProfileDataUc extends UseCaseWithParams<BaseResponse<ExtraProfileDataModel>,String>{

  final RoomBaseRepository _repo;

  ExtraProfileDataUc(this._repo);

  @override
  ResultFuture<BaseResponse<ExtraProfileDataModel>> call(String params) async {
    return await _repo.fetchExtraProfileData(params) ;
  }
}