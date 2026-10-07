import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class AddRoomBackGroundUseCase {
  final RoomBaseRepository _repo;

  AddRoomBackGroundUseCase(this._repo);

  ResultFuture<String> call(File roomBackGround) async {
    return await _repo.addRoomBackGround(roomBackGround);
  }
}
