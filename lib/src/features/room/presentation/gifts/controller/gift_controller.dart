import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/wabbles_model.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_event.dart';
import 'package:general/src/features/room/presentation/gifts/manager/gift_queue_manager.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';

class GiftController {
  static final GiftController _instance = GiftController._internal();

  GiftController._internal();

  factory GiftController() => _instance;

  final GiftQueueManager _queueManager = GiftQueueManager();

  /// Backward-compatible access for cache widgets that still read/mutate
  /// `GiftController().normalGiftsToShow`.
  GiftQueueListProxy get normalGiftsToShow => _queueManager.normalGiftsToShow;

  /// Legacy helper — kept for callers that update showTime by uniqueId.
  void updateGiftShowTime(String uniqueId) {
    _queueManager.updateFirstShowTime();
  }

  Map<String, dynamic> userIntroData = {
    'user_name_intro': '',
    'user_image_intro': '',
    'user_vip_intro': '',
    'wappelImage': '',
    'wappelType': '',
    'wappelKeyName': {},
  };

  List<Map<String, dynamic>> userBannerData = [];

  /// True while a banner is currently mid-animation. The queue is strictly
  /// sequential: ONLY the banner widget's teardown (whenComplete / skip) clears
  /// this and pulls the next entry. enqueueBanner never re-emits the head while
  /// a banner is showing — re-emitting a fresh `_ts` copy to the keyless host
  /// made Flutter reuse the same State (no initState/animation), so a second
  /// rapid win never ran its own cycle and two wins collapsed into one visible
  /// banner (and an in-room banner could starve to nothing). See app.dart keys.
  bool _isShowing = false;

  /// Monotonic per-banner sequence id. Stamped on every enqueued banner and
  /// used as the host widget's ValueKey so each banner — even two wins with the
  /// same coin value — gets a distinct widget identity and its own State.
  int _bannerSeq = 0;

  // ─── Banner management ────────────────────────────────────────────────

  void enqueueBanner(Map<String, dynamic> banner, String type) {
    banner['bannerType'] = type;
    // Unique identity per enqueued banner so two distinct wins never merge,
    // regardless of equal coin value or sort ties.
    banner['_seq'] = ++_bannerSeq;
    userBannerData.add(banner);

    userBannerData.sort((a, b) {
      final aCoins = _getCoinsValue(a);
      final bCoins = _getCoinsValue(b);
      return bCoins.compareTo(aCoins);
    });

    // Only kick the queue if nothing is animating; otherwise the in-flight
    // banner's teardown will pull this one next. This is what prevents the
    // re-entrant re-emit that starved the keyless host.
    if (!_isShowing) showNextBanner();
  }

  /// Called by the banner widget teardown (whenComplete / skip) after it has
  /// removed the head. Clears the in-flight flag and shows the next banner, or
  /// leaves the queue idle when empty.
  void advanceQueue() {
    _isShowing = false;
    if (userBannerData.isNotEmpty) showNextBanner();
  }

  /// Clears the queue AND the in-flight flag in one step. Call this on room
  /// teardown / background instead of `userBannerData.clear()` alone — a bare
  /// clear that left `_isShowing` true would block every future banner because
  /// enqueueBanner only kicks the queue when nothing is showing.
  void resetBannerQueue() {
    userBannerData.clear();
    _isShowing = false;
    di<ShowBannersBloc>().add(const ShowBannerInAppEvent(bannerData: {}));
  }

  int _getCoinsValue(Map<String, dynamic> banner) {
    final type = banner['bannerType'];
    switch (type) {
      case 'lucky':
        return Methods().convertFromAbbreviatedString(banner['per'].toString());
      case 'game':
        // Matches the real game.win.event payload's `win_coins` field (was
        // `coins`, which that event never actually carries). win_coins
        // arrives as a raw int, not a string -- same fix as the 'lucky'
        // case above.
        return Methods()
            .convertFromAbbreviatedString((banner['win_coins'] ?? 0).toString());
      case 'normal':
        final gift = banner['gift'];
        final numGift = gift is Map ? gift['num_gift'] : banner['num_gift'];
        return Methods()
            .convertFromAbbreviatedString('${numGift ?? 0}');
      default:
        return 0;
    }
  }

  String _getBannerSpeed() {
    return userBannerData.length < 5 ? 'normal' : 'fast';
  }

  void showNextBanner() {
    if (userBannerData.isEmpty) {
      _isShowing = false;
      return;
    }
    _isShowing = true;
    final banner = userBannerData[0];
    banner['speed'] = _getBannerSpeed();
    // Copy the map and stamp a unique key so the Equatable state in
    // ShowBannersBloc always differs from the previous emission —
    // even if two identical gifts arrive back-to-back.
    final copy = Map<String, dynamic>.from(banner);
    copy['_ts'] = DateTime.now().microsecondsSinceEpoch;
    di<ShowBannersBloc>().add(ShowBannerInAppEvent(bannerData: copy));
  }

  // ─── Gift animation loading ───────────────────────────────────────────
  // These are still called by cache widgets when advancing the queue.
  // They now emit only the ShowGiftsEvent (price update is handled by
  // the composite event emitted when the gift was enqueued).

  Future<void> loadMp4Gift({required GiftDataEntity giftData}) async {
    Methods.printLog(
      '🎁 [GiftDisplay] load MP4 => ${giftData.giftImg}',
    );

    di<GiftBloc>().add(
      ShowGiftsEvent(
        pathGift: giftData.giftImg,
        isShowGift: true,
        isFamousGift: giftData.isFamousGift,
        giftType: ShowGiftType.mp4,
      ),
    );
  }

  Future<void> loadAlphaMp4({required GiftDataEntity giftData}) async {
    Methods.printLog(
      '🎁 [GiftDisplay] load Alpha => ${giftData.giftImg}',
    );

    di<AlphaGiftManagerBloc>().add(
      ShowAlphaGift(
        imgFile: giftData.giftImg,
        isFamousGift: giftData.isFamousGift,
      ),
    );
  }

  Future<void> loadAnimationGift(GiftDataEntity giftData) async {
    final displayType =
    giftData.type == 'svga'
        ? ShowGiftType.svga
        : ShowGiftType.vap;

    Methods.printLog(
      '🎁 [GiftDisplay] load animation '
          'type=${giftData.type} path=${giftData.giftImg}',
    );

    di<GiftBloc>().add(
      ShowGiftsEvent(
        pathGift: giftData.giftImg,
        isShowGift: true,
        isFamousGift: giftData.isFamousGift,
        giftType: displayType,
      ),
    );
  }

  // ─── User entry animation ─────────────────────────────────────────────

  userEntro(
      Map<String, dynamic> result,
      Map<String, dynamic> userIntroData,
      ) async {
    WabblesModel? wabble = Methods().getUserWabble(
      result[messageContent]['wabbleId'],
    );

    wabble ??= Methods().getUserWabble(0);

    userIntroData['user_name_intro'] = result[messageContent][userName];
    userIntroData['user_image_intro'] = result[messageContent][userImge];
    userIntroData['wappelImage'] = wabble?.image ?? '';
    userIntroData['wappelType'] = wabble?.imageType ?? '';
    userIntroData['wappelKeyName'] = wabble?.keyJson ?? {};

    final wappelMap = {
      'user_name_intro': result[messageContent][userName],
      'user_image_intro': result[messageContent][userImge],
      'wappelImage': wabble?.image ?? '',
      'wappelType': wabble?.imageType ?? '',
      'wappelKeyName': wabble?.keyJson ?? {},
    };

    // The backend's own `_type` field for an equipped intro/frame is
    // unreliable for .svga files -- confirmed from a live my-data response
    // reporting `intro_type: "png"` for an `intro: "files/xxx.svga"` path.
    // GiftQueueManager.showGiftType falls back to ShowGiftType.image for any
    // unrecognized type, so a mistyped .svga silently tried to decode as a
    // still image and failed, leaving the entry blank. Trust the file
    // extension over the backend's type string whenever it looks like svga.
    final entroImg = result[messageContent]['entroImg'] ?? '';
    final rawEntroType = result[messageContent]['entroType'] ?? 'image';
    final entroType =
        Methods().isSvgaFile(entroImg) ? 'svga' : rawEntroType;

    final item = GiftQueueItem(
      uniqueId: _queueManager.generateUniqueId(),
      pathGift: entroImg,
      giftType: entroType,
      isIntro: true,
      isShowIntroFullScreen: true,
      wappelData: wappelMap,
    );

    if (_queueManager.isEmpty) {
      ShowEntroWidget.showEntro.value = wappelMap;
      userIntroData['user_vip_intro'] = '${result[messageContent]["userVip"]}';
    }

    _queueManager.enqueue(item);
  }

  // ─── Gift display ─────────────────────────────────────────────────────

  showGifts(
      Map<String, dynamic> result,
      String id,
      Future<void> Function({required GiftDataEntity giftData}) loadMp4Gift,
      Future<void> Function(GiftDataEntity giftData) loadAnimationGift,
      Future<void> Function({required GiftDataEntity giftData}) loadAlphaMp4,
      String roomOwnerId,
      ) async {
    try {
      Methods.printLog('ShowGifts: ShowGifts called with result = $result');

      String sendId = result[messageContent][sendIdKey].toString();

      if (sendId == id) {
        RoomData.instance.myCoins.value = result[messageContent]['coins'];
      }

      final giftType = result[messageContent]['type'].toString();
      final isFamous = result[messageContent]['giftType'] == 'famous';

      // A gift accepted by the backend must always be rendered.
      // Do not suppress it via roomEffects.showGift: the current backend/user
      // state may carry false by default, which previously made every client
      // silently drop the animation even though coins were charged.
      Methods.printLog(
        '🎁 [GiftDisplay] display allowed '
            '(room effect flag ignored for sent gifts)',
      );

      final rawGiftPath =
          result[messageContent]['showGift']?.toString() ?? '';

      final resolvedGiftPath =
      EndPoints.getImage(rawGiftPath);

      Methods.printLog(
        '🎁 [GiftDisplay] type=$giftType '
            'raw=$rawGiftPath '
            'resolved=$resolvedGiftPath',
      );

      if (resolvedGiftPath.trim().isEmpty) {
        Methods.printLog(
          '🚨 [GiftDisplay] skipped: empty gift animation path',
        );
        return;
      }

      final item = GiftQueueItem(
        uniqueId: _queueManager.generateUniqueId(),
        pathGift: resolvedGiftPath,
        isFamousGift: isFamous,
        giftType: giftType,
        roomGiftsPrice:
        result[messageContent][roomGiftsPriceKey]?.toString() ?? '',
      );

      // Enqueue — GiftQueueManager handles priority, concurrency,
      // and emits the composite event when animation starts.
      _queueManager.enqueue(item);
    } catch (e, stack) {
      Methods.printLog('ShowGifts: ERROR in ShowGifts: $e');
      Methods.printLog('ShowGifts: Stack trace:\n$stack');
    }
  }
}
