import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/manager/manager_lucky_gift_bannaer_for_reciver/lucky_gift_banner_for_reciver_event.dart';
import 'package:general/src/features/room/presentation/manager/manager_lucky_gift_bannaer_for_reciver/lucky_gift_banner_for_reciver_state.dart';

class LuckyGiftBannerForReciverBloc extends Bloc<
    BaseLuckyGiftBannerForReciverEvent, LuckyGiftBannerForReciverState> {
  int giftNum = 0;
  int totalWin = 0;
  int isFrist = 0;
  String senderName = "";
  String giftImage = "";

  LuckyGiftBannerForReciverBloc() : super(LuckyGiftBannerForReciverInitial()) {
    on<LuckyGiftBannerForReciverEvent>((event, emit) {
      isFrist++;
      if (senderName != "" && senderName != event.senderName) {
        giftNum = 0;
        totalWin = 0;
        isFrist = 1;
      } else if (giftImage != event.giftImage && isFrist != 1) {
        giftNum = 0;
      }
      giftNum =
          (giftNum + event.giftNum) == 0 ? 1 : (giftNum + event.giftNum);
      totalWin = totalWin + event.totalWin;
      emit(LuckyGiftBannerForReciverSucssesState(
          giftNum: giftNum,
          giftImage: event.giftImage,
          receiverName: event.receiverName,
          isFirst: isFrist,
          senderImg: event.senderImg,
          totalWin: totalWin,
          senderName: event.senderName));
      senderName = event.senderName;
      giftImage = event.giftImage;
    });

    on<EndLuckyGiftBannerForReciverEvent>((event, emit) {
      emit(LuckyGiftBannerForReciverInitial());

      isFrist = 0;
      giftNum = 0;
      totalWin = 0;
      senderName = "";
      giftImage = "";
    });
  }
}
