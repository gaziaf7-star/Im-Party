import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

/// Live-room gift send bloc — the standalone counterpart of the audio room's
/// [SendGiftBloc]. It reuses the shared REST send use case ([SendGiftUC]) and
/// the shared gift animation engine ([GiftController]), but broadcasts the gift
/// to other participants on the **live** data channel
/// ([LiveRoomData.sendLiveRoomData]) instead of the audio `sendRoomData` (which
/// targets the null audio controller while in a live room and silently drops).
sealed class LiveSendGiftState extends Equatable {
  const LiveSendGiftState();
  @override
  List<Object?> get props => [];
}

class LiveSendGiftInitial extends LiveSendGiftState {
  const LiveSendGiftInitial();
}

class LiveSendGiftLoading extends LiveSendGiftState {
  const LiveSendGiftLoading();
}

class LiveSendGiftSuccess extends LiveSendGiftState {
  final String message;
  const LiveSendGiftSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class LiveSendGiftError extends LiveSendGiftState {
  final String error;
  const LiveSendGiftError(this.error);
  @override
  List<Object?> get props => [error];
}

class LiveSendGiftEvent extends Equatable {
  final String roomId;
  final String id;
  final String toUid;
  final String num;
  final String typeGift;
  final List<String> userSelected;
  final List<String> userSelectedName;
  final int selectedGiftPrice;
  final int numberOfGifts;
  final int myCoins;
  final GiftsEntity? giftData;

  const LiveSendGiftEvent({
    required this.roomId,
    required this.id,
    required this.toUid,
    required this.num,
    required this.typeGift,
    required this.userSelected,
    required this.userSelectedName,
    required this.selectedGiftPrice,
    required this.numberOfGifts,
    required this.myCoins,
    required this.giftData,
  });

  @override
  List<Object?> get props => [
        roomId,
        id,
        toUid,
        num,
        typeGift,
        userSelected,
        userSelectedName,
        selectedGiftPrice,
        numberOfGifts,
        myCoins,
        giftData,
      ];
}

class LiveSendGiftBloc extends Bloc<LiveSendGiftEvent, LiveSendGiftState> {
  final SendGiftUC _sendGiftUC;

  LiveSendGiftBloc(this._sendGiftUC) : super(const LiveSendGiftInitial()) {
    on<LiveSendGiftEvent>(_onSend);
  }

  Future<void> _onSend(
    LiveSendGiftEvent event,
    Emitter<LiveSendGiftState> emit,
  ) async {
    emit(const LiveSendGiftLoading());

    final isBag = event.typeGift == TypeGift.bag.value;
    final result = await _sendGiftUC(
      GiftParameter(
        roomId: event.roomId,
        id: event.id,
        toUid: event.toUid,
        num: event.num,
        toZego: false,
        giftType: isBag ? TypeGift.bag.value : null,
      ),
    );

    result.fold(
      (failure) => emit(
        LiveSendGiftError(NetworkExceptions.getErrorMessage(failure)),
      ),
      (success) {
        // Backend success is authoritative. Match the audio gift pipeline:
        // never suppress display after the server charged the gift because a
        // local balance/recipient snapshot became stale while awaiting it.
        final serverReceiverIds = success.data?.data?.ids
                .map((id) => id.toString())
                .where((id) => id.isNotEmpty)
                .toList(growable: false) ??
            const <String>[];
        final receiverIds = serverReceiverIds.isNotEmpty
            ? serverReceiverIds
            : event.userSelected;
        final rawGiftPath = event.giftData?.img?.trim().isNotEmpty == true
            ? event.giftData!.img!
            : (event.giftData?.showImg ?? '');
        final resolvedGiftPath = EndPoints.getImage(rawGiftPath);
        final giftType = event.giftData?.giftType?.trim().isNotEmpty == true
            ? event.giftData!.giftType!
            : event.typeGift;
        final giftValue = event.selectedGiftPrice * int.parse(event.num);
        final accumulatedPrice = Methods().convertToAbbreviatedString(
          giftValue +
              Methods().convertFromAbbreviatedString(di<GiftBloc>().state.price),
        );
        final giftEventId =
            'live_gift_${DateTime.now().microsecondsSinceEpoch}_${event.id}';

        if (resolvedGiftPath.trim().isNotEmpty) {
          final mapInformation = {
            "action": "showGifts",
            "messageContent": {
              "message": "showGifts",
              "giftEventId": giftEventId,
              "showGift": resolvedGiftPath,
              "send_id": MyDataModel.getInstance().id,
              "receiver_id": receiverIds,
              "gift_price": accumulatedPrice,
              "coins": RoomData.instance.myCoins.value,
              "type": giftType,
              "giftType": event.typeGift,
              "userGiftTP": giftValue,
            }
          };

          di<GiftBloc>()
              .add(UpdateRoomGiftsPriceEvent(price: accumulatedPrice));

          // Local animation for the sender (shared engine).
          GiftController().showGifts(
            mapInformation,
            MyDataModel.getInstance().id.toString(),
            GiftController().loadMp4Gift,
            GiftController().loadAnimationGift,
            GiftController().loadAlphaMp4,
            LiveRoomData.instance.room.ownerId.toString(),
          );

          // Broadcast to other participants on the LIVE data channel.
          LiveRoomData.instance.sendLiveRoomData(
            data: mapInformation[messageContent] as Map<String, dynamic>,
          );

          // Per-stage guest counter (المسّات) — sender side (LiveKit never
          // echoes our own data message back).
          LiveRoomData.instance.addGuestStageTouches(
            receiverIds,
            giftValue,
          );

          // Gift line in the live comments — same canonical wire the audio
          // chat views localize/parse ("N x ارسل هدية قيمتها P الى Names"),
          // so it lands in the الكل/هدية tabs styled as a gift message.
          final names = event.userSelectedName.join(' , ');
          final totalPrice = giftValue;
          final me = MyDataModel.getInstance();
          LiveRoomData.instance.chatController?.sendMessage(
            '${event.num} x ارسل هدية قيمتها $totalPrice الى $names',
            userData: {
              "img": me.profile?.image ?? "",
              "bu": me.bubble ?? "",
              "buId": me.bubbleId.toString(),
              "sL": me.level?.senderImage ?? "",
              "rL": me.level?.receiverImage ?? "",
              "v": me.vip1?.img1 ?? "",
              "c": me.vip1?.colorName ?? "",
              "aI": (di<UserBadgesBloc>().state.myBadge ?? [])
                  .map((b) => EndPoints.getImage(b.image))
                  .toList(),
              "bT": (di<GetUserBadgesBloc>().state.userBadge?.top ?? [])
                  .map((b) => EndPoints.getImage(b.image))
                  .toList(),
              "sI": (me.specialId != null && me.specialId != 0)
                  ? (me.specialIdImage ?? "")
                  : "",
              "giftImage": event.giftData?.img ?? "",
              "giftName": event.giftData?.name ?? "",
              'type': 'message',
            },
          );
        }
        emit(LiveSendGiftSuccess(success.message));
      },
    );
  }
}
