import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class EmojiUC extends UseCaseWithParams<BaseResponse<List<EmojiModel>> , String> {
  final RoomBaseRepository _repo;
  const EmojiUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<EmojiModel>>> call(param) async {
    return await _repo.fetchEmoji(param);
  }
}
