import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';

/// How long this broadcast has been on air.
///
/// The start time comes from the SERVER (`rooms.live_started_at`, surfaced on
/// the enter-room response). A client-side stopwatch would start whenever this
/// particular viewer joined, so the host and someone arriving an hour later
/// would see different numbers for the same broadcast.
///
/// Renders nothing at all until the start time is known, rather than flashing a
/// misleading 00:00 while the enter-room response is still in flight.
class LiveDurationChip extends StatefulWidget {
  const LiveDurationChip({super.key, this.startedAt, required this.isHost});

  /// When null, the start time is read from the LIVE room. The party (audio)
  /// room keeps its own [RoomData] singleton, so it passes its start time in —
  /// one chip serves both, and a broadcast is timed the same either way.
  final DateTime? startedAt;

  /// Only the person broadcasting sees the clock.
  final bool isHost;

  @override
  State<LiveDurationChip> createState() => _LiveDurationChipState();
}

class _LiveDurationChipState extends State<LiveDurationChip> {
  Timer? _ticker;

  /// Stamped the first time the HOST needs a clock and no start time is known.
  ///
  /// `rooms.live_started_at` is written when the broadcast begins, but the
  /// enter-room response the client holds was fetched BEFORE that — so a host
  /// who had just gone live saw no clock at all, and one who re-entered an
  /// already-running room did. That is the "timer shows sometimes" report.
  /// The host's own screen is proof the broadcast is running, so a missing
  /// stamp is a gap in the data, not a reason to hide the clock. Kept in state
  /// so it is stamped once per broadcast, not once per tick.
  DateTime? _hostFallbackStart;

  @override
  void initState() {
    super.initState();
    // One second is the smallest unit shown, so a faster tick would only burn
    // frames. The tick is cancelled in dispose, and setState is guarded by
    // `mounted` because the room can be left mid-tick.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// When this broadcast began, in order of authority: the caller's value (the
  /// party room passes the server stamp), the live room's server stamp, the
  /// engine's own publish moment, and finally this device's stamp so the host
  /// always has a running clock.
  DateTime _resolveStart() {
    final fromServer =
        widget.startedAt ?? LiveRoomData.instance.roomOrNull?.liveStartedAt;
    if (fromServer != null) return fromServer;

    final fromEngine = LiveRoomData
        .instance.liveController?.mediaController.liveStartedAt.value;
    if (fromEngine != null) return fromEngine;

    return _hostFallbackStart ??= DateTime.now().toUtc();
  }

  /// `mm:ss` under an hour, `h:mm:ss` past it — the usual broadcast format.
  String _format(Duration d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));

    return d.inHours > 0 ? '${d.inHours}:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // The broadcaster's own clock: how long THEY have been on air. Viewers do
    // not get it — they did not start the broadcast, and the number only means
    // something to the person running it.
    if (!widget.isHost) return const SizedBox.shrink();

    final startedAt = _resolveStart();

    // A clock skewed ahead of the server would otherwise render a negative
    // duration; clamping to zero is the honest fallback.
    final elapsed = DateTime.now().toUtc().difference(startedAt.toUtc());
    if (elapsed.isNegative) return const SizedBox.shrink();

    return Container(
      padding: context.paddingSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF3B30),
            ),
          ),
          5.wBox,
          TextWidget(
            _format(elapsed),
            style: context.bodySmall.w600
                .colorExt(ColorManager.white)
                .size(11),
          ),
        ],
      ),
    );
  }
}
