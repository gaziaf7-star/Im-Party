import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_data/get_my_data_bloc.dart';
import 'package:general/src/features/room/room.dart';

/// Applies the backend's `user_profile_updated` broadcast (Centrifugo channel
/// `live-stream-event`, event `live.stream.event`, routed here from
/// `get_my_data_bloc.dart`) so a name / photo / cover change shows up
/// everywhere at once, without the user re-entering the room:
///
///  - the signed-in user's own profile data is re-fetched and their seat is
///    repainted and re-published to the other participants;
///  - another user's mic seat in the current room is repainted;
///  - the room owner's header fields are updated when the owner changed.
///
/// Payload (backend contract): `{action_type: "user_profile_updated",
/// user_id, name, profile_image | avatar, cover_image, ...}`.
class UserProfileRealtimeController {
  UserProfileRealtimeController._();
  static final UserProfileRealtimeController instance =
      UserProfileRealtimeController._();

  /// Bumped on every applied update, for any screen that wants to refresh a
  /// cached user (name / photo) when it changes.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Map<String, dynamic> _extract(Map<String, dynamic> raw) {
    var json = raw;
    for (final key in const ['messageContent', 'data']) {
      final inner = json[key];
      if (inner is Map) json = Map<String, dynamic>.from(inner);
    }
    return json;
  }

  void handleEvent(dynamic payload) {
    if (payload is! Map) return;
    final json = _extract(Map<String, dynamic>.from(payload));
    final action = json['action_type'] ?? json['action'] ?? json['type'];
    if (action != 'user_profile_updated') return;
    debugPrint('[ProfileRT] user_profile_updated user_id=${json['user_id'] ?? json['id']} name=${json['name']}');

    final uid = '${json['user_id'] ?? json['id'] ?? ''}';
    if (uid.isEmpty || uid == 'null') return;

    final name = '${json['name'] ?? ''}'.trim();
    final photo = '${json['profile_image'] ?? json['avatar'] ?? ''}'.trim();
    final attrs = <String, String>{
      if (name.isNotEmpty) 'name': name,
      if (photo.isNotEmpty) 'avatar': EndPoints.getImage(photo),
    };

    final myId = '${MyDataModel.getInstance().id ?? ''}';
    final controller = RoomData.instance.utdController;

    if (uid == myId) {
      // Own profile: refresh every screen that reads MyDataModel.
      di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));
      // Repaint our seat and tell the other participants.
      controller?.updateSelfAttributes(attrs);
    } else {
      controller?.applyRemoteCosmeticOverride(uid, attrs);
    }

    // Room header (owner name / photo).
    final room = RoomData.instance.roomOrNull;
    if (room != null && '${room.ownerId ?? ''}' == uid) {
      if (name.isNotEmpty) room.ownerName = name;
      if (photo.isNotEmpty) room.ownerImage = photo;
    }

    revision.value++;
  }
}
