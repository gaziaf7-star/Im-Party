import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetMyBackgroundUseCase {
  final RoomBaseRepository _repo;

  GetMyBackgroundUseCase(this._repo);

  ResultFuture<List<BackgroundModel>> call() async {
    return await _repo.getMyAllBackGround();
  }
}
