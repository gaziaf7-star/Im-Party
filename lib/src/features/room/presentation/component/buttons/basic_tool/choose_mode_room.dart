import 'dart:math' as math;

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// "Choose Mic Seats" bottom sheet: the seat counts sit in a tab row on top, a
/// preview card below shows that layout over the moon / star / cloud
/// background, and "Confirm" applies it. Cinema / PK (owner spec) are offered
/// as two extra tabs; their full activation logic stays in the caller.
class ChooseModeRoom extends StatefulWidget {
  final String roomId;
  final String modeRoom;
  final VoidCallback? onCinemaTap;
  final VoidCallback? onPkTap;

  const ChooseModeRoom({
    required this.modeRoom,
    required this.roomId,
    this.onCinemaTap,
    this.onPkTap,
    super.key,
  });

  @override
  State<ChooseModeRoom> createState() => _ChooseModeRoomState();
}

/// One tab: either a seat layout ([mode]) or a special mode (cinema / PK).
class _Tab {
  final String label;
  final UTDRoomMode? mode;
  final IconData? icon;
  final VoidCallback? onConfirm;

  const _Tab({required this.label, this.mode, this.icon, this.onConfirm});
}

const Color _kSheetTop = Color(0xFF12123A);
const Color _kSheetBottom = Color(0xFF070719);
const Color _kAccent = Color(0xFF5B49F5);

class _ChooseModeRoomState extends State<ChooseModeRoom> {
  late final List<_Tab> _tabs;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    final controller = RoomData.instance.utdController;
    final modes = [
      ...?controller?.registeredModes.where((m) => m.id != '5'),
    ]..sort((a, b) => a.seatCount.compareTo(b.seatCount));

    final counts = <int, int>{};
    for (final m in modes) {
      counts[m.seatCount] = (counts[m.seatCount] ?? 0) + 1;
    }
    _tabs = [
      for (final m in modes)
        _Tab(
          // Two layouts can share a seat count (e.g. 8-seat CP and Couples),
          // so those fall back to their own name.
          label: counts[m.seatCount]! > 1 && m.displayName != null
              ? m.displayName!.tr()
              : '${m.seatCount}',
          mode: m,
        ),
      if (widget.onCinemaTap != null)
        _Tab(
          label: StringManager.cinemaMode.tr(),
          icon: Icons.movie_outlined,
          onConfirm: widget.onCinemaTap,
        ),
      if (widget.onPkTap != null)
        _Tab(
          label: StringManager.pk.tr(),
          icon: Icons.sports_kabaddi,
          onConfirm: widget.onPkTap,
        ),
    ];
    final current = _tabs.indexWhere((t) => t.mode?.id == widget.modeRoom);
    if (current >= 0) _selected = current;
  }

  /// Stores the layout on the backend too. The seat engine only holds the
  /// live session, so without this `enter_room` keeps returning the old mode
  /// and the room falls back to it (e.g. 30 seats -> 9) when the owner
  /// re-enters.
  Future<void> _saveMode(String modeId) async {
    final mode = int.tryParse(modeId);
    if (mode == null) return;
    final result = await di<ChangeRoomModeUC>().call(
      ChangeRoomModeParameter(roomId: widget.roomId, mode: mode),
    );
    result.fold(
      (failure) =>
          Methods.printLog('[ChooseModeRoom] save mode failed: $failure'),
      (_) => RoomData.instance.room.mode = modeId,
    );
  }

  void _confirm() {
    final controller = RoomData.instance.utdController;
    final tab = _tabs[_selected];
    Navigator.pop(context);
    if (tab.mode != null && controller != null) {
      final modeId = tab.mode!.id;
      controller.seatController
          .setupSeats(
            identity: MyDataModel.getInstance().id.toString(),
            seatCount: tab.mode!.seatCount,
            seatMode: controller.seatController.seatMode.value,
            modeId: modeId,
          )
          .then((ok) => ok ? _saveMode(modeId) : null);
    } else {
      tab.onConfirm?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) return const SizedBox.shrink();
    final tab = _tabs[_selected];
    final screenW = MediaQuery.sizeOf(context).width;
    // Wide layouts (6 seats across, e.g. 30 mics) get a wider card so the grid
    // fits instead of running past the right edge.
    final columns = tab.mode?.rows
            .fold<int>(1, (m, r) => r.length > m ? r.length : m) ??
        1;
    final cardWidth =
        columns > 5 ? screenW * 0.86 : math.min(screenW * 0.5, 230.0);

    return Container(
      padding: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kSheetTop, _kSheetBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            child: Text(
              'Choose Mic Seats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 10.w,
            endIndent: 10.w,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          SizedBox(
            height: 52.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              itemCount: _tabs.length,
              itemBuilder: (context, i) {
                final selected = i == _selected;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 60.w),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _tabs[i].label,
                          style: TextStyle(
                            color: selected ? _kAccent : Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        5.hBox,
                        Container(
                          width: 38.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: selected ? _kAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          12.hBox,
          _PreviewCard(width: cardWidth, tab: tab),
          18.hBox,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: GestureDetector(
              onTap: _confirm,
              child: Container(
                height: 50.h,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kAccent,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Text(
                  StringManager.confirm.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Portrait card with the moon / star / cloud backdrop and the seat layout.
class _PreviewCard extends StatelessWidget {
  final double width;
  final _Tab tab;

  const _PreviewCard({required this.width, required this.tab});

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF2B4C57).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _NightSkyPainter()),
            if (tab.mode != null)
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 14.h, 8.w, height * 0.34),
                // scaleDown guarantees the grid never overflows the card.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _SeatPreview(mode: tab.mode!),
                ),
              )
            else
              Align(
                alignment: const Alignment(0, -0.35),
                child: Icon(
                  tab.icon,
                  size: 46.h,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Deep teal sky with a glowing green cloud bank, crescent moon and star.
class _NightSkyPainter extends CustomPainter {
  const _NightSkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1730), Color(0xFF0C2530), Color(0xFF0A1A24)],
        ).createShader(Offset.zero & size),
    );

    // Glow behind the cloud bank.
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.95),
      w * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF1FD18B).withValues(alpha: 0.35),
          Colors.transparent,
        ]).createShader(
          Rect.fromCircle(center: Offset(w * 0.5, h * 0.95), radius: w * 0.55),
        ),
    );

    // Crescent moon.
    final moonC = Offset(w * 0.36, h * 0.8);
    final moonR = w * 0.2;
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: moonC, radius: moonR)),
      Path()
        ..addOval(Rect.fromCircle(
          center: moonC.translate(moonR * 0.45, -moonR * 0.1),
          radius: moonR * 0.88,
        )),
    );
    canvas.drawPath(
      moon,
      Paint()
        ..color = const Color(0xFF39E8A0).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      moon,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7DF5C4), Color(0xFF1DB87A)],
        ).createShader(Rect.fromCircle(center: moonC, radius: moonR)),
    );

    // Star.
    final starC = Offset(w * 0.62, h * 0.84);
    final starR = w * 0.055;
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? starR : starR * 0.45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(starC.dx + r * math.cos(a), starC.dy + r * math.sin(a));
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFF39E8A0));

    // Cloud bank: overlapping puffs, lit green on top.
    final cloud = Path();
    final puffs = <Rect>[
      Rect.fromCircle(center: Offset(w * 0.12, h * 0.97), radius: w * 0.16),
      Rect.fromCircle(center: Offset(w * 0.3, h * 0.93), radius: w * 0.17),
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.9), radius: w * 0.2),
      Rect.fromCircle(center: Offset(w * 0.72, h * 0.93), radius: w * 0.17),
      Rect.fromCircle(center: Offset(w * 0.9, h * 0.97), radius: w * 0.16),
    ];
    for (final p in puffs) {
      cloud.addOval(p);
    }
    cloud.addRect(Rect.fromLTWH(0, h * 0.96, w, h * 0.04));
    canvas.drawPath(
      cloud,
      Paint()
        ..color = const Color(0xFF1FD18B).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      cloud,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2FA37B), Color(0xFF0B3B3A)],
        ).createShader(Rect.fromLTWH(0, h * 0.7, w, h * 0.3)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The seat grid of [mode]: grey seat circles with their number underneath
/// ("Host" for seat 0).
class _SeatPreview extends StatelessWidget {
  final UTDRoomMode mode;

  const _SeatPreview({required this.mode});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            mode.rows.fold<int>(1, (m, r) => r.length > m ? r.length : m);
        final rowCount = mode.rows.length;
        const gap = 2.0;
        // Reserve a little height per row for the number label.
        const labelH = 7.0;
        final byWidth = (constraints.maxWidth - gap * 2 * columns) / columns;
        final byHeight =
            (constraints.maxHeight - (gap * 2 + labelH) * rowCount) / rowCount;
        final dot = math.min(byWidth, byHeight).clamp(4.0, 22.0);
        final showLabels = dot >= 10;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final row in mode.rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: gap),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final seat in row)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: gap),
                        child: SizedBox(
                          width: dot + 6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: dot,
                                height: dot,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    AssetsManager.seat,
                                    width: dot * 0.55,
                                    height: dot * 0.55,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              if (showLabels)
                                Text(
                                  seat == 0 ? 'Host' : '$seat',
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 5,
                                    height: 1.3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
