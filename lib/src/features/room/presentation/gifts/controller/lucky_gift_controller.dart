import 'dart:developer';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/lucky_log.dart';
import 'package:general/src/features/room/room.dart';

/// How a seat target was resolved, used for diagnostics so we can tell a real
/// seat hit from an approximate one in the local LUCKYFLY logs.
enum SeatResolveSource {
  /// Read from the live seat-avatar [RenderBox] via BuildContext/GlobalKey.
  renderBox,

  /// Computed from the kit's deterministic seat grid geometry anchored to a
  /// sibling seat that DID resolve from a render box. On-screen accurate.
  geometryAnchored,

  /// Computed from the kit's grid geometry using a screen estimate for the grid
  /// origin (no sibling seat resolved). Approximate but seat-aware.
  geometryEstimated,

  /// Live room: the visitors-bar container in the header (recipient not
  /// individually visible — e.g. a viewer beyond the displayed avatars).
  liveVisitorsBar,

  /// Live room: the host's header avatar (recipient unresolvable any other way).
  liveHostAvatar,

  /// Generic upper-center band — the seat could not be resolved at all.
  centerFallback,
}

/// Resolution outcome for a single seat: the on-screen target plus the source
/// that produced it. [isExact] is true only for a real render-box hit.
class SeatResolution {
  final SeatPosition position;
  final SeatResolveSource source;
  const SeatResolution(this.position, this.source);

  bool get isExact => source == SeatResolveSource.renderBox;
}

class LuckyGiftController {
  LuckyGiftController._internal();

  static final LuckyGiftController _instance = LuckyGiftController._internal();

  static LuckyGiftController get instance => _instance;

  List<LuckyGiftModel> tempLuckyGiftData = [];
  int numOfRequest = 0;

  static const String showLuckyGiftAnimation = 'showLuckyGiftAnimation';
  static const String endLuckyGiftforReciver = 'endLuckyGiftforReciver';

  /// LIVE-room fly targets, registered by the live header while it is mounted
  /// (null in audio rooms). Individual avatars (host card + visible visitor
  /// avatars) register per-userId targets in [liveAvatarKeys]; these two
  /// are the live AREA fallbacks when the recipient has no visible avatar.
  static GlobalKey? liveVisitorsBarKey;
  static GlobalKey? liveHostAvatarKey;

  /// Per-avatar targets owned only by the video live-room header. These must
  /// not share [RoomScreenState.seatAvatarKeys]: the transparent input route
  /// can keep an audio room subtree mounted while the live header rebuilds,
  /// which otherwise attaches the same GlobalKey to both trees.
  static final Map<String, GlobalKey> liveAvatarKeys = {};

  /// Vertical gap between seat rows in the kit grid (see [UTDSeatGrid.build],
  /// `const SizedBox(height: 5)`). Kept in sync with the kit layout.
  static const double _rowGap = 5.0;

  /// Resolve the actual on-screen center of [userId]'s avatar.
  ///
  /// AUDIO rooms register BuildContext directly, avoiding duplicate GlobalKey
  /// crashes during seat/overlay transitions. LIVE-room header avatars still
  /// use the legacy GlobalKey registry as a fallback.
  SeatPosition? _renderBoxPosition(String userId) {
    if (!di<RoomStateManager>().isInAudioRoom) {
      final livePosition = _keyCenter(liveAvatarKeys[userId]);
      if (livePosition != null) return livePosition;
    }

    final fromContext = _contextCenter(
      RoomScreenState.seatAvatarContexts[userId],
    );

    if (fromContext != null) {
      return fromContext;
    }

    return _keyCenter(
      RoomScreenState.seatAvatarKeys[userId],
    );
  }

  SeatPosition? _contextCenter(BuildContext? context) {
    if (context == null || !context.mounted) return null;

    try {
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox) return null;
      if (!renderObject.attached || !renderObject.hasSize) {
        return null;
      }

      final center = renderObject.localToGlobal(
        renderObject.size.center(Offset.zero),
      );

      return SeatPosition(
        x: center.dx,
        y: center.dy,
      );
    } catch (_) {
      return null;
    }
  }

  /// On-screen center of [key]'s render box, or null when it isn't laid out.
  SeatPosition? _keyCenter(GlobalKey? key) {
    final context = key?.currentContext;
    if (context == null || !context.mounted) return null;

    try {
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox) return null;
      if (!renderObject.attached || !renderObject.hasSize) {
        return null;
      }

      final center = renderObject.localToGlobal(
        renderObject.size.center(Offset.zero),
      );

      return SeatPosition(
        x: center.dx,
        y: center.dy,
      );
    } catch (_) {
      return null;
    }
  }

  /// Resolve the recipient's mic seat as reliably as possible.
  ///
  /// Order of preference:
  ///   1. The recipient's OWN seat-avatar render box (exact).
  ///   2. Kit-grid geometry anchored to a SIBLING seat that resolved from a
  ///      render box — geometrically exact for the same Column/Row layout.
  ///   3. Kit-grid geometry with a screen-estimated grid origin — approximate
  ///      but still aimed at the correct seat cell.
  ///   4. Generic upper-center fallback (caller-supplied via [fallback]).
  ///
  /// [seatIndex] is the recipient's seat index in the kit grid; pass -1/null if
  /// unknown (only the render-box and center paths remain available then).
  SeatResolution resolveSeat(
      String userId, {
        required int seatIndex,
        required int slot,
        required int totalSlots,
      }) {
    // 1) Exact render box.
    final exact = _renderBoxPosition(userId);
    if (exact != null) {
      log('🎁 LUCKYFLY: resolveSeat($userId,idx=$seatIndex) -> renderBox '
          '(${exact.x.toStringAsFixed(1)},${exact.y.toStringAsFixed(1)})');
      LuckyLog.write('LUCKYFLY: resolveSeat($userId,idx=$seatIndex) -> renderBox '
          '(${exact.x.toStringAsFixed(1)},${exact.y.toStringAsFixed(1)})');
      return SeatResolution(exact, SeatResolveSource.renderBox);
    }

    // LIVE room: there is no seat grid. The recipient either has a visible
    // avatar (host card / visitors bar — the render-box path above), or we aim
    // at the visitors-bar area (viewer from the comments without a displayed
    // avatar), then the host's header avatar. Never the audio grid geometry.
    if (!di<RoomStateManager>().isInAudioRoom) {
      final bar = _keyCenter(liveVisitorsBarKey);
      if (bar != null) {
        log('🎁 LUCKYFLY: resolveSeat($userId) -> liveVisitorsBar '
            '(${bar.x.toStringAsFixed(1)},${bar.y.toStringAsFixed(1)})');
        LuckyLog.write('LUCKYFLY: resolveSeat($userId) -> liveVisitorsBar '
            '(${bar.x.toStringAsFixed(1)},${bar.y.toStringAsFixed(1)})');
        return SeatResolution(bar, SeatResolveSource.liveVisitorsBar);
      }
      final host = _keyCenter(liveHostAvatarKey);
      if (host != null) {
        log('🎁 LUCKYFLY: resolveSeat($userId) -> liveHostAvatar '
            '(${host.x.toStringAsFixed(1)},${host.y.toStringAsFixed(1)})');
        LuckyLog.write('LUCKYFLY: resolveSeat($userId) -> liveHostAvatar '
            '(${host.x.toStringAsFixed(1)},${host.y.toStringAsFixed(1)})');
        return SeatResolution(host, SeatResolveSource.liveHostAvatar);
      }
    }

    // Unknown/-1 seat index (audio room): recover it from the KIT's live seat
    // map (the source of truth) by the recipient's userId. The caller's index
    // comes from the RoomScreenState.seatAvatarIds mirror, which can be
    // empty/stale at send time (multi-recipient sends arrived here with EVERY
    // index -1 while all recipients were seated), so a miss there must not
    // disable geometry.
    var effectiveIndex = seatIndex;
    if (effectiveIndex < 0 && userId.isNotEmpty) {
      effectiveIndex = _seatIndexFromKit(userId) ?? -1;
    }

    // 2) + 3) Geometry from the kit grid (anchored, then estimated).
    if (effectiveIndex >= 0) {
      final geo = _computeSeatPositionByIndex(effectiveIndex);
      if (geo != null) {
        log('🎁 LUCKYFLY: resolveSeat($userId,idx=$seatIndex) -> '
            '${geo.source.name} '
            '(${geo.position.x.toStringAsFixed(1)},${geo.position.y.toStringAsFixed(1)})');
        LuckyLog.write('LUCKYFLY: resolveSeat($userId,idx=$seatIndex) -> '
            '${geo.source.name} '
            '(${geo.position.x.toStringAsFixed(1)},${geo.position.y.toStringAsFixed(1)})');
        return geo;
      }
    }

    // 4) Last resort: generic upper-center band, fanned out by slot.
    final fb = fallbackSeatPosition(slot, totalSlots);
    log('🎁 LUCKYFLY: resolveSeat($userId,idx=$seatIndex) -> centerFallback '
        '(${fb.x.toStringAsFixed(1)},${fb.y.toStringAsFixed(1)}) '
        '— seat unresolvable (key null + geometry failed)');
    LuckyLog.write('LUCKYFLY: resolveSeat($userId,idx=$seatIndex) -> '
        'centerFallback (${fb.x.toStringAsFixed(1)},${fb.y.toStringAsFixed(1)}) '
        '— seat unresolvable (key null + geometry failed)');
    return SeatResolution(fb, SeatResolveSource.centerFallback);
  }

  /// The recipient's seat index read from the kit's live seat list (keyed by
  /// occupant userId). Null when the user isn't seated or the kit isn't up.
  int? _seatIndexFromKit(String userId) {
    try {
      final seats =
          RoomData.instance.utdController?.seatController.seats.value;
      if (seats == null) return null;
      for (final seat in seats) {
        if (seat.occupantUserId == userId) return seat.index;
      }
    } catch (_) {/* fall through to the caller's remaining strategies */}
    return null;
  }

  /// Backward-compatible exact lookup (render box only). Retained for callers
  /// that only need the precise position and treat null as "not ready yet".
  SeatPosition? getSeatPosition(String userId) {
    final pos = _renderBoxPosition(userId);
    if (pos != null) {
      log('🎁 LUCKYFLY: getSeatPosition($userId) resolved center=global'
          '(${pos.x.toStringAsFixed(1)},${pos.y.toStringAsFixed(1)})');
      LuckyLog.write('LUCKYFLY: getSeatPosition($userId) resolved center=global'
          '(${pos.x.toStringAsFixed(1)},${pos.y.toStringAsFixed(1)})');
      return pos;
    }
    final key = RoomScreenState.seatAvatarKeys[userId];
    final contextRegistered =
        RoomScreenState.seatAvatarContexts[userId] != null;

    log('🎁 LUCKYFLY: getSeatPosition($userId) -> null '
        '(contextRegistered=$contextRegistered, keyRegistered=${key != null})');
    LuckyLog.write('LUCKYFLY: getSeatPosition($userId) -> null '
        '(contextRegistered=$contextRegistered, keyRegistered=${key != null})');
    return null;
  }

  /// Compute a seat's on-screen center from the UTD kit's deterministic grid
  /// layout (see [UTDSeatGrid.build] / [UTDRoomMode]): a Column of Rows, each
  /// Row laid out with [MainAxisAlignment.spaceAround] across the full grid
  /// width, [_rowGap] px between rows. The geometry is reconstructed from the
  /// live [UTDRoomMode] (rows + seat size).
  ///
  /// The grid's TOP-LEFT in global coordinates is recovered by ANCHORING to any
  /// sibling seat whose render box IS available (exact). If none is available, a
  /// conservative screen estimate of the grid origin is used (approximate). The
  /// horizontal position is always exact because spaceAround is deterministic.
  SeatResolution? _computeSeatPositionByIndex(int seatIndex) {
    try {
      final controller = RoomData.instance.utdController;
      if (controller == null) return null;

      final mode = controller.currentMode.value;
      final rows = mode.rows;
      if (rows.isEmpty) return null;

      // Locate (row, col) of the target seat in the grid layout.
      int targetRow = -1;
      int targetCol = -1;
      for (int r = 0; r < rows.length; r++) {
        final c = rows[r].indexOf(seatIndex);
        if (c != -1) {
          targetRow = r;
          targetCol = c;
          break;
        }
      }
      if (targetRow == -1) return null;

      final screenWidth = ScreenUtil().screenWidth;
      final seatSize = mode.computeSeatSize(screenWidth);
      if (seatSize <= 0) return null;

      // Horizontal center within a Row of [count] seats laid out with
      // spaceAround across the full [gridWidth]. spaceAround gives each child a
      // gap on both sides (half-gap at the edges):
      //   gap = (gridWidth - count*seatSize) / count
      //   centerX(k) = gap/2 + k*(seatSize + gap) + seatSize/2
      double centerXFor(int count, int col, double gridWidth) {
        if (count <= 0) return gridWidth / 2;
        final gap = (gridWidth - count * seatSize) / count;
        return (gap / 2) + col * (seatSize + gap) + seatSize / 2;
      }

      // The seats Column fills the screen width (kit adds no horizontal padding
      // around the grid), so the grid width is the screen width and its left
      // edge is x=0.
      final gridWidth = screenWidth;
      final targetCount = rows[targetRow].length;
      final targetX = centerXFor(targetCount, targetCol, gridWidth);

      // Vertical: try to anchor the grid origin to a sibling seat whose render
      // box resolved. seatY(row) = gridTop + row*(seatSize + _rowGap) + size/2.
      final seats = controller.seatController.seats.value;
      double? gridTop;
      for (final seat in seats) {
        final occupant = seat.occupantUserId;
        if (occupant == null || occupant.isEmpty) continue;
        final box = _renderBoxPosition(occupant);
        if (box == null) continue;
        // Find this anchor's (row) to back-solve gridTop.
        int anchorRow = -1;
        for (int r = 0; r < rows.length; r++) {
          if (rows[r].contains(seat.index)) {
            anchorRow = r;
            break;
          }
        }
        if (anchorRow == -1) continue;
        gridTop = box.y -
            (anchorRow * (seatSize + _rowGap)) -
            seatSize / 2;
        break;
      }

      if (gridTop != null) {
        final targetY =
            gridTop + targetRow * (seatSize + _rowGap) + seatSize / 2;
        return SeatResolution(
          SeatPosition(x: targetX, y: targetY),
          SeatResolveSource.geometryAnchored,
        );
      }

      // No sibling anchor — estimate the grid origin from the screen. The seat
      // grid sits just below the room header near the top of the screen. A
      // conservative estimate places the grid top at ~12% of the screen height
      // (status bar + header). This is approximate but still aimed at the right
      // seat cell, far better than a generic center target.
      final screenHeight = ScreenUtil().screenHeight;
      final estTop = screenHeight * 0.12;
      final targetY =
          estTop + targetRow * (seatSize + _rowGap) + seatSize / 2;
      return SeatResolution(
        SeatPosition(x: targetX, y: targetY),
        SeatResolveSource.geometryEstimated,
      );
    } catch (e) {
      log('🎁 LUCKYFLY: _computeSeatPositionByIndex($seatIndex) threw: $e');
      LuckyLog.write(
          'LUCKYFLY: _computeSeatPositionByIndex($seatIndex) threw: $e');
      return null;
    }
  }

  /// Approximate on-screen target used only when the seat cannot be resolved by
  /// render box OR kit-grid geometry. The seat grid lives in the upper portion
  /// of the room, so we aim at the upper-center band and fan out horizontally by
  /// [slot] so multiple gifts in one combo don't perfectly overlap. Guarantees
  /// the candy ALWAYS flies somewhere plausible instead of showing nothing.
  SeatPosition fallbackSeatPosition(int slot, int total) {
    final width = ScreenUtil().screenWidth;
    final height = ScreenUtil().screenHeight;
    final count = total <= 0 ? 1 : total;
    // Spread targets across the central 60% of the width.
    final fraction = count == 1 ? 0.5 : (0.2 + (0.6 * (slot / (count - 1))));
    return SeatPosition(
      x: width * fraction,
      y: height * 0.28,
    );
  }

  void dispose() {
    tempLuckyGiftData.clear();
    numOfRequest = 0;
  }
}

class SeatPosition {
  double x;
  double y;
  SeatPosition({required this.x, required this.y});
}
