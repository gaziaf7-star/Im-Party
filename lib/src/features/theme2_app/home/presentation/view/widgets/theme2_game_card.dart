import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/games/domain/entities/game_entity.dart';
import 'package:general/src/features/room/presentation/component/games/leader_cc_game_web_view_screen.dart';
import 'package:general/src/features/room/presentation/manager/open_game_manager/open_game_bloc.dart';
import 'package:general/src/features/room/presentation/manager/open_game_manager/open_game_event.dart';

class Theme2GameCard extends StatelessWidget {
  final GameDataEntity game;
  final int colorIndex;

  const Theme2GameCard({
    super.key,
    required this.game,
    required this.colorIndex,
  });

  static const List<Color> _bgColors = [
    ColorManager.theme2GameCardBg2,
    ColorManager.theme2GameCardBg1,
    ColorManager.theme2GameCardBg3,
    ColorManager.theme2GameCardBg4,
    ColorManager.theme2GameCardBg1,
    ColorManager.theme2GameCardBg2,
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = _bgColors[colorIndex % _bgColors.length];

    return GestureDetector(
      onTap: () => _onGameTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.8),
          borderRadius: 12.radius,
        ),
        padding: context.paddingSymmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // Game image
            ClipRRect(
              borderRadius: 8.radius,
              child: ImageViewWidget(
                url: game.image ?? '',
                width: 40.w,
                height: 40.h,
                boxFit: BoxFit.cover,
              ),
            ),
            10.wBox,
            // Game info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name ?? '',
                    style: TextStyle(
                      color: ColorManager.theme2TextPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        '${game.high ?? 0}',
                        style: TextStyle(
                          color: ColorManager.theme2TextPrimary
                              .withValues(alpha: 0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                      4.wBox,
                      Icon(
                        Icons.person,
                        color: ColorManager.theme2TextPrimary
                            .withValues(alpha: 0.7),
                        size: 14.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onGameTap(BuildContext context) {
    di<OpenGameBloc>().add(OpenGameEvent(id: game.id ?? -1));
    if (game.type == 3) {
      final gameURL = game.url;
      String uid = '${MyDataModel.getInstance().id}';
      String token = Methods.getUserToken();
      final lang = Methods.getLang();
      final langMap = {
        'en': 'en-US',
        'ar': 'ar-SA',
        'tr': 'tr-TR',
        'hi': 'hi-IN',
        'ur': 'ur-PK',
      };
      String langCode = langMap[lang] ?? 'en-US';
      String roomId = '${MyDataModel.getInstance().myRoomData?.id}';
      String url =
          '$gameURL&uid=$uid&token=$token&roomid=$roomId&lang=$langCode';
      if (url.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderCCGameWebViewScreen(
            gameUrl: url,
            screenMode: "full",
          ),
        ),
      );
    }
  }
}
