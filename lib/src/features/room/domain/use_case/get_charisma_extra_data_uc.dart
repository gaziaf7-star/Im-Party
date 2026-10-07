import 'package:general/src/features/room/room.dart';
import '../../../../core/index.dart';

class GetCharismaExtraDataUC extends UseCaseWithParams<BaseResponse<List<CharismaModel>>,String>{
  final RoomBaseRepository _repo;

  GetCharismaExtraDataUC( this._repo);

  @override
  ResultFuture<BaseResponse<List<CharismaModel>>> call(String params) async {
    return  _repo.getCharismaExtraData(params);
  }
}
