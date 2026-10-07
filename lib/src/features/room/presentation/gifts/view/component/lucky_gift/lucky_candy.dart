import 'dart:async';
import 'dart:developer';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/lucky_log.dart';
import 'package:general/src/features/room/presentation/gifts/controller/lucky_gift_service.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_bottom_bar.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_user_only.dart';
import 'package:general/src/features/room/presentation/gifts/view/gift_room_page.dart';
import 'package:general/src/features/room/room.dart';

class LuckyCandy extends StatefulWidget {
  final EnterRoomModel roomData;
  final bool showData;
  final List<Color> gradientColors;

  const LuckyCandy({
    required this.roomData,
    super.key,
    required this.showData,
    required this.gradientColors,
  });

  @override
  LuckyCandyState createState() => LuckyCandyState();
}

class LuckyCandyState extends State<LuckyCandy> with TickerProviderStateMixin {
  late Timer requestTimer;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    LuckyGiftController.instance.tempLuckyGiftData.clear();

    // The network request is still BATCHED (1s combo): the backend's
    // ActionAbuseGuard caps lucky sends at 5/sec, and one HTTP call per tap
    // would hammer it. Each tap only increments numOfRequest; this timer flushes
    // the accumulated count once per second.
    requestTimer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (LuckyGiftController.instance.numOfRequest != 0) {
          LuckyGiftService.instance.sendGift(
            roomOwnerId: widget.roomData.ownerId.toString(),
          );
        }
      },
    );

    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 3), () {
      LuckyGiftService.instance.endAllLuckyGift();
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _scaleController.dispose();
    requestTimer.cancel();
    LuckyGiftController.instance.numOfRequest = 0;
    LuckyGiftController.instance.tempLuckyGiftData.clear();
    super.dispose();
  }

  /// One full round cost: P × m × N — the EXACT amount the backend deducts per
  /// candy tap (charged_total of one send). The promise == the charge.
  int _roundCost() {
    final price = GiftScreen.chosenGift?.price ?? 0;
    final num = GiftBottomBar.numberOfGift.value;
    final recipients = GiftUserOnly.userSelected != ""
        ? 1
        : (GiftUser.userSelected.value.isEmpty
            ? 1
            : GiftUser.userSelected.value.length);
    return price * num * recipients;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        // Count this tap for the batched network flush (requestTimer).
        LuckyGiftController.instance.numOfRequest++;
        // Fire ONE optimistic seat animation for THIS tap immediately, from
        // local state — the gift never waits on the network response, so every
        // tap shows its own candy in the same frame instead of a batched burst
        // after the server replies.
        _showOptimisticTapAnimation();
        _resetInactivityTimer();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: (widget.gradientColors.isNotEmpty
                          ? widget.gradientColors.first
                          : ColorManager.primary)
                      .withValues(alpha: 0.5),
                ),
                CircleAvatar(
                  radius: 35.r,
                  backgroundColor: (widget.gradientColors.isNotEmpty
                          ? widget.gradientColors.first
                          : ColorManager.primary)
                      .withValues(alpha: 0.8),
                ),
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: widget.gradientColors.isNotEmpty
                      ? widget.gradientColors.first
                      : ColorManager.primary,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorManager.white,
                        width: 2.w,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        StringManager.send.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: ColorManager.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
        ),
        SizedBox(height: 4.h),
        // Honest cost label: what ONE candy tap deducts.
        ValueListenableBuilder<int>(
          valueListenable: GiftBottomBar.numberOfGift,
          builder: (context, _, __) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '${StringManager.luckyCostPerSend.tr()}: ${_roundCost()}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: ColorManager.white, fontSize: 10.sp),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Fire ONE seat animation for the current tap, built entirely from local
  /// state (selected gift + selected recipients), without waiting on the
  /// backend. This is the SENDER's own feedback: the candy flies in the same
  /// frame as the tap. The win banner / balance / RTM re-broadcast still come
  /// from the backend response (foreground_widget), so this path uses
  /// `fromRtm: null` (no re-broadcast, no receiver banner) and `immediate: true`
  /// (the sender's own seats are already laid out — skip the render-box retry).
  void _showOptimisticTapAnimation() {
    if (!mounted) return;

    final ids = <String>[];
    final selectedIndexes = <int>[];

    // Resolve recipients from the live selection (single via GiftUserOnly, or
    // multi via GiftUser), then their CURRENT on-screen seat index from the
    // local kit map so the candy lands on the right seat.
    final selectedUserIds = <String>[];
    if (GiftUserOnly.userSelected.isNotEmpty) {
      selectedUserIds.add(GiftUserOnly.userSelected);
    } else {
      GiftUser.userSelected.value.forEach((_, obj) {
        if (obj.userId.isNotEmpty) selectedUserIds.add(obj.userId);
      });
    }

    for (final userId in selectedUserIds) {
      int? localSeatIndex;
      RoomScreenState.seatAvatarIds.forEach((seat, occupantId) {
        if (occupantId == userId) localSeatIndex = seat;
      });
      ids.add(userId);
      selectedIndexes.add(localSeatIndex ?? -1);
    }

    if (ids.isEmpty) {
      LuckyLog.write('LUCKYFLY: optimistic tap skipped — no recipient selected');
      return;
    }

    // Match the static gift thumbnail used everywhere else for the flying candy
    // (backend's gift_image == the gift list `img`).
    final image = GiftScreen.chosenGift?.img ?? "";

    log('🎁 LUCKYFLY: optimistic tap — selectedIndexes=$selectedIndexes, ids=$ids');
    LuckyLog.write('LUCKYFLY: optimistic tap — '
        'selectedIndexes=$selectedIndexes, ids=$ids');

    di<LuckyGiftAnaimationManagerBloc>().add(
      LuckyGiftAnaimationManagerEvent(
        // fromRtm:null → sender's OWN local animation only (no re-broadcast,
        // no receiver banner). immediate:true → resolve seats in one pass.
        fromRtm: null,
        immediate: true,
        index: selectedIndexes,
        ids: ids,
        image: image,
        totalWin: 0,
        reciverName: "",
        senderName: "",
        giftNum: GiftBottomBar.numberOfGift.value,
        senderImage: "",
        giftPriceT: 0,
        totalPk: 0,
      ),
    );
  }
}
