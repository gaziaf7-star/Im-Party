import 'dart:developer';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/levels/bloc/levels_bloc/levels_bloc.dart';
import 'package:general/src/features/profile/presentation/levels/bloc/levels_bloc/levels_event.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_gift_sound_manager.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_event.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/yallow_banner/controller/controller.dart';
import 'package:general/src/features/room/room.dart';

import '../room_message_processor.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/live_room/presentation/taps/live_taps_controller.dart';

/// Handles gift-related RTM messages: showGifts, lucky gift animations,
/// lucky gift winner banners, and winner sounds.
class GiftMessageHandler {
  final GiftController giftController;
  final String userModelId;

  GiftMessageHandler({
    required this.giftController,
    required this.userModelId,
  });

  /// De-dup window for incoming `showLuckyGiftAnimation` frames. The backend
  /// data-channel can deliver the same lucky-gift frame several times within a
  /// few dozen ms (observed 3× in 76ms), which animated the same gift multiple
  /// times on every receiver. We collapse duplicates by a content signature
  /// within a short window.
  static const Duration _luckyDedupWindow = Duration(milliseconds: 400);
  final Map<String, DateTime> _luckyAnimationSeen = {};
  final Set<String> _normalGiftEventsSeen = {};

  void handle(CategorizedMessage msg) {
    if (RoomData.instance.isExitingRoom) return;
    final result = msg.payload;

    switch (msg.messageType) {
      case showGifts:
        final normalContent = result[messageContent];
        if (normalContent is! Map) return;
        final giftEventId = normalContent['giftEventId']?.toString() ?? '';
        final senderId = normalContent[sendIdKey]?.toString() ?? '';
        // The sender already enqueued the confirmed animation locally. Ignore
        // a transport echo, and collapse only exact replays of the stable
        // per-send event id. Repeated sends have different ids.
        if (senderId == userModelId) return;
        if (giftEventId.isNotEmpty && !_normalGiftEventsSeen.add(giftEventId)) {
          return;
        }
        if (_normalGiftEventsSeen.length > 300) {
          _normalGiftEventsSeen.remove(_normalGiftEventsSeen.first);
        }
      // Credit the gift to the PK bars regardless of the user's gift-effect
      // preference: a viewer who disabled gift animations must still see the
      // correct PK totals. Runs on every client (including the sender, whose
      // own message LiveKit never echoes back) so bars stay in sync without
      // depending on a server `updatePk` broadcast.
        _scorePK(result);

        // Refresh room level when current user's room receives a gift (any sender)
        if (RoomData.instance.room.ownerId.toString() == userModelId) {
          di<LevelBloc>().add(GetUserLevels());
        }

        // Live room: feed the per-stage guest counter (المسّات) on every
        // receiving client (the sender credits itself locally).
        if (di<RoomStateManager>().isInVideoRoom) {
          final receivers = (result[messageContent]["receiver_id"] as List?)
              ?.map((e) => e.toString())
              .toList() ??
              const <String>[];
          final amount =
              int.tryParse('${result[messageContent]["userGiftTP"] ?? 0}') ??
                  0;
          LiveRoomData.instance.addGuestStageTouches(receivers, amount);
        }

        // Always render a successfully delivered room gift.
        //
        // Previously this was gated by roomEffects.showGift. In production
        // that flag is currently false for users, so every receiver silently
        // discarded the animation although the backend charged the sender and
        // broadcast the showGifts event successfully.
        Methods.printLog(
          '🎁 [RTM_GIFT_RECEIVED] forwarding gift to display queue',
        );

        giftController.showGifts(
          result,
          userModelId,
          giftController.loadMp4Gift,
          giftController.loadAnimationGift,
          giftController.loadAlphaMp4,
          RoomData.instance.room.ownerId.toString(),
        );
        break;

    // بانر الهدية الغالية القادم عبر Zego (بدل قناة legacy realtime gift_banner).
    // نفس مسار العرض: enqueueBanner مع تغليف بمفتاح "gift".
      case "showBanner":
        final banner = result[messageContent]['gift'];
        // Show unless the user EXPLICITLY disabled banners (mirror the showGift
        // gate at the top, `!= false`). The out-of-room Centrifugo path
        // (_handleGiftBanner) never gated on showBanner, so the previous
        // `?? false` default dropped the in-room copy for every user who had not
        // toggled it on — and since the in-room de-dup now suppresses the
        // Centrifugo copy, the gift banner was lost entirely. `!= false` shows
        // by default while still honoring an explicit opt-out.
        if (banner is Map &&
            banner.isNotEmpty &&
            banner['num_gift'] != null &&
            (MyDataModel.getInstance().roomEffects?.showBanner != false)) {
          giftController.enqueueBanner(
            {'gift': Map<String, dynamic>.from(banner)},
            'normal',
          );
        }
        break;

      case LuckyGiftController.endLuckyGiftforReciver:
        di<LuckyGiftBannerForReciverBloc>()
            .add(const EndLuckyGiftBannerForReciverEvent());
        di<LuckyGiftAnaimationManagerBloc>()
            .add(const InitLuckyGiftAnaimationManagerEvent());
        break;

      case LuckyGiftController.showLuckyGiftAnimation:
        di<GiftBloc>().add(UpdateRoomGiftsPriceEvent(
            price: result[messageContent]["giftPrice"]));
        final senderId = result[messageContent]["senderId"];
        if (senderId != null && senderId.toString() == userModelId) return;

        final content = result[messageContent] as Map<String, dynamic>;
        final giftNumVal =
            int.tryParse('${content["giftNum"] ?? 0}') ?? 0;
        final giftPriceTVal =
            int.tryParse('${content["giftPriceT"] ?? 0}') ?? 0;
        final totalPkVal =
            int.tryParse('${content["totalPk"] ?? 0}') ?? 0;

        // Drop zero-value frames: a payload with no gifts AND no charge carries
        // nothing to animate (observed as a stray giftNum:0/giftPriceT:0 frame
        // interleaved with the real ones).
        if (giftNumVal == 0 && giftPriceTVal == 0) {
          if (kDebugMode) {
            log('LUCKYFLY: dropped zero-value lucky frame from $senderId');
          }
          return;
        }

        // De-dup repeated frames within a short window. Signature = sender +
        // recipients + the gift's own numbers, so distinct gifts (different
        // count / pk) still animate while exact replays are collapsed.
        final dedupKey =
            '$senderId|${content["receiversId"]}|${content["seatIndex"]}'
            '|$giftNumVal|$giftPriceTVal|$totalPkVal';
        final now = DateTime.now();
        final lastSeen = _luckyAnimationSeen[dedupKey];
        if (lastSeen != null && now.difference(lastSeen) < _luckyDedupWindow) {
          if (kDebugMode) {
            log('LUCKYFLY: dropped duplicate lucky frame key=$dedupKey');
          }
          return;
        }
        _luckyAnimationSeen[dedupKey] = now;
        // Bound the map: evict entries older than the window so it can't grow.
        _luckyAnimationSeen.removeWhere(
                (_, t) => now.difference(t) >= _luckyDedupWindow);

        // Live room: lucky gifts also feed the per-stage guest counter.
        if (di<RoomStateManager>().isInVideoRoom) {
          final luckyReceivers =
              (result[messageContent]["receiversId"] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
                  const <String>[];
          final luckyAmount =
              int.tryParse('${result[messageContent]["giftPriceT"] ?? 0}') ??
                  0;
          LiveRoomData.instance
              .addGuestStageTouches(luckyReceivers, luckyAmount);
        }

        final indexes =
            (result[messageContent]["seatIndex"] as List?)?.cast<int>() ??
                const <int>[];
        final ids = <String>[];
        final selectedIndexes = <int>[];
        // Prefer the broadcast's recipient userIds (paired index-for-index with
        // seatIndex by the sender): resolution is userId-driven (seat-avatar
        // GlobalKey / kit seat map), so a recipient must NOT be dropped just
        // because the local seatAvatarIds mirror misses their index — that
        // collapsed multi-recipient gifts into a single center candy on every
        // receiver's screen.
        final receivers = (result[messageContent]["receiversId"] as List?)
            ?.map((e) => e.toString())
            .toList() ??
            const <String>[];
        if (receivers.isNotEmpty) {
          for (int k = 0; k < receivers.length; k++) {
            if (receivers[k].isEmpty) continue;
            ids.add(receivers[k]);
            selectedIndexes.add(k < indexes.length ? indexes[k] : -1);
          }
        } else {
          // Legacy payloads without receiversId: map seat indexes to the local
          // occupants as before.
          for (final index in indexes) {
            if (RoomScreenState.seatAvatarIds.containsKey(index)) {
              ids.add(RoomScreenState.seatAvatarIds[index] ?? '');
              selectedIndexes.add(index);
            }
          }
        }
        di<LuckyGiftAnaimationManagerBloc>().add(
          LuckyGiftAnaimationManagerEvent(
            index: selectedIndexes,
            ids: ids,
            image: result[messageContent]["giftImage"],
            reciverName: result[messageContent]["reciver"],
            senderName: result[messageContent]["senderName"],
            senderImage: result[messageContent]["senderImage"],
            giftNum: result[messageContent]["giftNum"],
            giftPriceT: result[messageContent]["giftPriceT"],
            totalWin: result[messageContent]["totalWin"],
            totalPk: result[messageContent]["totalPk"],
            fromRtm: true,
          ),
        );
        break;

    // بانر الهدية المحظوظة القادم عبر UTD Stream (نسخة داخل الغرفة).
    // نفس مسار العرض خارج الغرفة: enqueueBanner مع تغليف بمفتاح "lucky".
      case "win.lucky.gift.event":
        giftController.enqueueBanner(result[messageContent], 'lucky');
        break;

    // بانر التعليق الأصفر القادم عبر UTD Stream (نسخة داخل الغرفة).
    // نفس مسار العرض خارج الغرفة: YallowBannerController.
      case "yellowBanner":
        if (YallowBannerController().isShowYallowBanner.value) {
          Future.delayed(const Duration(seconds: 1), () async {
            YallowBannerController().roomData = RoomEntity(
              id: result[messageContent]['room']['id'],
              name: result[messageContent]['room']['name'],
              cover: result[messageContent]['room']['cover'],
              ownerId: result[messageContent]['room']['owner']['id'],
              uuidOwnerRoom: result[messageContent]['room']['owner']['uuid'],
              roomBackground: result[messageContent]['room']['background'],
              mode: result[messageContent]['room']['mode'].toString(),
              giftPrice: result[messageContent]['room']['gift_price'].toString(),
              passwordStatus: result[messageContent]['ps'],
              roomType: result[messageContent]['room_type'],
            );
            YallowBannerController().showYallowBannerAnimation(
              senderId: result[messageContent]['uId'],
              message: result[messageContent]['umsg'],
              room: YallowBannerController().roomData,
            );
          });
        } else {
          YallowBannerController().roomData = RoomEntity(
            id: result[messageContent]['room']['id'],
            name: result[messageContent]['room']['name'],
            cover: result[messageContent]['room']['cover'],
            ownerId: result[messageContent]['room']['owner']['id'],
            uuidOwnerRoom: result[messageContent]['room']['owner']['uuid'],
            roomBackground: result[messageContent]['room']['background'],
            mode: result[messageContent]['room']['mode'].toString(),
            giftPrice: result[messageContent]['room']['gift_price'].toString(),
            passwordStatus: result[messageContent]['ps'],
            roomType: result[messageContent]['room_type'],
          );
          YallowBannerController().showYallowBannerAnimation(
            senderId: result[messageContent]['uId'],
            message: result[messageContent]['umsg'],
            room: YallowBannerController().roomData,
          );
        }
        break;

      case "lucky_gift_winner":
        di<LuckyGiftWinBloc>().add(AddLuckyWinEvent(
          winTimes: result[messageContent]['winTimes'],
          winnerImage: result[messageContent]['winnerImage'],
        ));
        break;

      case "play_lucky_gift_winner_sound":
        LuckyGiftSoundManager.instance.tryPlaySound();
        break;

    // ── Live tap-hearts (التكبيس) ──
    // Peer pulse (lossy): someone else's tap burst — bump the shared
    // estimate + render a few hearts. The sender renders its own locally.
      case "live_tap_pulse":
        if (di<RoomStateManager>().isInVideoRoom) {
          final sender = result[messageContent]['s']?.toString() ?? '';
          if (sender != userModelId) {
            LiveTapsController.instance.onRemotePulse(
                int.tryParse('${result[messageContent]['c'] ?? 0}') ?? 0);
          }
        }
        break;

    // Backend's official total: everyone snaps to the same number.
      case "live_taps_total":
        if (di<RoomStateManager>().isInVideoRoom) {
          LiveTapsController.instance.onOfficialTotal(
              int.tryParse('${result[messageContent]['total'] ?? 0}') ?? 0);
        }
        break;

    // Host edited the broadcast's name/intro/cover mid-stream (the live
    // settings sheet): apply to the local room model and poke the
    // participants stream so the header/details sheet rebuild.
      case "live_meta_updated":
        if (di<RoomStateManager>().isInVideoRoom) {
          final content = result[messageContent];
          LiveRoomData.instance.roomOrNull?.copyWith(
            roomName: content['n']?.toString(),
            roomIntro: content['i']?.toString(),
            roomCover: content['c']?.toString(),
          );
          LiveRoomData.instance.liveController?.refreshParticipants();
        }
        break;
    }
  }

  /// Credits a `showGifts` payload to the PK bars when a PK is running.
  /// `receiver_id` is the list of users that received the gift and `userGiftTP`
  /// (price × quantity) is the value credited to each of them.
  void _scorePK(Map<String, dynamic> result) {
    if (!PkController.isPK.value) return;
    final content = result[messageContent];
    if (content is! Map) return;

    final giftValue = (content['userGiftTP'] as num?)?.toInt() ?? 0;
    if (giftValue <= 0) return;

    final rawReceivers = content[receiverIdKey];
    if (rawReceivers is! List) return;
    final receiverIds =
    rawReceivers.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();

    addGiftToPK(receiverIds, giftValue);
  }
}
