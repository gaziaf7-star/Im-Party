import 'package:general/src/features/home/domain/entities/carousel_entity.dart';
import '../../../../../../core/index.dart';
import '../../../../domain/entities/room_entity.dart';

/// In-app destinations a `route` banner may point at.
///
/// Keys are what the panel puts in the carousel's `url`, optionally with a tab
/// index after a colon — `rank:1` opens the ranking screen on its second tab.
/// Only these keys resolve; anything else is ignored.
const Map<String, String> _routeTargets = {
  'rank': Routes.rankScreen,
  'giftrank': Routes.giftRankScreen,
  'cprank': Routes.cpRank,
  'familyrank': Routes.familyRankPage,
  'recharge': Routes.rechargeCoinsScreen,
  'coins': Routes.coinsPage,
  'diamonds': Routes.rechargeDiamondPage,
};

/// What a banner does when it is tapped.
///
/// Every panel-managed banner slot on the home page — the wide top banner, the
/// two cards under it, and any banner placed inside the room list — is a CTA
/// carrying the same four kinds of action, so the behaviour lives here once
/// instead of being copied into each widget:
///
///   normal  inert artwork
///   room    open that room
///   link    open the url; WhatsApp links hand off to the app
///   event   open the url with token/lang/base_url/bucket_name appended, which
///           is what the web event pages expect to authenticate the viewer
///   route   open a SCREEN INSIDE the app, named in `url` — see [_routeTargets].
///           The cards under the home banner are this kind: a "top rank" card
///           opens the ranking screen, a "top recharge" card opens recharge.
///           A webview link cannot do that, and hardcoding it per widget would
///           mean the panel could not change where a card points.
Future<void> handleCarouselTap(BuildContext context, CarouselEntity item) async {
  switch (item.type) {
    case 'normal':
      break;

    case 'route':
      // Whitelisted so a typo in the panel can never navigate somewhere
      // unexpected — an unknown key simply does nothing.
      final raw = (item.url ?? '').trim().toLowerCase();
      if (raw.isEmpty) break;

      final parts = raw.split(':');
      final key = parts.first;
      final arg = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

      final target = _routeTargets[key];
      if (target == null) break;

      Navigator.pushNamed(context, target, arguments: arg);
      break;

    case 'room':
      di<RoomStateManager>().navigateToRoom(
        RoomEntryRequest(
          context: context,
          roomData: RoomEntity(
            passwordStatus: item.myRoomData?.passwordStatus,
            ownerId: item.ownerId,
            id: item.myRoomData?.id ?? 0,
            name: item.myRoomData?.name ?? "",
            cover: item.myRoomData?.cover ?? "",
            roomBackground: item.myRoomData?.background ?? "",
            mode: item.myRoomData?.toString() ?? '',
            uuidOwnerRoom: item.myRoomData?.ownerUuid ?? "",
            giftPrice: item.myRoomData?.giftPrice ?? "",
          ),
          isLive: false,
        ),
      );
      break;

    case 'link':
      final url = item.url ?? "";
      if (url.isEmpty) break;
      if (url.contains("wa.me") || url.contains("whatsapp.com")) {
        Methods().whatsAppLink(context, url);
      } else if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.webViewEvents,
          arguments: {'url': url, 'type': 'events'},
        );
      }
      break;

    case 'event':
      final raw = item.url;
      if (!context.mounted || raw == null || raw.isEmpty) break;

      final token = Methods.getUserToken();
      final lang = HiveManager().getData<String>(
            KeysManager.USER_BOX,
            KeysManager.LANG_CODE_KEY,
          ) ??
          "en";

      final original = Uri.parse(raw);
      final params = Map<String, String?>.from(original.queryParameters)
        ..putIfAbsent('token', () => token)
        ..putIfAbsent('lang', () => lang)
        ..putIfAbsent('base_url', () => EndPoints.baseURL)
        ..putIfAbsent('bucket_name', () => EndPoints.storageURL);

      Navigator.pushNamed(
        context,
        Routes.webViewEvents,
        arguments: {
          'url': original.replace(queryParameters: params).toString(),
          'type': 'events',
        },
      );
      break;

    default:
      // An unknown type from the panel behaves like a plain link if it has one.
      final url = item.url ?? "";
      if (url.isNotEmpty && context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.webViewEvents,
          arguments: {'url': url, 'type': 'events'},
        );
      }
  }
}
