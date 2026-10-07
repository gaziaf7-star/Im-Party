import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/send_message_all/send_message_all_bloc.dart';

import '../../../src/features/reels/domain/entities/reel_entity.dart';

class ShareController {
  ShareController();

  void shareReelMessageLink(List<int> ids, bool selectAll, BuildContext context,
      ReelsEntity reelModel, String secretKey) {
    if (ids.isNotEmpty) {
      if (selectAll) {
        // send this reel to all users except selected
        di<SendMessageAllBloc>().add(SendMessageAllEvent(
          type: 'not',
          users: '',
          exceptUsers: ids.join(','),
          url: reelModel.subFrame,
          message:
              'share_reel:$secretKey:${reelModel.description}\n:${reelModel.id!}:Reel',
        ));
      } else {
        // send this reel to selected
        di<SendMessageAllBloc>().add(SendMessageAllEvent(
          type: 'one',
          exceptUsers: '',
          url: reelModel.subFrame,
          message:
              'share_reel:$secretKey:${reelModel.description}\n:${reelModel.id!}:Reel',
          users: ids.join(','),
        ));
      }
    } else {
      // send this reel to all
      di<SendMessageAllBloc>().add(SendMessageAllEvent(
        type: 'all',
        users: '',
        exceptUsers: '',
        url: reelModel.subFrame,
        message:
            'share_reel:$secretKey:${reelModel.description}\n:${reelModel.id!}:Reel',
      ));
    }
  }
}
