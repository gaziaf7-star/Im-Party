import 'dart:async';
import 'dart:convert';
import 'package:general/src/features/room/room.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/index.dart';

part 'lucky_box_event.dart';
part 'lucky_box_state.dart';

class LuckyBoxBloc extends Bloc<LuckyBoxesEvents, LuckyBoxState> {
  final GetLuckyBoxUC _getBoxUC;
  final SendLuckyBoxUc _sendBoxUC;
  final PickUpLuckyBoxUc _pickupBoxUC;

  LuckyBoxBloc(
    this._getBoxUC,
    this._sendBoxUC,
    this._pickupBoxUC,
  ) : super(const LuckyBoxState()) {
    on<GetLuckyBoxesEvent>(_getBoxes);
    on<SendLuckyBoxEvent>(_sendBox);
    on<PickupLuckyBoxEvent>(_pickUpBox);
    on<SelectLuckyBoxCoins>(_selectLuckyBoxCoins);
    on<SelectLuckyBoxQuantity>(_selectLuckyBoxQuantity);
    on<SelectSuperBoxCoins>(_selectSuperBoxCoins);
    on<ChangeTabBarState>(_changeTabBarState);
    on<ResetPickupLuckyBoxEvent>(_resetPickUpBox);
  }

  Future<void> _getBoxes(
    GetLuckyBoxesEvent event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(state.copyWith(getLuckyBoxReqState: RequestState.loading));

    final result = await _getBoxUC.call();
    result.fold(
      (left) {
        emit(
          state.copyWith(
            getLuckyBoxMessage: NetworkExceptions.getErrorMessage(left),
            getLuckyBoxReqState: RequestState.error,
          ),
        );
      },
      (r) => emit(
        state.copyWith(
          getLuckyBoxMessage: r.message,
          getLuckyBoxReqState: RequestState.loaded,
          boxData: r.data,
          luckyBoxItem: (r.data?.normalBox ?? []).isNotEmpty
              ? r.data?.normalBox[0].coins.toString()
              : '',
          luckyBoxQuantity: (r.data?.normalBox ?? []).isNotEmpty
              ? (r.data?.normalBox[0].userNum ?? []).isNotEmpty
                  ? r.data?.normalBox[0].userNum[0].toString()
                  : ''
              : '',
          superBoxCoins: (r.data?.superBox ?? []).isNotEmpty
              ? r.data?.superBox[0].coins.toString()
              : '',
          luckyBoxList: (r.data?.normalBox ?? []).isNotEmpty
              ? r.data?.normalBox[0].userNum
              : [],
        ),
      ),
    );
  }

  Future<void> _sendBox(
    SendLuckyBoxEvent event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(state.copyWith(sendLuckyBoxReqState: RequestState.loading));
    final result = await _sendBoxUC.call(
      LuckyBoxParam(
        boxId: event.boxId,
        roomId: event.roomId,
        quantity: event.quantity,
      ),
    );

    result.fold(
      (l) {
        emit(
          state.copyWith(
            sendLuckyBoxMessage: NetworkExceptions.getErrorMessage(l),
            sendLuckyBoxReqState: RequestState.error,
          ),
        );
        emit(
          state.copyWith(
            sendLuckyBoxReqState: RequestState.idle,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            sendLuckyBoxMessage: r.message,
            sendLuckyBoxReqState: RequestState.loaded,
            sendLuckyBoxEntity: r.data,
          ),
        );

        Map<String, dynamic> mapShowLuckyBox = {
          "messageContent": {
            "message": showLuckyBoxKey,
            boxIDKey: r.data?.id,
            boxCoinsKey: r.data?.coins,
            "ownerBoxUId": r.data?.user.uuid,
            ownerBoxNameKey: r.data?.user.name,
            "ownerBoxImage": r.data?.user.image,
            boxTypeKey: r.data?.type,
            ownerBoxIdKey: r.data?.user.id,
            // showLuckyBox() (lucky_box_controller.dart) reads these two
            // keys unconditionally -- 'numOfBoxes' has no null fallback and
            // does int.parse(null.toString()) => throws FormatException, so
            // without them the whole RTM handler crashed silently and the
            // banner never got added for ANYONE in the room, sender
            // included. Both were simply missing from this payload.
            "numOfBoxes": r.data?.usersNum,
            "end_time": r.data?.endTime.toIso8601String(),
          }
        };

        String map = jsonEncode(mapShowLuckyBox);
        sendRoomData(data: jsonDecode(map));
        // sendRoomData only reaches OTHER participants -- the realtime
        // channel doesn't echo a client's own broadcast back to itself, so
        // without this the sender never saw their own banner (this is also
        // why it looked broken when testing solo in an empty room: there
        // was nobody else in the room for the broadcast to reach).
        showLuckyBox(jsonDecode(map));

        // The floating in-room icon (above) and the app-wide top banner are
        // two SEPARATE systems. The top banner (ShowLuckyBannerWidget, drawn
        // in app.dart's _buildLuckyBoxBanners) is normally fed by the
        // backend pushing to the realtime "banner:lucky_box" channel, which
        // GetMyDataBloc._handleLuckyBoxBanner listens to and turns into
        // enqueueLuckyBoxBanner(...) calls. That channel never fires for the
        // box you just sent yourself (same self-echo gap as sendRoomData
        // above), so without this call the sender never sees their own top
        // banner even though the backend push is working for everyone else.
        final room = RoomData.instance.room;
        enqueueLuckyBoxBanner({
          "coins": r.data?.coins,
          "ownerBoxUId": r.data?.user.uuid,
          "ownerBoxName": r.data?.user.name,
          "ownerBoxImage": r.data?.user.image,
          "ownerRoomId": room.uuidOwnerRoom,
          "room": {
            "uuid": room.uuidOwnerRoom,
            "id": room.id,
            "room_name": room.roomName,
            "room_cover": room.roomCover,
            "room_background": room.roomBackground,
            "room_mode": room.mode,
            "room_owner_id": room.ownerId,
            "is_password": room.roomPassStatus,
            "room_session": room.giftPrice,
            "room_type": room.streamType,
          },
          "ownerBoxSL": 0,
          "ownerBoxRL": 0,
          "ownerBoxAL": 0,
        });

        emit(
          state.copyWith(
            sendLuckyBoxReqState: RequestState.idle,
          ),
        );
      },
    );
  }

  Future<void> _pickUpBox(
    PickupLuckyBoxEvent event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(state.copyWith(pickUpLuckyBoxReqState: RequestState.loading));
    final result = await _pickupBoxUC.call(event.boxId);

    result.fold(
      (left) {
        emit(state.copyWith(
            pickUpLuckyBoxMessage: NetworkExceptions.getErrorMessage(left),
            pickUpLuckyBoxReqState: RequestState.error));
        emit(
          state.copyWith(
            pickUpLuckyBoxReqState: RequestState.idle,
          ),
        );
      },
      (right) async {
        emit(
          state.copyWith(
            pickUpLuckyBoxMessage: right.message,
            pickUpLuckyBoxReqState: RequestState.loaded,
            pickUpLuckyBoxEntity: right.data,
          ),
        );
        if (right.data!.type == "super") {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('picked_${event.boxId}', true);
        } else {
          if (state.pickUpLuckyBoxEntity?.isWin ?? false) {
            RoomData.instance.chatController?.sendMessage(
              StringManager.winInLuckyBoxMessageKey,
              userData: {
                "coins": state.pickUpLuckyBoxEntity?.coins.toString() ?? '0',
                "img": MyDataModel.getInstance().profile?.image ?? "",
                "bu": MyDataModel.getInstance().bubble ?? "",
                "buId": MyDataModel.getInstance().bubbleId.toString(),
                "sL": MyDataModel.getInstance().level?.senderImage ?? "",
                "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
                "v": MyDataModel.getInstance().vip1?.img1 ?? "",
                "c": MyDataModel.getInstance().vip1?.colorName ?? "",
                'type': 'games',
              },
            );
          }
        }
        hideLuckyBoxFromLocal(event.boxId);
      },
    );
  }

  Future<void> _resetPickUpBox(
    ResetPickupLuckyBoxEvent event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(
      state.copyWith(
        pickUpLuckyBoxReqState: RequestState.idle,
        luckyBoxItem: "",
        luckyBoxQuantity: "",
        superBoxCoins: "",
        indexItemSelectedNormal: 0,
        indexItemSelectedSuper: 0,
        pickUpLuckyBoxEntity: const PickUpLuckyBoxEntity(),
      ),
    );
  }

  Future<void> _selectLuckyBoxCoins(
    SelectLuckyBoxCoins event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(state.copyWith(
        luckyBoxItem: state.boxData?.normalBox[event.index].coins.toString(),
        luckyBoxList: state.boxData?.normalBox[event.index].userNum,
        indexItemSelectedNormal: event.index,
        luckyBoxQuantity:
            state.boxData?.normalBox[event.index].userNum[0].toString()));
  }

  Future<void> _selectLuckyBoxQuantity(
    SelectLuckyBoxQuantity event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(state.copyWith(
        luckyBoxQuantity: state.boxData
            ?.normalBox[state.indexItemSelectedNormal ?? 0].userNum[event.index]
            .toString()));
  }

  Future<void> _selectSuperBoxCoins(
    SelectSuperBoxCoins event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(state.copyWith(
        superBoxCoins: state.boxData?.superBox[event.index].coins.toString(),
        indexItemSelectedSuper: event.index));
  }

  Future<void> _changeTabBarState(
    ChangeTabBarState event,
    Emitter<LuckyBoxState> emit,
  ) async {
    emit(state.copyWith(
      isLuckyBoxTap: event.isLuckyBox,
    ));
  }
}
