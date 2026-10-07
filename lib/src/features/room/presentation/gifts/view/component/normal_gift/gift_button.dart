import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

class GiftButton extends StatelessWidget {
  const GiftButton(
      {required this.myDataModel,
        required this.users,
        required this.roomData,
        super.key});

  final MyDataModel myDataModel;
  final List<UTDParticipant> users;
  final EnterRoomModel? roomData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        bottomDailog(
          context: context,
          barrierColor: ColorManager.transparent,
          widget: GiftScreen(
            users: users,
            roomData: roomData!,
            myDataModel: myDataModel,
            isSingleUser: false,
            isAudioRoom: true,
            userId: null,
            userImage: null,
            userName: null,
          ),
        );
      },
      child: ConstantsManager.isTheme1
          ? ShowSVGA(
        svgaAssetPath: AssetsManager.giftIconNew,
        width: 50.w,
        height: 50.h,
        fit: BoxFit.cover,
      )
          : ShowSVGA(
        // Audio room's bottom-bar gift icon -- new asset on request
        // (kept separate from AssetsManager.giftRoom, which the live
        // room bar and the Moment screen still use, so those are
        // untouched). Sized a bit bigger than the other bottom-bar
        // tiles (~39.r diameter) on request, so Gift stands out.
        svgaAssetPath: AssetsManager.giftIconAudio,
        width: 44.w,
        height: 44.h,
      ),
    );
  }
}