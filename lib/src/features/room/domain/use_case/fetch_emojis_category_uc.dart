import 'package:general/src/features/room/data/model/reaction_model.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../core/index.dart';

class FetchEmojisCategoryUc
    extends UseCaseWithoutParams<BaseResponse<List<ReactionModel>>> {
  final RoomBaseRepository _repo;

  const FetchEmojisCategoryUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<ReactionModel>>> call() async {
    final result = await _repo.fetchEmojisCategory();
    return result;
  }
}
