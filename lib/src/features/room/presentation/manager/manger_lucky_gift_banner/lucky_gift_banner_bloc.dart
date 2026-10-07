import 'dart:convert';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_gift_sound_manager.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_event.dart';
import 'package:general/src/features/room/presentation/manager/manger_lucky_gift_banner/lucky_gift_banner_event.dart';
import 'package:general/src/features/room/room.dart';

class LuckyGiftBannerBloc
    extends Bloc<BaseLuckyGiftBannerEvent, LuckyGiftBannerState> {
  final SendLuckyGiftUC sendLuckyGiftUc;
  int giftNum = 0;
  int totalWin = 0;
  int isFrist = 0;

  LuckyGiftBannerPram _data = LuckyGiftBannerPram(
      data: null, giftNum: null, isFirst: null, totalWin: null);
  LuckyGiftBannerBloc({required this.sendLuckyGiftUc})
      : super(LuckyGiftBannerInitial()) {
    on<SendLuckyGiftEvent>(
      (event, emit) async {
        if (_data.data == null) {
          emit(SendLuckyGiftLoadingState());
        } else {
          emit(
            SendLuckyGiftLoadingState(
              giftNum: _data.giftNum,
              data: _data.data,
              totalWin: _data.totalWin,
              isFirst: _data.isFirst,
            ),
          );
        }

        final prevGiftNum = giftNum;
        final prevTotalWin = totalWin;
        final prevGiftImage = _data.data?.giftImage;

        final result = await sendLuckyGiftUc.call(
          GiftParameter(
            id: event.id,
            num: event.num,
            roomId: event.roomId,
            toUid: event.toUid,
            toZego: true,
            count: event.count,
            nonce: event.nonce,
          ),
        );
        result.fold(
          (left) => emit(SendLuckyGiftErrorStateState(
              error: NetworkExceptions.getErrorMessage(left))),
          (right) async {
            isFrist++;
            if (prevGiftImage != right.data?.giftImage) {
              giftNum = 0;
              totalWin = 0;
            } else {
              giftNum = prevGiftNum;
              totalWin = prevTotalWin;
            }

            _data.data = right.data;
            _data.giftNum = giftNum + (right.data?.giftNum ?? 0);
            _data.totalWin = totalWin + (right.data?.totalWin ?? 0);
            _data.isFirst = isFrist;
            giftNum = giftNum + (right.data?.giftNum ?? 0);
            totalWin = totalWin + (right.data?.totalWin ?? 0);
            emit(
              SendLuckyGiftSucssesState(
                data: right.data ?? const LuckyGiftModel(),
                giftNum: giftNum,
                isFirst: isFrist,
                totalWin: totalWin,
              ),
            );

            if (right.data?.winTimes != 0) {
              di<LuckyGiftWinBloc>().add(AddLuckyWinEvent(
                winTimes: right.data?.winTimes ?? 0,
                winnerImage: MyDataModel.getInstance().profile?.image ?? '',
              ));
              if ((right.data?.winTimes ?? 0) >= 50) {
                Map<String, dynamic> roomData = {
                  "action": "lucky_gift_winner",
                  "messageContent": {
                    "message": "lucky_gift_winner",
                    "winTimes": right.data!.winTimes!,
                    "winnerImage":
                        MyDataModel.getInstance().profile?.image ?? '',
                  }
                };
                String map = jsonEncode(roomData);
                sendRoomData(data: jsonDecode(map));
              }
            }

            if ((right.data?.totalWin ?? 0) > 0 &&
                ((right.data?.totalWin ?? 0) >=
                    int.parse(RoomData.instance.room.luckyGiftCoins ?? "0"))) {
              try {
                // Route via the ACTIVE room's chat: in a LIVE room the audio
                // controller is null, so this comment silently vanished while
                // the win sound (unconditional) still played — owner report
                // 2026-06-12. Same routing rule as sendRoomData.
                final winnerUserData = {
                    "type": "gift",
                    "img": MyDataModel.getInstance().profile?.image ?? "",
                    "bu": MyDataModel.getInstance().bubble ?? "",
                    "buId": MyDataModel.getInstance().bubbleId.toString(),
                    "sL": MyDataModel.getInstance().level?.senderImage ?? "",
                    "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
                    "v": MyDataModel.getInstance().vip1?.img1 ?? "",
                    "c": MyDataModel.getInstance().vip1?.colorName ?? "",
                    "senderName": right.data?.senderName ?? "",
                    "giftName": right.data?.giftName ?? "",
                    "winTimes": right.data?.winTimes.toString() ?? "0",
                    "winCoins": right.data?.totalWin.toString() ?? "0",
                };
                if (di<RoomStateManager>().isInVideoRoom) {
                  LiveRoomData.instance.chatController?.sendMessage(
                      "lucky_gift_winner", userData: winnerUserData);
                } else {
                  RoomData.instance.chatController?.sendMessage(
                      "lucky_gift_winner", userData: winnerUserData);
                }

                Map<String, dynamic> roomData = {
                  "action": "play_lucky_gift_winner_sound",
                  "messageContent": {
                    "message": "play_lucky_gift_winner_sound",
                  }
                };
                LuckyGiftSoundManager.instance.tryPlaySound();
                String map = jsonEncode(roomData);
                sendRoomData(data: jsonDecode(map));
              } catch (_) {}
            }
          },
        );
      },
    );

    on<EndBannerEvent>((event, emit) {
      emit(LuckyGiftBannerInitial());
      giftNum = 0;
      totalWin = 0;
      isFrist = 0;
      _data = LuckyGiftBannerPram(
        data: null,
        giftNum: null,
        isFirst: null,
      );
    });
  }
}

class LuckyGiftBannerPram {
  int? giftNum;
  LuckyGiftModel? data;
  int? isFirst;
  int? totalWin;

  LuckyGiftBannerPram({
    this.isFirst,
    this.data,
    this.giftNum,
    this.totalWin,
  });
}
