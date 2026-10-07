import 'package:general/src/features/room/data/model/get_games_images_model.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';
import 'package:general/src/core/index.dart';

class FetchGamesImagesUc extends UseCaseWithParams<BaseResponse<SvgaDataModel>,int>{

  final RoomBaseRepository _repo;

  FetchGamesImagesUc(this._repo);

  @override
  ResultFuture<BaseResponse<SvgaDataModel>> call(int params) async {
    return await _repo.fetchGamesImages(params) ;
  }
}