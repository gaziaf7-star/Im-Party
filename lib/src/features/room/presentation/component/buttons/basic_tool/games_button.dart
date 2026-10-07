import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../../../core/index.dart';

class GamesButton extends StatelessWidget {
  final EnterRoomModel roomData;
  const GamesButton({
    required this.roomData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Defense-in-depth: hide the icon even if a future caller forgets to gate
    // it. The authoritative decision is delivered by the server.
    if (!GamesAccess.canPlay) return const SizedBox.shrink();
    return InkWell(
      onTap: () {
        if (!GamesAccess.canPlay) {
          Methods.showToast(
            context,
            message: StringManager.gamesNotAvailableForYou.tr(),
            isError: true,
          );
          return;
        }
        if (HomePage.isConnectToInternet == true) {
          final navContext = SafeNavigator.context;
          if (navContext == null) return;
          bottomDailog(
            context: navContext,
            widget: GamesView(
              roomId: roomData.id.toString(),
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
      child: Container(
        padding: context.paddingAll(7),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.white.withValues(alpha: (0.2)),
        ),
        child: Image.asset(
          AssetsManager.gameIconRank,
          width: 25.w,
          height: 30.h,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
