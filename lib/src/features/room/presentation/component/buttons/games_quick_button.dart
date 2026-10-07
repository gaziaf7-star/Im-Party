import 'dart:math';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// A single bottom-bar icon that groups the three quick games (lucky number,
/// rock-paper-scissors, dice). Tapping it pops the three game icons stacked
/// vertically just above the bar, so a viewer (not on mic / not owner) can fire
/// a game in one tap without opening the full tools sheet.
class GamesQuickButton extends StatelessWidget {
  const GamesQuickButton({super.key});

  Map<String, dynamic> _baseUserData(String gameType) => {
        StringManager.gameType: gameType,
        "img": MyDataModel.getInstance().profile?.image ?? "",
        "bu": MyDataModel.getInstance().bubble ?? "",
        "buId": MyDataModel.getInstance().bubbleId.toString(),
        "sL": MyDataModel.getInstance().level?.senderImage ?? "",
        "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
        "v": MyDataModel.getInstance().vip1?.img1 ?? "",
        "c": MyDataModel.getInstance().vip1?.colorName ?? "",
        'type': 'games',
      };

  void _sendLuckyNum() => RoomData.instance.chatController?.sendMessage(
        "${Random().nextInt(9)},${Random().nextInt(9)},${Random().nextInt(9)}",
        userData: _baseUserData(StringManager.luckyNumGame),
      );

  void _sendRps() => RoomData.instance.chatController?.sendMessage(
        "${Random().nextInt(3)}",
        userData: _baseUserData(StringManager.rps),
      );

  void _sendDice() => RoomData.instance.chatController?.sendMessage(
        "${Random().nextInt(6)}",
        userData: _baseUserData(StringManager.diceGame),
      );

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorManager.transparent,
      builder: (sheetCtx) {
        Widget tile(String asset, String label, VoidCallback onTap) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(sheetCtx);
              onTap();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: ColorManager.surfaceCardColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(asset, height: 34.h, width: 34.h),
                  12.wBox,
                  TextWidget(
                    label,
                    style:
                        context.bodyMedium.bold.colorExt(ColorManager.textPrimary),
                  ),
                ],
              ),
            ),
          );
        }

        // Stacked vertically (newest game styles on top), aligned above the bar.
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.h, right: 12.w, left: 12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                tile(AssetsManager.number12,
                    StringManager.luckyNumGame.tr(), _sendLuckyNum),
                tile(AssetsManager.rpsGameIcon,
                    StringManager.rpsGameKey.tr(), _sendRps),
                tile(AssetsManager.dices,
                    StringManager.diceGame.tr(), _sendDice),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Image.asset(
        AssetsManager.dices,
        height: 35.h,
        width: 35.h,
        color: ColorManager.white,
      ),
    );
  }
}
