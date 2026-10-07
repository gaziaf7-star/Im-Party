import 'package:general/src/features/room/room.dart';

class GetCharismaLevelsUC {
  final RoomBaseRepository _repo;

  GetCharismaLevelsUC(this._repo);

  Future<List<CharismaLevelModel>> call() async {
    return _repo.getCharismaLevels();
  }
}
