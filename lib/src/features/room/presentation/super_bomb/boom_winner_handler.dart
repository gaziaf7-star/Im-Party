import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/super_bomb/view/super_boom_controller.dart';
import 'package:general/src/features/room/presentation/super_bomb/view/widgets/winner_dialog.dart';

/// Shows the super-boom winner dialog when the backend delivers the
/// `room_boom_rewards` event.
///
/// This logic was moved out of the deleted legacy in-room realtime service (in-room legacy realtime,
/// removed with Zego). The event is now delivered over Centrifugo and invoked
/// from `get_my_data` when the `room_boom_rewards` event arrives.
class BoomWinnerHandler {
  const BoomWinnerHandler._();

  static void show(dynamic data, {int retryDelayMs = 500}) {
    if (SuperBoomController.superBoomVideo.value == "") {
      // ✅ Condition satisfied → show dialog

      // winners field is a map of IDs
      final winners = data["winners"] as Map<String, dynamic>?;

      if (winners != null) {
        if (winners.containsKey(MyDataModel.getInstance().id.toString())) {
          // ✅ Access the data for this ID
          final winnerData = winners[MyDataModel.getInstance().id.toString()];

          final dialogContext = SafeNavigator.context;
          if (dialogContext != null) {
            showDialog(
              barrierDismissible: true,
              context: dialogContext,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: ColorManager.transparent,
                  contentPadding: EdgeInsets.zero,
                  content: WinnerDialog(
                    gift: winnerData["image"] ?? "",
                    giftType: winnerData["image_type"] ?? "",
                  ),
                );
              },
            );
          }
          Methods.printLog("Fetch Bag Gift After Send Gift");
          di<FetchGiftBloc>().add(const FetchBagGiftEvent());
        }
      }
    } else {
      // ⏳ Retry until condition is satisfied
      Future.delayed(Duration(milliseconds: retryDelayMs), () {
        show(data, retryDelayMs: retryDelayMs);
      });
    }
  }
}
