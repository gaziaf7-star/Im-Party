import 'package:general/src/features/room/room.dart';

class RoomService {
  RoomService._();
  static final RoomService instance = RoomService._();

  List<UTDParticipant> getAllUsers() {
    final controller = RoomData.instance.utdController;
    if (controller == null) return [];
    return controller.participants;
  }

  Stream<List<UTDParticipant>> getUserListStream() {
    final controller = RoomData.instance.utdController;
    if (controller == null) return Stream.value([]);
    return controller.participantsStream;
  }

  void reset() {
    // No music state to clean up — handled by MusicRoomBloc
  }
}
