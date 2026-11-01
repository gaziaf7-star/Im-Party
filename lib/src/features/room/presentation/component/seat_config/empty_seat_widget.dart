import 'dart:io';
import 'package:general/src/features/room/presentation/component/seat_config/charisma_badge_widget.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_metrics.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_mute_badge.dart';
import 'package:general/src/features/room/room.dart';

class EmptySeat extends StatelessWidget {
  final int index;

  /// The full seat slot size provided by the audio-room kit. The image is sized
  /// to [SeatMetrics.avatar] — the SAME shared source the occupied avatar and
  /// the locked seat use — so all seat states match exactly. It is wrapped in
  /// [Flexible] so it shrinks when the slot is too small (e.g. seat8 mode) to
  /// leave room for the index label — otherwise the column overflows the tight
  /// square the kit lays the seat out in.
  final double size;

  const EmptySeat({super.key, required this.index, required this.size});

  /// The empty-seat glyph, filling the full seat-avatar size with no
  /// background disc/container behind it (the seat icon art stands on its
  /// own now, on request).
  Widget _emptyDisc(SeatMetrics m, Widget glyph) {
    return SizedBox(width: m.avatar, height: m.avatar, child: glyph);
  }

  @override
  Widget build(BuildContext context) {
    final m = SeatMetrics.forSeat(size);
    return ValueListenableBuilder<bool>(
      valueListenable: PkController.showPK,
      builder: (context, isPK, _) {
        if (isPK) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SizedBox(
                    width: m.avatar,
                    height: m.avatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child:
                              (PkController.isPK.value &&
                                      PkController.isTeam1Seat(index))
                                  ? Image.asset(
                                    AssetsManager.team1,
                                    fit: BoxFit.contain,
                                  )
                                  : (PkController.isPK.value &&
                                      PkController.isTeam2Seat(index))
                                  ? Image.asset(
                                    AssetsManager.team2,
                                    fit: BoxFit.contain,
                                  )
                                  : _emptyDisc(
                                    m,
                                    // The generated sofa is already coloured to match
                                    // the ring; tinting it would flatten it back to
                                    // the grey vendor glyph this replaced.
                                    Image.asset(
                                      AssetsManager.seatSofa,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (_, __, ___) => Image.asset(
                                            AssetsManager.seat,
                                            color: ColorManager.onDark
                                                .withValues(alpha: 0.55),
                                            fit: BoxFit.contain,
                                          ),
                                    ),
                                  ),
                        ),
                        AllMuteSeatBadge(avatarSize: m.avatar),
                      ],
                    ),
                  ),
                ),
              ),
              _SeatFooter(index: index, metrics: m),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SizedBox(
                    width: m.avatar,
                    height: m.avatar,
                    // A room-specific seat skin, when the owner has set one,
                    // still wins: it is chosen art and must not be covered by
                    // the default ring.
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child:
                              Methods.getMicImageOpen() != null
                                  ? ClipOval(
                                    child: Image.file(
                                      File(Methods.getMicImageOpen() ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : _emptyDisc(
                                    m,
                                    Image.asset(
                                      AssetsManager.seatSofa,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (_, __, ___) => Image.asset(
                                            AssetsManager.seat,
                                            color: ColorManager.onDark
                                                .withValues(alpha: 0.55),
                                            fit: BoxFit.contain,
                                          ),
                                    ),
                                  ),
                        ),
                        AllMuteSeatBadge(avatarSize: m.avatar),
                      ],
                    ),
                  ),
                ),
              ),
              _SeatFooter(index: index, metrics: m),
            ],
          );
        }
      },
    );
  }
}

/// The seat's bottom line: its number.
///
/// This briefly carried an Apply pill under EVERY empty seat in view mode. That
/// was wrong twice over: it repeated one action up to thirty times, and it
/// implied you were applying for *that* seat when the backend seats an approved
/// applicant in whichever seat is free (`SpeakerService::approve` falls back to
/// `firstFreeSeat` for a request that names none). There is now a single Apply
/// control under the boom -- see `foreground_widget.dart`.
class _SeatFooter extends StatelessWidget {
  final int index;
  final SeatMetrics metrics;

  const _SeatFooter({required this.index, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${index + 1}",
          textAlign: TextAlign.center,
          style: context.bodyMedium
              .copyWith(fontSize: metrics.indexFont)
              .w400
              .colorExt(ColorManager.onDark),
        ),
        // Same line as occupied seats, so all seats keep one height.
        CharismaValueLine(
          userId: '',
          fontSize: metrics.charismaFont,
          iconSize: metrics.charismaIcon,
        ),
      ],
    );
  }
}
