import 'package:general/src/features/games/domain/entities/game_entity.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/room/presentation/component/games/leader_cc_game_web_view_screen.dart';
import 'package:general/src/features/room/presentation/manager/open_game_manager/open_game_bloc.dart';
import 'package:general/src/features/room/presentation/manager/open_game_manager/open_game_event.dart';
import 'game_room_card_item.dart';

/// Renders the "outer" games grid and centralizes the open-game flow
/// (OpenGameBloc + Leader CC web-view routing).
///
/// Shared between the dedicated Games page and the Discover tab so the launch
/// logic lives in exactly one place. Visibility is gated server-side via
/// [GamesAccess.canPlay] (`game_available`), never recomputed on the client.
class GamesGridWidget extends StatelessWidget {
  const GamesGridWidget({
    super.key,
    required this.bloc,
    this.shrinkWrap = false,
    this.physics,
    this.maxItems,
  });

  final ExploreBloc bloc;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  /// Caps the number of cards rendered (e.g. a compact preview inside Discover).
  /// Null shows the full list.
  final int? maxItems;

  static void openGame(BuildContext context, GameDataEntity game) {
    di<OpenGameBloc>().add(OpenGameEvent(id: game.id ?? -1));

    if (game.type == 3) {
      final gameURL = game.url;
      final String uid = '${MyDataModel.getInstance().id}';
      final String token = Methods.getUserToken();
      final lang = Methods.getLang();

      const langMap = {
        'en': 'en-US',
        'ar': 'ar-SA',
        'tr': 'tr-TR',
        'hi': 'hi-IN',
        'ur': 'ur-PK',
      };

      final String langCode = langMap[lang] ?? 'en-US';
      final String roomId = '${MyDataModel.getInstance().myRoomData?.id}';
      final String url =
          '$gameURL&uid=$uid&token=$token&roomid=$roomId&lang=$langCode';

      if (gameURL == null || gameURL.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderCCGameWebViewScreen(
            gameUrl: url,
            screenMode: "full",
          ),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GameDataEntity> games = [
      ...bloc.state.outerGames?.fullGames ?? [],
    ];

    final int itemCount = maxItems != null && games.length > maxItems!
        ? maxItems!
        : games.length;

    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: context.paddingZero(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final game = games[index];
        return InkWell(
          onTap: () => openGame(context, game),
          child: GameRoomCardItem(
            title: game.name ?? '',
            img: game.image ?? '',
          ),
        );
      },
    );
  }
}
