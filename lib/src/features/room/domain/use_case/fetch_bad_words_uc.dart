import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class FetchBadWordsUC extends UseCaseWithoutParams<BaseResponse<List<String>>> {
  final RoomBaseRepository _repo;

  FetchBadWordsUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<String>>> call() async {
    return await _repo.fetchBadWords();
  }
}
