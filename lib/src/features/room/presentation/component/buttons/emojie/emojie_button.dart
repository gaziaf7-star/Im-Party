import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/component/buttons/emojie/emojie_widget.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../../../core/index.dart';

class EmoijeButton extends StatelessWidget {
  const EmoijeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (HomePage.isConnectToInternet == true) {
          bottomDailog(
            context: context,
            widget: EmojieWidget(
              userId: MyDataModel.getInstance().id.toString(),
              roomId: RoomData.instance.room.id.toString(),
            ),
          );
        } else {
          Methods.showToast(
            context,
            message: StringManager.pleaseCheckInternet.tr(),
            isError: true,
          );
        }
      },
      child: CircleAvatar(
        // Unified with Chat/Mic/More's tile radius (19.5.r) and icon size
        // (24.sp) so every bottom-bar tile is the same size.
        radius: 19.5.r,
        // Both variants now share the same light-black tile background
        // (was light-white for the non-A variant).
        backgroundColor: Colors.black.withValues(alpha: .1),
        child: Icon(
          Icons.emoji_emotions,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
    );
  }
}