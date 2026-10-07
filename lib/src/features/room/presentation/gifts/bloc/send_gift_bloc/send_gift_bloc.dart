import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_event.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_bottom_bar.dart';
import 'package:general/src/features/room/room.dart';

part 'send_gift_events.dart';
part 'send_gift_states.dart';

class SendGiftBloc extends Bloc<SendGiftEvents, SendGiftStates> {
  final SendGiftUC _sendGiftUC;

  SendGiftBloc(this._sendGiftUC) : super(const IntialSendGiftStates()) {
    on<SendGiftesEvent>(_sendGiftEvent);
  }

  Future<void> _sendGiftEvent(
      SendGiftesEvent event,
      Emitter<SendGiftStates> emit,
      ) async {
    emit(const LoadingSendGiftStates());

    final result = await _sendGiftUC(
      GiftParameter(
        roomId: event.roomId,
        id: event.id,
        toUid: event.toUid,
        num: event.num,
        toZego: event.toZego,
        giftType: GiftBottomBar.giftType == TypeGift.bag
            ? TypeGift.bag.value
            : null,
      ),
    );

    result.fold(
          (failure) {
        emit(
          ErrorSendGiftStates(
            error: NetworkExceptions.getErrorMessage(failure),
          ),
        );
      },
          (success) {
        // Backend success is the source of truth.
        //
        // IMPORTANT:
        // The old code performed ANOTHER local balance check here after the
        // server had already accepted and charged the gift. If local coins or
        // recipient state was stale, the API returned 200 but this block was
        // skipped, so:
        //   - no GiftController.showGifts()
        //   - no sendRoomData()
        //   - coins changed, but no animation appeared.
        //
        // Never gate the display/broadcast after a successful backend send.

        final serverReceiverIds = success.data?.data?.ids
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toList(growable: false) ??
            const <String>[];

        final toUidIds = event.toUid
            .split(',')
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toList(growable: false);

        final receiverIds = serverReceiverIds.isNotEmpty
            ? serverReceiverIds
            : toUidIds.isNotEmpty
            ? toUidIds
            : event.userSelected
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toList(growable: false);

        final rawGiftPath =
        (event.giftData?.img?.trim().isNotEmpty ?? false)
            ? event.giftData!.img!
            : (event.giftData?.showImg ?? '');

        final resolvedGiftPath =
        EndPoints.getImage(rawGiftPath);

        final giftType =
        event.giftData?.giftType?.trim().isNotEmpty == true
            ? event.giftData!.giftType
            : 'image';

        final quantity =
            int.tryParse(event.num) ?? event.numberOfGifts;

        final giftValuePerReceiver =
            event.selectedGiftPrice * quantity;

        final updatedRoomGiftPrice =
        Methods().convertToAbbreviatedString(
          giftValuePerReceiver +
              Methods().convertFromAbbreviatedString(
                di<GiftBloc>().state.price,
              ),
        );

        final mapInformation = <String, dynamic>{
          "action": "showGifts",
          "messageContent": <String, dynamic>{
            "message": "showGifts",
            "showGift": resolvedGiftPath,
            "send_id": MyDataModel.getInstance().id,
            "receiver_id": receiverIds,
            "gift_price": updatedRoomGiftPrice,
            "coins": RoomData.instance.myCoins.value,
            "type": giftType,
            "giftType": event.typeGift,
            "userGiftTP": giftValuePerReceiver,
          },
        };

        Methods.printLog(
          '🎁 [SEND_GIFT_SUCCESS] '
              'giftId=${event.id} '
              'type=$giftType '
              'receivers=$receiverIds '
              'raw=$rawGiftPath '
              'resolved=$resolvedGiftPath',
        );

        if (resolvedGiftPath.trim().isNotEmpty) {
          di<GiftBloc>().add(
            UpdateRoomGiftsPriceEvent(
              price: updatedRoomGiftPrice,
            ),
          );

          // Queue the animation locally FIRST. This guarantees that the sender
          // sees the same animation even when the realtime transport does not
          // echo the sender's own message.
          GiftController().showGifts(
            mapInformation,
            MyDataModel.getInstance().id.toString(),
            GiftController().loadMp4Gift,
            GiftController().loadAnimationGift,
            GiftController().loadAlphaMp4,
            RoomData.instance.room.ownerId.toString(),
          );

          Methods.printLog(
            '🎁 [LOCAL_GIFT_DISPLAY_DISPATCHED] '
                'path=$resolvedGiftPath type=$giftType',
          );

          // Bump the Charisma badge locally, right now, for the sender's own
          // view. The realtime transport never echoes a sender's own
          // broadcast frame back to itself (see GiftMessageHandler), so
          // without this the sender's badge stayed frozen until the room
          // was re-entered and re-seeded from the server — everyone else
          // still gets it live via the incoming frame in
          // RoomMessageProcessor.
          di<CharismaBloc>().add(
            AccumulateCharismaFromGiftEvent(
              receiverIds: receiverIds,
              giftValue: giftValuePerReceiver,
            ),
          );

          // Broadcast to everyone else in the room.
          sendRoomData(
            data: mapInformation[messageContent]
            as Map<String, dynamic>,
          );

          Methods.printLog(
            '🎁 [ROOM_GIFT_BROADCAST_DISPATCHED] '
                'receivers=$receiverIds',
          );

          // Keep existing PK accounting behaviour.
          addGiftToPK(
            receiverIds,
            giftValuePerReceiver,
          );
        } else {
          Methods.printLog(
            '🚨 [GIFT_DISPLAY_SKIPPED] '
                'backend succeeded but animation path is empty '
                'giftId=${event.id}',
          );
        }

        // Emit success AFTER local/realtime gift dispatch.
        // Variant-A can now close the bottom sheet without racing the display.
        emit(
          SuccessSendGiftStates(
            message: success.message,
          ),
        );

        di<GetMyLevelBloc>().add(
          const GetMyLevelData(),
        );
      },
    );
  }
}