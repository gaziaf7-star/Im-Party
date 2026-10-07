import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/seat_config/empty_seat_widget.dart';
import 'package:general/src/features/room/room.dart';

/// Frees a "ghost" seat: the backend can keep a seat occupied after the user
/// has already left the room (its participant-left cleanup is not instant and
/// can be missed), which used to leave a never-ending shimmer circle. If the
/// occupant is not in the live room participant list for [grace], the seat is
/// drawn as an empty one until the backend catches up.
class GhostSeatGuard extends StatefulWidget {
  final String userId;
  final int seatIndex;
  final double size;
  final Widget child;
  final Duration grace;

  const GhostSeatGuard({
    super.key,
    required this.userId,
    required this.seatIndex,
    required this.size,
    required this.child,
    this.grace = const Duration(seconds: 6),
  });

  @override
  State<GhostSeatGuard> createState() => _GhostSeatGuardState();
}

class _GhostSeatGuardState extends State<GhostSeatGuard> {
  StreamSubscription<dynamic>? _sub;
  Timer? _timer;
  bool _ghost = false;

  bool _present() {
    final c = RoomData.instance.utdController;
    if (c == null) return true; // not connected yet: never guess
    try {
      return c.participants.any((p) => p.id == widget.userId);
    } catch (_) {
      return true;
    }
  }

  void _check() {
    if (!mounted) return;
    if (_present()) {
      _timer?.cancel();
      _timer = null;
      if (_ghost) setState(() => _ghost = false);
    } else if (!_ghost && _timer == null) {
      _timer = Timer(widget.grace, () {
        _timer = null;
        if (mounted && !_present()) setState(() => _ghost = true);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _sub = RoomData.instance.utdController?.participantsStream.listen(
      (_) => _check(),
    );
    _check();
  }

  @override
  void didUpdateWidget(covariant GhostSeatGuard old) {
    super.didUpdateWidget(old);
    if (old.userId != widget.userId) {
      _timer?.cancel();
      _timer = null;
      _ghost = false;
      _check();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ghost) {
      return EmptySeat(index: widget.seatIndex, size: widget.size);
    }
    return widget.child;
  }
}
