import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class OpenGameUseCase {
  final RoomBaseRepository _repo;
  OpenGameUseCase(this._repo);

  ResultFuture<String> call(int id) async {
    final result = await _repo.openGame(id);
    return result;
  }
}
