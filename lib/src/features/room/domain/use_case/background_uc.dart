import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class BackGroundUC extends UseCaseWithoutParams<List<BackgroundModel>>{
  final RoomBaseRepository _repo;
  BackGroundUC(this._repo);
  @override
  ResultFuture<List<BackgroundModel>> call() async {
    return await _repo.fetchBackGround();
  }
}
