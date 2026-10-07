import 'package:flutter/material.dart';

import '../controller/seat_controller.dart';
import '../models/seat_layout.dart';
import '../models/seat_model.dart';
import '../theme/utd_room_theme.dart';
import 'seat_widget.dart';

// Renders seats in rows based on layout mode — supports all 8 modes
class UTDSeatGrid extends StatelessWidget {
  final List<List<int>> rows;
  final double seatSize;
  final List<SeatState> seats;
  final Set<String> activeSpeakers;

  /// Identities muted via live RTC state — OR'd with [SeatState.isMuted]
  /// when drawing the mic-off icon.
  final Set<String> mutedParticipants;
  final void Function(int index, SeatState seat)? onSeatTap;

  /// Color tokens for the default seat rendering.
  final UTDRoomTheme? theme;

  /// Whether to render occupant names under default seats.
  final bool showName;

  /// Seat index reserved for the host.
  final int hostSeatIndex;

  /// Vertical gap (logical px) between seat rows. Null ⇒ read the dev-set
  /// [UTDSeatLayout.active.rowSpacing].
  final double? rowSpacing;

  /// Maps occupant identity → role string (e.g., "host", "admin", "guest").
  /// Used to display role badges on seats.
  final Map<String, String> participantRoles;

  // Custom builders passed through to UTDSeatWidget
  final Widget Function(SeatState seat, double size)? seatBuilder;
  final Widget Function(
    String userId,
    double size,
    Map<String, String> attributes,
    bool isMuted,
    int seatIndex,
    String userName,
  )? avatarBuilder;
  final Widget Function(int index, double size)? emptySeatBuilder;
  final Widget Function(int index, double size)? lockedSeatBuilder;

  const UTDSeatGrid({
    super.key,
    required this.rows,
    required this.seatSize,
    required this.seats,
    this.activeSpeakers = const {},
    this.mutedParticipants = const {},
    this.participantRoles = const {},
    this.onSeatTap,
    this.theme,
    this.showName = true,
    this.hostSeatIndex = 0,
    this.rowSpacing,
    this.seatBuilder,
    this.avatarBuilder,
    this.emptySeatBuilder,
    this.lockedSeatBuilder,
  });

  @Deprecated('Use UTDRoomMode with UTDAudioRoom.modes instead')
  factory UTDSeatGrid.fromMode({
    Key? key,
    required String mode,
    required double screenWidth,
    required List<SeatState> seats,
    Set<String> activeSpeakers = const {},
    Map<String, String> participantRoles = const {},
    void Function(int index, SeatState seat)? onSeatTap,
    Widget Function(SeatState seat, double size)? seatBuilder,
    Widget Function(
      String userId,
      double size,
      Map<String, String> attributes,
      bool isMuted,
      int seatIndex,
      String userName,
    )? avatarBuilder,
    Widget Function(int index, double size)? emptySeatBuilder,
    Widget Function(int index, double size)? lockedSeatBuilder,
  }) {
    final count = UTDSeatController.seatCountForMode(mode);
    final rows = <List<int>>[];
    for (var i = 0; i < count; i += 4) {
      final end = (i + 4 > count) ? count : i + 4;
      rows.add(List.generate(end - i, (j) => i + j));
    }
    final seatSize = screenWidth / 5;

    return UTDSeatGrid(
      key: key,
      rows: rows,
      seatSize: seatSize,
      seats: seats,
      activeSpeakers: activeSpeakers,
      participantRoles: participantRoles,
      onSeatTap: onSeatTap,
      seatBuilder: seatBuilder,
      avatarBuilder: avatarBuilder,
      emptySeatBuilder: emptySeatBuilder,
      lockedSeatBuilder: lockedSeatBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dev-tunable inter-row gap (falls back to the published layout value).
    final gap = rowSpacing ?? UTDSeatLayout.active.rowSpacing;
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0)
            SizedBox(
              height: i <= 2 ? gap + UTDSeatLayout.active.firstRowGap : gap,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final seatIndex in rows[i])
                _buildSeat(seatIndex),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSeat(int index) {
    final seat = index < seats.length
        ? seats[index]
        : SeatState(index: index);

    final isSpeaking = seat.occupantUserId != null &&
        activeSpeakers.contains(seat.occupantUserId);

    final isMutedLive = seat.occupantUserId != null &&
        mutedParticipants.contains(seat.occupantUserId);

    // Look up role for the occupant (if any)
    final role = seat.occupantUserId != null
        ? participantRoles[seat.occupantUserId]
        : null;

    // Isolate each seat in its own layer: when one occupant's speaking/mute
    // state flips and the grid rebuilds, only the seat(s) that actually changed
    // repaint, instead of the whole grid's raster.
    return RepaintBoundary(
      child: UTDSeatWidget(
        seat: seat,
        size: seatSize,
        isSpeaking: isSpeaking,
        isMutedLive: isMutedLive,
        role: role,
        showName: showName,
        isHostSeat: index == hostSeatIndex,
        theme: theme,
        onTap: () => onSeatTap?.call(index, seat),
        seatBuilder: seatBuilder,
        avatarBuilder: avatarBuilder,
        emptySeatBuilder: emptySeatBuilder,
        lockedSeatBuilder: lockedSeatBuilder,
      ),
    );
  }
}
