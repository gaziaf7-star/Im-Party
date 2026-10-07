import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// The 30-seat party layout: six across, five deep.
///
/// The built-in grid packs its rows with a flat 5px gap, which is right for a
/// three- or four-row mode and wrong here: five rows of six small seats
/// clustered into the top third of the screen and left a dead band above the
/// chat, which then stretched to fill it.
///
/// So the rows are spread across whatever height the room gives this widget.
/// The seat SIZE is untouched -- it is computed once from the densest row so
/// six still fit the narrowest phone, and growing it would break that.
class Seat30Mode extends StatelessWidget {
  final List<UTDParticipant> allUsers;
  final List<UTDParticipant> audioVideoUsers;
  final Widget Function(UTDParticipant user, int seatIndex) seatWidgetCreator;

  const Seat30Mode({
    super.key,
    required this.allUsers,
    required this.audioVideoUsers,
    required this.seatWidgetCreator,
  });

  static const int _columns = 6;
  static const int _rows = 5;

  @override
  Widget build(BuildContext context) {
    final seatNotifier = RoomData.instance.utdController?.seatController.seats;
    // Single source of truth for the seat size (already device-scaled). Do NOT
    // apply ScreenUtil to it.
    final seatSize = RoomData.instance.utdController?.currentMode.value
            .computeSeatSize(MediaQuery.of(context).size.width) ??
        52.0;

    if (seatNotifier == null) return _buildLayout(context, seatSize);

    return ValueListenableBuilder<List<SeatState>>(
      valueListenable: seatNotifier,
      builder: (context, _, __) => _buildLayout(context, seatSize),
    );
  }

  Widget _buildLayout(BuildContext context, double seatSize) {
    Widget seat(int index) => SizedBox(
          width: seatSize,
          height: seatSize,
          child:
              seatWidgetCreator(const UTDParticipant(id: '', name: ''), index),
        );

    Widget rowAt(int r) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int c = 0; c < _columns; c++) seat(r * _columns + c),
          ],
        );

    final sidePad = MediaQuery.of(context).size.width * 0.0125;

    return LayoutBuilder(
      builder: (context, constraints) {
        // A seat slot is the avatar plus its name label, so a row is taller
        // than seatSize alone; 1.35 matches what the slot actually occupies.
        final rowHeight = seatSize * 1.35;
        final rowGap = seatSize * 0.28;
        // Must include the gaps -- leaving them out made `natural` smaller
        // than the real rendered content (5 rows + 4 gaps), which under the
        // old artificial-height branch below let the last seat row overflow
        // past its box.
        final natural = rowHeight * _rows + rowGap * (_rows - 1);
        final available = constraints.maxHeight;

        // The kit places this widget as a plain child of a Column, above an
        // Expanded message list -- so the height offered here is INFINITE.
        // Previously this claimed an artificial share of the screen height
        // (a guessed `target`, floored at an estimated `natural`), which
        // kept over/under-shooting the real content height and made the
        // comment section jump down or clip the last row depending on the
        // guess. Simplest correct fix, on request ("upora othba" repeatedly):
        // don't guess at all -- let the Column size itself to its actual
        // content (mainAxisSize.min) with no wrapping SizedBox, exactly like
        // the `available <= natural` branch below. The block is then always
        // exactly as tall as 5 rows + their gaps truly need, nothing more,
        // so the chat below starts immediately after it -- as high up as it
        // can physically go without clipping anything.
        if (!available.isFinite) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int r = 0; r < _rows; r++) ...[
                  if (r > 0) SizedBox(height: rowGap),
                  rowAt(r),
                ],
              ],
            ),
          );
        }

        if (available <= natural) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int r = 0; r < _rows; r++) ...[
                  // Row-to-row gap, nudged up again on request.
                  if (r > 0) SizedBox(height: rowGap),
                  rowAt(r),
                ],
              ],
            ),
          );
        }

        // Room to breathe: spread the rows down it instead of leaving a dead
        // band under the grid. Capped so a tablet does not end up with rows
        // marooned at the extremes.
        final slack = available - natural;
        // Row gap tightened further, on request.
        final gap = (slack / (_rows + 1)).clamp(seatSize * 0.14, seatSize * 0.5);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: gap * 0.5),
              for (int r = 0; r < _rows; r++) ...[
                if (r > 0) SizedBox(height: gap),
                rowAt(r),
              ],
            ],
          ),
        );
      },
    );
  }
}
