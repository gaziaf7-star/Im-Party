import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// The single "ask for a seat" control, shown in view mode under the boom.
///
/// View mode is the kit's `request` seat mode: anyone may enter the room, but
/// taking a seat needs the host's approval. Whoever is already seated when the
/// owner switches the room into it stays put — the mode gates NEW takes only.
///
/// There used to be an Apply pill under every empty seat. That repeated one
/// action up to thirty times and implied you were applying for a particular
/// chair, which is not how the backend works: a request that names no seat is
/// approved into whichever seat is free at that moment
/// (`SpeakerService::approve` → `firstFreeSeat`). So this asks for *a* seat, not
/// *that* seat, and there is exactly one of it.
///
/// Hidden for the owner and admins — they seat people directly and never apply
/// — and hidden once you are on a seat.
class SeatApplyButton extends StatefulWidget {
  const SeatApplyButton({super.key});

  @override
  State<SeatApplyButton> createState() => _SeatApplyButtonState();
}

class _SeatApplyButtonState extends State<SeatApplyButton> {
  bool _pending = false;
  bool _busy = false;
  StreamSubscription<Map<String, dynamic>>? _events;

  @override
  void initState() {
    super.initState();
    final controller = RoomData.instance.utdController;
    // The audio kit has no "my request is pending" notifier the way the live
    // kit does, so the answer is kept here and cleared by the host's verdict.
    // Without this the button would say Pending for the rest of the session
    // after a rejection.
    _events = controller?.seatController.speakerEventStream.listen((event) {
      final type = '${event['type'] ?? ''}';
      if (type == '_speaker_request_approved' ||
          type == '_speaker_request_rejected') {
        if (mounted) setState(() => _pending = false);
      }
    });
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _apply(UTDRoomController controller) async {
    if (_busy) return;
    setState(() => _busy = true);

    // No seat index on purpose: the server picks the free seat at approval
    // time, which is the only moment it can be sure one is still free.
    final result = await controller.requestToSpeak();

    if (!mounted) return;
    setState(() {
      _busy = false;
      _pending = result != null;
    });

    if (!context.mounted) return;
    Methods.showToast(
      context,
      message: result != null
          ? StringManager.requestSent.tr()
          : StringManager.someThingWentWrong.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = RoomData.instance.utdController;
    if (controller == null) return const SizedBox.shrink();

    final myId = MyDataModel.getInstance().id.toString();
    final isStaff = RoomData.instance.room.ownerId?.toString() == myId ||
        (RoomData.instance.room.admins?.contains(myId) ?? false);
    if (isStaff) return const SizedBox.shrink();

    return ValueListenableBuilder<String>(
      valueListenable: controller.seatController.seatMode,
      builder: (context, mode, _) {
        if (mode != 'request') return const SizedBox.shrink();

        // Rebuilt on every seat change so the button disappears the moment the
        // approval seats you, without waiting for anything else to redraw.
        return ValueListenableBuilder<List<SeatState>>(
          valueListenable: controller.seatController.seats,
          builder: (context, __, ___) {
            if (controller.localSeatIndex >= 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: _Pill(
                pending: _pending,
                busy: _busy,
                onTap: () => _apply(controller),
              ),
            );
          },
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.pending,
    required this.busy,
    required this.onTap,
  });

  final bool pending;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Grey while waiting on the host: the button is still there so you can see
    // your request stands, but it no longer invites a second tap.
    final background =
        pending ? ColorManager.black.withValues(alpha: 0.45) : ColorManager.primary;
    final ink = pending ? ColorManager.onDark : ColorManager.inkOn(ColorManager.primary);

    return GestureDetector(
      onTap: pending || busy ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: ColorManager.onDark.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              pending ? Icons.hourglass_top_rounded : Icons.event_seat_rounded,
              size: 13.h,
              color: ink,
            ),
            4.wBox,
            TextWidget(
              (pending ? StringManager.pending : StringManager.apply).tr(),
              style: context.bodySmall.size(10).w700.colorExt(ink),
            ),
          ],
        ),
      ),
    );
  }
}
