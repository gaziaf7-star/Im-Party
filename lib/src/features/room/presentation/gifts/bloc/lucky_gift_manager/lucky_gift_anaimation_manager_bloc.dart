import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/lucky_log.dart';
import 'package:general/src/features/room/room.dart';

class LuckyGiftAnaimationManagerBloc extends Bloc<
    BaseLuckyGiftAnaimationManagerEvent, LuckyGiftAnaimationManagerState> {
  /// Cache of seat positions keyed by index list string representation.
  /// Supports multiple concurrent senders targeting different seats.
  final Map<String, _CachedSeatPositions> _seatPositionCache = {};

  /// Maximum number of retries to get seat positions
  static const int _maxRetries = 5;

  /// Delay between retries in milliseconds
  static const int _retryDelayMs = 100;

  /// Seat position cache TTL — invalidate after 10 seconds to handle seat changes
  static const Duration _cacheTtl = Duration(seconds: 10);

  // Keyed by indexes AND recipient ids: resolution is now userId-driven, so two
  // different recipient sets can share the same index list (e.g. all -1 when
  // the screen mirror missed) and must not collide in the cache.
  String _cacheKey(List<int> indexes, List<String> ids) =>
      '${indexes.toString()}|${ids.toString()}';

  LuckyGiftAnaimationManagerBloc() : super(LuckyGiftAnimationInitial(null)) {
    on<LuckyGiftAnaimationManagerEvent>((event, emit) async {
      if (isClosed || RoomData.instance.isExitingRoom) return;
      log('🎁 Lucky Gift Animation Event - fromRtm: ${event.fromRtm}, ids: ${event.ids}, indexes: ${event.index}');
      LuckyLog.write('LUCKYFLY: animation event — fromRtm=${event.fromRtm}, '
          'ids=${event.ids}, indexes=${event.index}');

      final key = _cacheKey(event.index, event.ids);
      List<SeatPosition> seatPosition;
      _SeatPositionsResult? resolved;

      final cached = _seatPositionCache[key];
      if (cached != null &&
          DateTime.now().difference(cached.createdAt) < _cacheTtl) {
        seatPosition = cached.positions;
        log('🎯 Using cached seat positions for key: $key');
        LuckyLog.write('LUCKYFLY: using cached seat positions for key=$key '
            '(${seatPosition.length} position(s))');
      } else {
        _seatPositionCache.remove(key);
        resolved = await _getSeatPositionsWithRetry(
          event.index,
          event.ids,
          // Optimistic sender path: seats are already on screen, resolve once
          // (zero animation latency). RTM path keeps the retry loop.
          immediate: event.immediate,
        );
        seatPosition = resolved.positions;
        // Cache ONLY a fully-resolved set (every seat read from a live
        // RenderBox). Caching a partial set or one that contains an approximate
        // fallback would pin the wrong positions for 10s (the seat keys may
        // attach a frame later), so a transient miss must not poison subsequent
        // gifts.
        if (resolved.allExact && seatPosition.isNotEmpty) {
          _seatPositionCache[key] = _CachedSeatPositions(seatPosition);
        }
        log('🎯 Got ${seatPosition.length} seat positions for ${event.index.length} indexes (allExact=${resolved.allExact})');
        LuckyLog.write('LUCKYFLY: got ${seatPosition.length} seat position(s) '
            'for ${event.index.length} indexes (allExact=${resolved.allExact}, '
            'sources=${resolved.sourceSummary})');
      }

      // seatPosition is now guaranteed non-empty (geometry/fallback targets fill
      // any unresolved seats), so the animation is never silently dropped.
      _emitAnimation(
          emit: emit, image: event.image, seatPosition: seatPosition);
      log('✅ Lucky gift animation emitted successfully');
      LuckyLog.write('LUCKYFLY: animation emitted successfully '
          '(${seatPosition.length} position(s))');

      // fromRtm == false → sender dispatched locally (re-broadcast to room)
      // fromRtm == true  → received via RTM (show receiver banner, no re-broadcast)
      // fromRtm == null  → sender sees their own animation (no re-broadcast, no receiver banner)
      if (event.fromRtm == false) {
        _rebroadcast(
          image: event.image,
          index: event.index,
          ids: event.ids,
          reciverName: event.reciverName,
          senderName: event.senderName,
          senderImage: event.senderImage,
          giftPrice: event.giftPrice,
          giftNum: event.giftNum,
          giftPriceT: event.giftPriceT,
          totalWin: event.totalWin,
          totalPk: event.totalPk,
        );
      }
      if (event.fromRtm == true) {
        di<LuckyGiftBannerForReciverBloc>().add(LuckyGiftBannerForReciverEvent(
            giftImage: event.image,
            receiverName: event.reciverName,
            senderName: event.senderName,
            giftNum: event.giftNum ?? 1,
            totalWin: event.totalWin,
            senderImg: event.senderImage));
      }
    });

    on<RebroadcastLuckyGiftEvent>((event, emit) {
      if (isClosed || RoomData.instance.isExitingRoom) return;
      // Other clients need the authoritative result (giftNum/totalWin/totalPk);
      // the sender already animated optimistically per-tap, so this path NEVER
      // touches the local seat animation — it only forwards over RTM.
      _rebroadcast(
        image: event.image,
        index: event.index,
        ids: event.ids,
        reciverName: event.reciverName,
        senderName: event.senderName,
        senderImage: event.senderImage,
        giftPrice: event.giftPrice,
        giftNum: event.giftNum,
        giftPriceT: event.giftPriceT,
        totalWin: event.totalWin,
        totalPk: event.totalPk,
      );
    });

    on<InitLuckyGiftAnaimationManagerEvent>((event, emit) {
      _seatPositionCache.clear();
      if (state.data != null) {
        state.data = [];
      }
      emit(LuckyGiftAnimationInitial(null));
    });

    on<RemoveCompletedLuckyGiftAnimationEvent>((event, emit) {
      if (state.data != null) {
        final updatedList = List<LuckyGiftSeatAnimation>.from(state.data!)
          ..remove(event.animation);
        if (updatedList.isEmpty) {
          emit(LuckyGiftAnimationInitial(null));
        } else {
          emit(LuckyGiftAnimationSucssesState(data: updatedList));
        }
      }
    });
  }

  /// Forward a lucky-gift result to every other room member over RTM. The
  /// payload mirrors the sender's known state plus the backend's win data; it
  /// runs AFTER any local animation so it can never block it, and is guarded so
  /// a serialization/transport throw can't escape into the global zone guard.
  void _rebroadcast({
    required String image,
    required List<int> index,
    required List<String> ids,
    required String reciverName,
    required String senderName,
    required String senderImage,
    required String? giftPrice,
    required int? giftNum,
    required int? giftPriceT,
    required int totalWin,
    required int totalPk,
  }) {
    final Map<String, dynamic> roomData = {
      "action": LuckyGiftController.showLuckyGiftAnimation,
      "messageContent": {
        "message": LuckyGiftController.showLuckyGiftAnimation,
        "seatIndex": index,
        "receiversId": ids,
        "giftImage": image,
        "reciver": reciverName,
        "senderName": senderName,
        "senderImage": senderImage,
        "senderId": MyDataModel.getInstance().id.toString(),
        "giftPrice": giftPrice,
        "giftNum": giftNum,
        "giftPriceT": giftPriceT,
        "totalWin": totalWin,
        "totalPk": totalPk,
      }
    };
    log('📤 Sending lucky gift room message: receiversId=$ids, seatIndex=$index');
    LuckyLog.write('LUCKYFLY: re-broadcasting room message — '
        'receiversId=$ids, seatIndex=$index');

    try {
      final String map = jsonEncode(roomData);
      sendRoomData(data: jsonDecode(map));
    } catch (e) {
      log('⚠️ LUCKYFLY: failed to re-broadcast lucky gift over RTM: $e');
      LuckyLog.write('LUCKYFLY: failed to re-broadcast over RTM: $e');
    }
  }

  void _emitAnimation({
    required Emitter<LuckyGiftAnaimationManagerState> emit,
    required String? image,
    required List<SeatPosition> seatPosition,
  }) {
    final newAnimation = LuckyGiftSeatAnimation(
      key: UniqueKey(),
      img: image,
      numberOfCircles: seatPosition.length,
      seatPosition: seatPosition,
    );
    final currentData = state.data ?? [];
    emit(LuckyGiftAnimationSucssesState(data: currentData + [newAnimation]));

    // Schedule removal after animation completes (300ms bounce + 1s move + 400ms buffer)
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!isClosed) {
        add(RemoveCompletedLuckyGiftAnimationEvent(newAnimation));
      }
    });
  }

  /// Gets seat positions with retry mechanism.
  ///
  /// The exact source for a seat is its live avatar [RenderBox] (via the
  /// per-userId GlobalKey), but the key's context can be null for a few frames
  /// right after a seat change / just-in-time join. We retry to give the widget
  /// time to lay out; if a seat is still unresolved after the retries, we fall
  /// back to KIT-GRID GEOMETRY (the seat's correct cell), and only as an
  /// absolute last resort to a generic upper-center target — never empty, so the
  /// animation is never silently dropped.
  /// A slot is resolvable when it carries a recipient userId (render-box / kit
  /// seat-map resolution) OR a valid seat index (grid geometry). Previously a
  /// -1 index dropped the recipient entirely — even though their seat avatar
  /// GlobalKey was registered — which collapsed multi-recipient sends into one
  /// generic center candy whenever the screen-side seat mirror was stale.
  bool _isResolvable(List<int> indexes, List<String> ids, int i) {
    final hasUser = i < ids.length && ids[i].isNotEmpty;
    return hasUser || indexes[i] != -1;
  }

  Future<_SeatPositionsResult> _getSeatPositionsWithRetry(
    List<int> indexes,
    List<String> ids, {
    bool immediate = false,
  }) async {
    int expected = 0;
    for (int i = 0; i < indexes.length; i++) {
      if (_isResolvable(indexes, ids, i)) expected++;
    }

    // Optimistic sender path resolves in a single pass: its own seats are
    // already laid out, so the render-box retry/delay would only add latency.
    final int maxRetries = immediate ? 1 : _maxRetries;
    for (int retry = 0; retry < maxRetries; retry++) {
      int exactCount = 0;
      for (int i = 0; i < indexes.length; i++) {
        if (!_isResolvable(indexes, ids, i)) continue;
        if (i < ids.length &&
            ids[i].isNotEmpty &&
            LuckyGiftController.instance.getSeatPosition(ids[i]) != null) {
          exactCount++;
        }
      }

      log('🎁 LUCKYFLY: retry $retry/$maxRetries — exact '
          '$exactCount/$expected seat positions for ids=$ids');
      LuckyLog.write('LUCKYFLY: retry $retry/$maxRetries — exact '
          '$exactCount/$expected seat positions for ids=$ids');

      // Every seat resolved from a live RenderBox → build the exact set now.
      if (exactCount == expected && expected > 0) {
        break;
      }

      // Wait before retrying to allow widgets to render.
      if (retry < maxRetries - 1) {
        await Future.delayed(const Duration(milliseconds: _retryDelayMs));
      }
    }

    // Build the final target set. Each seat resolves through the controller's
    // layered resolver (render box → kit seat-map index → kit geometry →
    // center fallback), so every recipient gets the BEST available target and
    // we record which source was used.
    final List<SeatPosition> result = [];
    final List<SeatResolveSource> sources = [];
    final targetCount = expected == 0 ? 1 : expected;
    int slot = 0;
    for (int i = 0; i < indexes.length; i++) {
      if (!_isResolvable(indexes, ids, i)) continue;
      final userId = i < ids.length ? ids[i] : '';
      final res = LuckyGiftController.instance.resolveSeat(
        userId,
        seatIndex: indexes[i],
        slot: slot,
        totalSlots: targetCount,
      );
      result.add(res.position);
      sources.add(res.source);
      slot++;
    }
    if (result.isEmpty) {
      // No resolvable recipient at all (no ids and no valid seat indexes) —
      // still fly one candy toward the seat band rather than nothing.
      result.add(LuckyGiftController.instance.fallbackSeatPosition(0, 1));
      sources.add(SeatResolveSource.centerFallback);
    }

    final usedCenterFallback =
        sources.any((s) => s == SeatResolveSource.centerFallback);
    if (usedCenterFallback) {
      log('🎁 LUCKYFLY: center fallback used for at least one seat — '
          'sources=${sources.map((s) => s.name).toList()}');
      LuckyLog.write('LUCKYFLY: center fallback used for at least one seat — '
          'sources=${sources.map((s) => s.name).toList()}');
    }

    return _SeatPositionsResult(result, sources);
  }
}

class _SeatPositionsResult {
  final List<SeatPosition> positions;
  final List<SeatResolveSource> sources;
  _SeatPositionsResult(this.positions, this.sources);

  /// True only when EVERY seat was resolved from a live render box — the only
  /// state safe to cache (geometry/fallback targets may be superseded once the
  /// keys attach a frame later).
  bool get allExact =>
      sources.isNotEmpty &&
      sources.every((s) => s == SeatResolveSource.renderBox);

  String get sourceSummary => sources.map((s) => s.name).toList().toString();
}

class _CachedSeatPositions {
  final List<SeatPosition> positions;
  final DateTime createdAt;
  _CachedSeatPositions(this.positions) : createdAt = DateTime.now();
}
