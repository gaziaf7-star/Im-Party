import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/music_url_model.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class GetMyMusicUc
    extends UseCaseWithoutParams<BaseResponse<List<MusicModel>>> {
  final RoomBaseRepository _repo;

  GetMyMusicUc(this._repo);
  @override
  ResultFuture<BaseResponse<List<MusicModel>>> call() async {
    final result = await _repo.getMyMusic();
    return result;
  }
}
