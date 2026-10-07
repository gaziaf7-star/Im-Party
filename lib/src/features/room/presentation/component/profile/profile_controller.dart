import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../../core/index.dart';

bool checkIsUserOnMic(UserModel userData) {
  return RoomData.instance.utdController?.seatController
          .isUserOnSeat(userData.id.toString()) ??
      false;
}

bool checkisAdminOrHost(
  UserModel userData,
  MyDataModel myData,
  EnterRoomModel roomData,
) {
  bool isAdminORHost =
      ((userData.id != myData.id && userData.id != roomData.ownerId) &&
          (RoomData.instance.adminsInRoom.containsKey(myData.id.toString()) ||
              myData.id == roomData.ownerId));
  return isAdminORHost;
}

bool myProfileOrNot(
  int id,
  MyDataModel myData,
) {
  if (id == myData.id) {
    return true;
  } else {
    return false;
  }
}
