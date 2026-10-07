import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class ChooseModeRoom extends StatelessWidget {
  final String roomId;
  final String modeRoom;
  // Cinema + PK are presented here as extra "modes" (owner spec). Their full
  // activation logic stays in the caller (basic_tool) and is invoked via these
  // callbacks; null hides the card.
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
  Widget build(BuildContext context) {
    final controller = RoomData.instance.utdController;
    if (controller == null) return const SizedBox.shrink();

    final allModes = controller.registeredModes
        .where((m) => m.id != '5')
        .toList();
    final isCinemaOn = RoomData.instance.room.mode == '5';

    return Container(
      padding: context.paddingSymmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: 0.8),
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height / 1.8,
        child: Column(
          children: [
            Container(
              height: 46.h,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: 10.radiusCircular, topRight: 10.radiusCircular),
                color: ColorManager.transparent,
              ),
              child: Center(
                child: Text(
                  StringManager.choosePreferableMicMode.tr(),
                  style: context.bodyMedium
                      .size(13)
                      .w500
                      .colorExt(ColorManager.textPrimary),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment.center,
                  children: [
                    ...allModes.map((mode) {
                      final isSelected = modeRoom == mode.id;
                      return _ModeCard(
                        mode: mode,
                        isSelected: isSelected,
                        onTap: () {
                          controller.seatController.setupSeats(
                            identity: MyDataModel.getInstance().id.toString(),
                            seatCount: mode.seatCount,
                            seatMode: controller.seatController.seatMode.value,
                            modeId: mode.id,
                          );
                          Navigator.pop(context);
                        },
                      );
                    }),
                    // Cinema as a selectable mode.
                    if (onCinemaTap != null)
                      _SpecialModeCard(
                        label: StringManager.cinemaMode.tr(),
                        icon: Icons.movie_outlined,
                        isSelected: isCinemaOn,
                        onTap: () {
                          Navigator.pop(context);
                          onCinemaTap!();
                        },
                      ),
                    // PK as a selectable mode.
                    if (onPkTap != null)
                      _SpecialModeCard(
                        label: StringManager.pk.tr(),
                        icon: Icons.sports_kabaddi,
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          onPkTap!();
                        },
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final UTDRoomMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 24 - 32 - 24) / 2;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth,
        height: cardWidth * 1.2,
        decoration: BoxDecoration(
          borderRadius: 12.radius,
          color: isSelected
              ? ColorManager.textForgetColor.withValues(alpha: 0.15)
              : ColorManager.white.withValues(alpha: 0.06),
          border: Border.all(
            color: isSelected
                ? ColorManager.textForgetColor
                : ColorManager.white.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: _SeatPreview(mode: mode, isSelected: isSelected),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                (mode.displayName ?? mode.id).tr(),
                style: context.bodyMedium.size(9).w500.colorExt(
                      isSelected
                          ? ColorManager.white
                          : ColorManager.white.withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A non-seat "mode" card (cinema / PK) shown alongside the seat-layout modes.
class _SpecialModeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpecialModeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 24 - 32 - 24) / 2;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth,
        height: cardWidth * 1.2,
        decoration: BoxDecoration(
          borderRadius: 12.radius,
          color: isSelected
              ? ColorManager.textForgetColor.withValues(alpha: 0.15)
              : ColorManager.white.withValues(alpha: 0.06),
          border: Border.all(
            color: isSelected
                ? ColorManager.textForgetColor
                : ColorManager.white.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: ColorManager.white.withValues(alpha: 0.85),
                size: 34.h),
            8.hBox,
            Text(
              label,
              style: context.bodyMedium.size(10).w500.colorExt(
                    isSelected
                        ? ColorManager.white
                        : ColorManager.white.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatPreview extends StatelessWidget {
  final UTDRoomMode mode;
  final bool isSelected;

  const _SeatPreview({required this.mode, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // The dot was a fixed 20x20, which fits the 4-wide layouts the picker
    // originally had and overflows the card the moment a mode is 6 wide and 5
    // deep. Sizing from the densest row and the row count instead means the
    // preview stays inside the card for any layout, including the 30-seat one.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = mode.rows.fold<int>(1, (m, r) => r.length > m ? r.length : m);
        final rowCount = mode.rows.length;
        const gap = 2.0;
        final byWidth = (constraints.maxWidth - gap * 2 * columns) / columns;
        final byHeight = (constraints.maxHeight - gap * 2 * rowCount) / rowCount;
        final dot = byWidth < byHeight ? byWidth : byHeight;
        return _gridPreview(rows: mode.rows, dot: dot.clamp(4.0, 20.0), gap: gap);
      },
    );
  }

  Widget _dot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.4),
      ),
      child: Center(
        child: Image.asset(
          AssetsManager.seat,
          width: size * 0.5,
          height: size * 0.5,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _gridPreview({
    required List<List<int>> rows,
    required double dot,
    required double gap,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: gap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((_) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: _dot(dot),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
