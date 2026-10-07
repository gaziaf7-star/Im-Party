import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/room_header/exit_room/exit_panel.dart';

/// Side-panel presentation for [ExitPanel].
///
/// Renders the "المزيد من الغرف" list as a partial-width drawer that slides in
/// from the start edge, leaving the audio room visible behind the panel on the
/// remaining edge. Tapping that exposed edge (the scrim) dismisses the panel.
///
/// The whole overlay is forced to RTL, so the start edge is the right side: the
/// panel pins to the right and the scrim (through which the room shows) is on
/// the left. Use [show] instead of `showModalBottomSheet`; it drives the
/// slide-in/out via [showGeneralDialog] so the panel content stays untouched.
class ExitSidePanelOverlay extends StatelessWidget {
  /// Fraction of the screen width the panel occupies; the rest stays the
  /// tap-to-dismiss scrim through which the room is visible.
  // Narrowed on request (was 0.82) -- more of the room shows through.
  static const double _panelWidthFactor = 0.74;

  final Animation<double> animation;

  const ExitSidePanelOverlay({required this.animation, super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: StringManager.moreRooms.tr(),
      barrierColor: ColorManager.transparent,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, animation, __) =>
          ExitSidePanelOverlay(animation: animation),
      transitionBuilder: (_, animation, __, child) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final panelWidth = MediaQuery.sizeOf(context).width * _panelWidthFactor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // Scrim over the room-visible edge — tap to dismiss.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: FadeTransition(
                opacity: curved,
                child: ColoredBox(
                  color: ColorManager.black.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          // Side panel: pinned to the start (right) edge, partial width, full
          // height, sliding in from off-screen toward that edge.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: SizedBox(
                width: panelWidth,
                height: double.infinity,
                child: const ExitPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}