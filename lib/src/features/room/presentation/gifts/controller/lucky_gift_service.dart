import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/lucky_log.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_bottom_bar.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_user_only.dart';
import 'package:general/src/features/room/presentation/gifts/view/gift_room_page.dart';
import 'package:general/src/features/room/presentation/manager/manger_lucky_gift_banner/lucky_gift_banner_event.dart';
import 'package:general/src/features/room/room.dart';
import 'package:uuid/uuid.dart';

class LuckyGiftService {
  LuckyGiftService._();
  static final LuckyGiftService instance = LuckyGiftService._();

  bool _isCleaningUp = false;

  /// Recipient list frozen at combo start: every flush of the same combo goes
  /// to the SAME recipients regardless of selection changes mid-combo, and an
  /// empty list never produces a request.
  String? _comboToUid;

  void startCombo() {
    _comboToUid = null;
  }

  void sendGift({required String roomOwnerId}) {
    final giftId = di<GiftBloc>().state.giftId;
    if (giftId.toString().isEmpty) return;
    if (LuckyGiftController.instance.numOfRequest <= 0) return;

    final receiver = _comboToUid ??= _resolveReceiver();
    if (receiver.isEmpty) {
      LuckyLog.write('LUCKYFLY: sendGift skipped — empty toUid');
      LuckyGiftController.instance.numOfRequest = 0;
      return;
    }

    // Per-request idempotency nonce: the backend dedups on it, so a network
    // retry/timeout replay can never double-charge this flush.
    final nonce = const Uuid().v4();

    LuckyLog.write('LUCKYFLY: sendGift — giftId=$giftId, toUid=$receiver, '
        'count=${LuckyGiftController.instance.numOfRequest}, '
        'num=${GiftBottomBar.numberOfGift.value}, nonce=$nonce');

    di<LuckyGiftBannerBloc>().add(
      SendLuckyGiftEvent(
        roomId: RoomData.instance.room.id.toString(),
        id: giftId.toString(),
        toUid: receiver,
        num: GiftBottomBar.numberOfGift.value.toString(),
        count: LuckyGiftController.instance.numOfRequest.toString(),
        nonce: nonce,
      ),
    );

    LuckyGiftController.instance.numOfRequest = 0;
  }

  String _resolveReceiver() {
    List<String> userSelected = [];
    GiftUser.userSelected.value.forEach((key, value) {
      userSelected.add(value.userId);
    });

    if (userSelected.isEmpty && GiftUserOnly.userSelected == "") {
      return "";
    }

    return GiftUserOnly.userSelected == ""
        ? userSelected.join(',')
        : GiftUserOnly.userSelected;
  }

  Future<void> endAllLuckyGift() async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    LuckyLog.write('LUCKYFLY: endAllLuckyGift triggered');

    _comboToUid = null; // next combo re-freezes its own recipient list

    try {
      GiftScreen.chosenGift = null;
      di<GiftBloc>().add(
        const ChangeGiftDataEvent(
          numOfGift: -1,
          giftId: -1,
          giftPrice: -1,
          categoryId: -1,
        ),
      );

      LuckyGiftController.instance.dispose();

      di<LuckyGiftBannerBloc>().add(EndBannerEvent());
      di<LuckyGiftAnaimationManagerBloc>()
          .add(const InitLuckyGiftAnaimationManagerEvent());
      GiftBottomBar.typeCandy.value = TypeCandy.non;

        if (!RoomData.instance.isExitingRoom) {
          final roomData = {
            "action": LuckyGiftController.endLuckyGiftforReciver,
            "messageContent": {
              "message": LuckyGiftController.endLuckyGiftforReciver,
            },
          };

          try {
            sendRoomData(data: roomData);
          } catch (e) {
            debugPrint('sendRoomData failed: $e');
          }
        }
    } finally {
      _isCleaningUp = false;
    }
  }

  void resetGuard() {
    _isCleaningUp = false;
  }
}
