import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/music_url_model.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class GetMusicUc extends UseCaseWithoutParams<BaseResponse<List<MusicModel>>> {
  final RoomBaseRepository _repo;

  GetMusicUc(this._repo);
  @override
  ResultFuture<BaseResponse<List<MusicModel>>> call() async {
    final result = await _repo.getMusic();
    return result;
  }
}
