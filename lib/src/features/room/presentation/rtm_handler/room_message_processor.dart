import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/room.dart';

import 'handlers/game_message_handler.dart';
import 'handlers/gift_message_handler.dart';
import 'handlers/media_message_handler.dart';
import 'handlers/pk_message_handler.dart';
import 'handlers/room_state_message_handler.dart';
import 'handlers/user_message_handler.dart';

/// Message categories for routing to the correct handler.
enum MessageCategory {
  gift,
  roomState,
  user,
  pk,
  media,
  game,
}

/// A parsed RTM message with its category pre-determined.
class CategorizedMessage {
  final MessageCategory category;
  final String messageType;
  final Map<String, dynamic> payload;

  const CategorizedMessage({
    required this.category,
    required this.messageType,
    required this.payload,
  });
}

/// Processes Zego RTM messages in batches aligned to frame boundaries (~16ms).
///
/// Instead of handling each message synchronously on arrival (which can cause
/// frame drops when dozens fire per second), messages are enqueued and
/// processed in bulk once per frame via a periodic timer.
class RoomMessageProcessor {
  final GiftController giftController;
  final String roomId;
  final String userModelId;
  final bool isHost;
  TickerProvider tickerProvider;
  late final GiftMessageHandler _giftHandler;
  late final RoomStateMessageHandler _roomStateHandler;
  late final UserMessageHandler _userHandler;
  late PkMessageHandler _pkHandler;
  late final MediaMessageHandler _mediaHandler;
  late final GameMessageHandler _gameHandler;

  final Queue<_RawMessage> _queue = Queue<_RawMessage>();
  Timer? _batchTimer;
  bool _disposed = false;

  /// Context supplier — set by the screen so handlers can show dialogs.
  BuildContext Function()? contextSupplier;

  RoomMessageProcessor({
    required this.giftController,
    required this.roomId,
    required this.userModelId,
    required this.isHost,
    required this.tickerProvider,
  }) {
    _giftHandler = GiftMessageHandler(
      giftController: giftController,
      userModelId: userModelId,
    );
    _roomStateHandler = RoomStateMessageHandler(
      isHost: isHost,
      roomId: roomId,
    );
    _userHandler = UserMessageHandler(
      userModelId: userModelId,
      roomId: roomId,
    );
    _pkHandler = PkMessageHandler(tickerProvider: tickerProvider);
    _mediaHandler = const MediaMessageHandler();
    _gameHandler = const GameMessageHandler();
  }

  void updateTickerProvider(TickerProvider tp) {
    tickerProvider = tp;
    _pkHandler.tickerProvider = tp;
  }

  /// Enqueue a raw command string for batched processing.
  void onMessage(String command) {
    if (_disposed) return;
    _queue.add(_RawMessage(command));
    // Start the batch timer on demand — only when there are messages to process.
    _batchTimer ??= Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _processBatch(),
    );
  }

  /// Enqueue a pre-parsed data channel message for batched processing.
  /// Used with LiveKit data channel — data arrives already as Map<String, dynamic>.
  void onDataMessage(Map<String, dynamic> data) {
    if (_disposed) return;
    // Re-encode to JSON string so _processBatch can handle it uniformly.
    _queue.add(_RawMessage(jsonEncode(data)));
    // 50ms batching (jo frame-drop mitigation) — matches the legacy onMessage path.
    _batchTimer ??= Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _processBatch(),
    );
  }

  /// Process all queued messages in one batch (called every ~16ms).
  void _processBatch() {
    if (_disposed) {
      _batchTimer?.cancel();
      _batchTimer = null;
      _queue.clear();
      return;
    }
    if (_queue.isEmpty) {
      _batchTimer?.cancel();
      _batchTimer = null;
      return;
    }

    // Drain the queue into a local list so new arrivals during processing
    // are picked up on the next tick.
    final batch = <_RawMessage>[];
    while (_queue.isNotEmpty) {
      batch.add(_queue.removeFirst());
    }

    final context = contextSupplier?.call();

    for (final raw in batch) {
      // Ludo diagnostics: show every frame that mentions ludo, exactly as it
      // arrived, so a wrong envelope on the backend is visible immediately.
      if (kDebugMode && raw.command.contains('ludo')) {
        debugPrint('[LudoRaw] ${raw.command}');
      }
      if (kDebugMode &&
          raw.command.contains('carom') &&
          !raw.command.contains('"type":"aim"')) {
        debugPrint('[CaromRaw] ${raw.command}');
      }
      try {
        var result = jsonDecode(raw.command) as Map<String, dynamic>;

        var content = result[messageContent] as Map<String, dynamic>?;
        if (content == null) {
          // BACKEND envelope: server-published frames arrive as
          // {Action, MessageContent: <map | json-string>} (RoomDataTrait::
          // pushRoomData). The inner value is either the content map itself
          // or a {messageContent: {...}} wrapper (RoomComments et al). These
          // were silently dropped before — only client-published frames
          // (lowercase messageContent) ever got through.
          var mc = result['MessageContent'];
          if (mc is String && mc.isNotEmpty) {
            try {
              mc = jsonDecode(mc);
            } catch (_) {
              mc = null;
            }
          }
          if (mc is Map<String, dynamic>) {
            if (mc[messageContent] is Map<String, dynamic>) {
              result = mc;
              content = mc[messageContent] as Map<String, dynamic>;
            } else if (mc[message] != null) {
              content = mc;
              result = <String, dynamic>{messageContent: mc};
            }
            // The prod backend also pushes its own 'showGifts' frame for
            // every gift (GiftLogService → SendRoomDataJob), while the
            // client still publishes one after API success. Processing both
            // would animate every gift twice — drop the server copy here.
            // Client-published frames never enter this unwrap branch.
            if (content != null && content[message] == showGifts) {
              // The server copy is the ONLY frame carrying the per-receiver
              // `receiver_charisma_totals` (server-authoritative cumulative room
              // charisma per receiver). Charisma is render-only: apply those
              // totals to the seat state here BEFORE the animation copy is
              // dropped. No accumulation/gating — the backend already decided
              // who was credited and the cumulative value.
              _renderCharismaTotals(content);
              continue;
            }
          }
        }
        if (content == null) continue;

        final msg = content[message];
        if (msg == null) {
          // A payload reached us with a messageContent map but no 'message'
          // key — almost always a double-wrapped send site. Log instead of
          // dropping silently so the mismatch is diagnosable.
          if (kDebugMode) log("Dropped data message — no 'message' key: $content");
          continue;
        }

        // Fallback charisma extraction: the branch above only applies
        // `receiver_charisma_totals` for frames that arrived through the
        // capitalized `MessageContent` backend envelope. A `showGifts` frame
        // that instead reaches here with `messageContent` already at the top
        // level (e.g. the LiveKit data-channel path via onDataMessage) used
        // to skip charisma entirely — the badge stayed seeded at its
        // room-entry value and never updated on a real gift. Harmless no-op
        // for frames without the field (client-published animation-only
        // frames included).
        if (msg == showGifts) {
          _renderCharismaTotals(content);
        }

        final category = _categorize(msg);
        if (category == null) continue;

        final categorized = CategorizedMessage(
          category: category,
          messageType: msg,
          payload: result,
        );

        _dispatch(categorized, context);
      } catch (e) {
        if (kDebugMode) log("Error parsing command: $e");
      }
    }
  }

  /// Determine which handler should process a message.
  static MessageCategory? _categorize(String msg) {
    switch (msg) {
      // Gift
      case showGifts:
      case "showBanner":
      case "win.lucky.gift.event":
      case "yellowBanner":
      case LuckyGiftController.endLuckyGiftforReciver:
      case LuckyGiftController.showLuckyGiftAnimation:
      case "lucky_gift_winner":
      case "play_lucky_gift_winner_sound":
      // Live tap-hearts (lossy peer pulses + the backend's official total).
      case "live_tap_pulse":
      case "live_taps_total":
      // Mid-stream broadcast meta edit (name/intro/cover).
      case "live_meta_updated":
        return MessageCategory.gift;

      // Room state
      case roomModeKey:
      case changeBackground:
      case removeChatKey:
      case "updateAdmins":
      case "LRC":
      case "isCommentsClosed":
      case "roomPassword":
      case "lock_seat":
      case "banRoom":
      case "deletedRoom":
        return MessageCategory.roomState;

      // User
      case userEntro:
      case "unableToUPMicrophone":
      case "unableToEnterRoom":
      case "kickUserfromMic":
      case kicKout:
      case "banDevice":
      case "kickVisitorOut":
      case "banAdmin":
      case "cpLovelyZego":
        return MessageCategory.user;

      // PK
      case PkController.showPk:
      case PkController.startPk:
      case PkController.hidePk:
      case PkController.updatePk:
      case PkController.closePk:
      case startCharisma:
      case closeCharisma:
      case updateCharisma:
        return MessageCategory.pk;

      // Media
      case closeVideo:
      case "youtube_url":
      case "stopVideo":
      case "playVideo":
      case "playVideoForOneUser":
      case "endVideo":
      case "destroyMusic":
      case "controllMusic":
      case "musicSync":
      case "playMusicForOneUser":
        return MessageCategory.media;

      // Emoji
      case EmojieController.showEmojie:
        return MessageCategory.user;

      // Game
      case "ludo_event":
      case "carom_event":
      case showLuckyBoxKey:
      case hideLuckyBoxKey:
      case winnerLuckyBoxKey:
      case "bannerSuperBox":
      case "roomBoomStarted":
      case "roomBoomEnded":
      case "end_room_boom":
      // Every frame that is not listed here is dropped before any handler
      // runs, so the progress case in GameMessageHandler was unreachable and
      // the meter never moved between level changes.
      case "roomBoomProgress":
        return MessageCategory.game;

      default:
        return null;
    }
  }

  /// Route a categorized message to the correct handler.
  void _dispatch(CategorizedMessage msg, BuildContext? context) {
    switch (msg.category) {
      case MessageCategory.gift:
        _giftHandler.handle(msg);
        break;
      case MessageCategory.roomState:
        _roomStateHandler.handle(msg, context);
        break;
      case MessageCategory.user:
        _userHandler.handle(msg, context);
        break;
      case MessageCategory.pk:
        _pkHandler.handle(msg, context);
        break;
      case MessageCategory.media:
        _mediaHandler.handle(msg, context);
        break;
      case MessageCategory.game:
        _gameHandler.handle(msg, context);
        break;
    }
  }

  /// Applies room charisma from a backend gift frame. Prefers the
  /// server-authoritative `receiver_charisma_totals` map ({receiverId:
  /// total}) when present — every receiver in the map is rendered as-is, no
  /// accumulation/gate/dedup, since the backend already owns the per-room
  /// store and decided who was credited.
  ///
  /// This build's actual `showGifts` payload never carries that map, though
  /// (confirmed from a live capture: `{message: showGifts, receiver_id: [16],
  /// ..., userGiftTP: 20000}`, no `receiver_charisma_totals` key at all) — it
  /// ships `receiver_id` (the credited users) plus `userGiftTP`, the PER-GIFT
  /// value, the same field the live-room stage-touch counter already
  /// accumulates client-side (see GiftMessageHandler/addGuestStageTouches).
  /// So when the map is absent, fall back to adding `userGiftTP` onto each
  /// receiver's current badge total instead of leaving it frozen.
  void _renderCharismaTotals(Map<String, dynamic> content) {
    final map = content['receiver_charisma_totals'];
    Methods.printLog(
      '💜 [CHARISMA] _renderCharismaTotals called, '
      'has receiver_charisma_totals map=${map is Map}, '
      'receiver_id=${content['receiver_id']}, '
      'userGiftTP=${content['userGiftTP']}',
    );
    if (map is Map) {
      _applyCharismaTotalsMap(map);
      return;
    }
    _accumulateCharismaFromGiftValue(content);
  }

  void _applyCharismaTotalsMap(Map map) {
    final updates = <CharismaModel>[];
    map.forEach((rid, value) {
      final userId = int.tryParse('$rid') ?? 0;
      if (userId <= 0) return;
      final total = (value is num)
          ? value.toInt()
          : int.tryParse('${value ?? ''}') ?? 0;
      if (total < 0) return;
      updates.add(
        CharismaModel(
          userId: userId,
          total: Methods().convertToAbbreviatedString(total),
          position: 0,
          totalValue: total,
        ),
      );
    });
    _emitCharismaUpdates(updates);
  }

  /// Client-side accumulation fallback — see [_renderCharismaTotals].
  void _accumulateCharismaFromGiftValue(Map<String, dynamic> content) {
    final receiverIds = content['receiver_id'];
    if (receiverIds is! List || receiverIds.isEmpty) return;

    final giftValue = (content['userGiftTP'] is num)
        ? (content['userGiftTP'] as num).toInt()
        : int.tryParse('${content['userGiftTP'] ?? ''}') ?? 0;
    if (giftValue <= 0) return;

    final bloc = di<CharismaBloc>();
    if (bloc.isClosed) return;
    final existing = bloc.state.data ?? const <CharismaModel>[];

    final updates = <CharismaModel>[];
    for (final rid in receiverIds) {
      final userId = int.tryParse('$rid') ?? 0;
      if (userId <= 0) continue;
      var currentTotal = 0;
      for (final e in existing) {
        if (e.userId == userId) {
          currentTotal = e.totalValue;
          break;
        }
      }
      final newTotal = currentTotal + giftValue;
      updates.add(
        CharismaModel(
          userId: userId,
          total: Methods().convertToAbbreviatedString(newTotal),
          position: 0,
          totalValue: newTotal,
        ),
      );
    }
    Methods.printLog(
      '💜 [CHARISMA] accumulate fallback built ${updates.length} update(s): '
      '${updates.map((u) => '${u.userId}->${u.totalValue}').join(', ')}',
    );
    _emitCharismaUpdates(updates);
  }

  void _emitCharismaUpdates(List<CharismaModel> updates) {
    if (updates.isEmpty) {
      Methods.printLog('💜 [CHARISMA] no updates to emit (empty list)');
      return;
    }

    // (G) Skip if the charisma bloc was torn down around a room switch — adding
    // to a closed bloc throws, and the frame belongs to the previous room.
    final bloc = di<CharismaBloc>();
    if (bloc.isClosed) {
      Methods.printLog('💜 [CHARISMA] bloc.isClosed=true, dropping update');
      return;
    }
    bloc.add(UpdateCharismaEvent(data: updates));
    Methods.printLog('💜 [CHARISMA] UpdateCharismaEvent dispatched');
  }

  void dispose() {
    _disposed = true;
    _batchTimer?.cancel();
    _batchTimer = null;
    _queue.clear();
  }
}

class _RawMessage {
  final String command;
  const _RawMessage(this.command);
}
