import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/send_message_all/send_message_all_bloc.dart';
import 'package:general/src/features/room/data/model/enter_room_model.dart';

class ShareRoomController {
  ShareRoomController();

  void shareRoomMessageLink(
    List<int> ids,
    bool selectAll,
    BuildContext context,
    EnterRoomModel roomModel,
    String secretKey,
  ) {
    final message =
        'share_room:$secretKey:${roomModel.roomName}\n:${roomModel.id!}:Room';
    final url = roomModel.roomCover ?? '';

    if (ids.isNotEmpty) {
      if (selectAll) {
        // send this room to all users except selected
        di<SendMessageAllBloc>().add(SendMessageAllEvent(
          type: 'not',
          users: '',
          exceptUsers: ids.join(','),
          url: url,
          message: message,
        ));
      } else {
        // send this room to selected
        di<SendMessageAllBloc>().add(SendMessageAllEvent(
          type: 'one',
          exceptUsers: '',
          url: url,
          message: message,
          users: ids.join(','),
        ));
      }
    } else {
      // send this room to all
      di<SendMessageAllBloc>().add(SendMessageAllEvent(
        type: 'all',
        users: '',
        exceptUsers: '',
        url: url,
        message: message,
      ));
    }
  }
}
