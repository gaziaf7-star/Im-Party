import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/coins_lucky_box.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/quantity_users_box.dart';
import 'package:general/src/features/room/room.dart';
// Only needed while the tab bar (commented out below) is back in use.
// import 'tab_bar_body.dart';

class LuckyBoxContent extends StatefulWidget {
  const LuckyBoxContent({
    super.key,
    required this.luckyBoxEntity,
    required this.room,
  });
  final LuckyBoxEntity? luckyBoxEntity;
  final EnterRoomModel room;
  @override
  State<LuckyBoxContent> createState() => LuckyBoxContentState();
}

class LuckyBoxContentState extends State<LuckyBoxContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // RoomData.instance.myCoins can still be empty at this point if this
    // sheet is opened right after entering the room (the room's own
    // startup fetch may not have landed yet). Same fix GiftBottomBar uses:
    // fetch the live balance directly instead of trusting whatever value
    // happened to already be in the notifier.
    getUserCoins();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Color _labelColor = Color(0xFF3A2410);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LuckyBoxBloc, LuckyBoxState>(
      bloc: di<LuckyBoxBloc>(),
      buildWhen: (prev, curr) =>
          prev.isLuckyBoxTap != curr.isLuckyBoxTap ||
          prev.luckyBoxList != curr.luckyBoxList ||
          prev.luckyBoxItem != curr.luckyBoxItem ||
          prev.superBoxCoins != curr.superBoxCoins ||
          prev.luckyBoxQuantity != curr.luckyBoxQuantity,
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: LuckyBoxVariables.notifierTypeBox,
          // Full-width sheet, sized to its content (no forced screen
          // fraction / no Spacer chewing up the leftover space) so it
          // stays compact instead of leaving a big empty gap above the
          // Send button.
          builder: (context, value, child) => Container(
            width: double.infinity,

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.redAccount,
                  ColorManager.orange,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: 15.radiusCircular,
                topRight: 15.radiusCircular,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header bar -- "Record >" / title / "?" help. Sits directly
                // on the OUTER gradient wrapper (not inside the white card
                // below), so it stays a flat rectangle in its own right --
                // only the outer wrapper's radius softens its very top
                // corners, matching the reference design where the header
                // and the white content card are two visually separate
                // pieces.
                Container(
                  height: 50.h,
                  width: double.infinity,
                  padding: context.paddingSymmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.redAccount,
                        ColorManager.orange,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              StringManager.record.tr(),
                              style: context.bodySmall.w600
                                  .colorExt(ColorManager.white),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: ColorManager.white,
                              size: 16.h,
                            ),
                          ],
                        ),
                        Text(
                          StringManager.luckyBox.tr(),
                          style: context.titleLarge.w700
                              .colorExt(ColorManager.yellow),
                        ),
                        Icon(
                          Icons.help_outline,
                          color: ColorManager.white.withValues(alpha: 0.85),
                          size: 20.h,
                        ),
                      ],
                    ),
                  ),
                // White content card -- its OWN top radius, separate from
                // the header above it.
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                      padding: context.paddingSymmetric(
                        horizontal: 19,
                        vertical: 14,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringManager.coins_.tr(),
                            style: context.bodySmall.w600.colorExt(_labelColor),
                          ),
                          // Detect Coins
                          6.hBox,
                          CoinsLuckyBox(
                            boxes: state.isLuckyBoxTap == true
                                ? widget.luckyBoxEntity?.normalBox ?? []
                                : widget.luckyBoxEntity?.superBox ?? [],
                          ),
                          if (state.isLuckyBoxTap != true) ...[
                            30.hBox,
                            Align(
                              alignment: AlignmentDirectional.topCenter,
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                height: 40.h,
                                padding: context.paddingAll(3),
                                decoration: BoxDecoration(
                                  borderRadius: 30.radius,
                                  border:
                                      Border.all(color: ColorManager.whiteColor),
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorManager.redAccount,
                                      ColorManager.whiteColor
                                          .withValues(alpha: 0.5),
                                      ColorManager.whiteColor
                                          .withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    5.wBox,
                                    UserImage(
                                      image:
                                          '${MyDataModel.getInstance().profile?.image}',
                                      displayName:
                                          MyDataModel.getInstance().name ?? '',
                                      imageSize: 35.h,
                                      borderRadius: 30.radius,
                                    ),
                                    10.wBox,
                                    Text(
                                      "ID: ${MyDataModel.getInstance().uuid}",
                                      style: context.bodyLarge
                                          .colorExt(ColorManager.darkYellow),
                                    ),
                                    10.wBox,
                                    Text(
                                      StringManager.sendASuperLuck.tr(),
                                      style: context.titleLarge.w400
                                          .colorExt(ColorManager.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            10.hBox,
                            Align(
                              alignment: AlignmentDirectional.topCenter,
                              child: Text(
                                StringManager
                                    .superLuckyBagWillBeDisplayedInAllRoom
                                    .tr(),
                                style: context.bodyLarge.colorExt(_labelColor),
                              ),
                            ),
                          ],
                          20.hBox,
                          if (state.isLuckyBoxTap == true)
                            Text(StringManager.quantity.tr(),
                                style: context.bodySmall.w600
                                    .colorExt(_labelColor)),
                          // Detect Quantity
                          if (state.isLuckyBoxTap == true) 8.hBox,
                          if (state.isLuckyBoxTap == true &&
                              (state.luckyBoxList ?? []).isNotEmpty)
                            QuantityUsersBox(
                              boxes: state.luckyBoxList ?? [],
                            ),
                          16.hBox,
                          // Send Button -- design left untouched on request.
                          if (((state.luckyBoxItem ?? '').isNotEmpty &&
                                  state.isLuckyBoxTap == true) ||
                              (state.isLuckyBoxTap == false &&
                                  (state.superBoxCoins ?? '').isNotEmpty))
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Align(
                                alignment: AlignmentDirectional.bottomCenter,
                                child: MultiTapCard(
                                  // No local pre-checks (coins/quantity empty) on
                                  // request -- Send always calls the real API and lets
                                  // the server be the sole source of truth, instead of
                                  // a client-side guess blocking the request.
                                  onTap: () {
                                    if ((state.superBoxCoins ?? '').isNotEmpty &&
                                        state.isLuckyBoxTap == false) {
                                      di<LuckyBoxBloc>().add(
                                        SendLuckyBoxEvent(
                                          boxId: (widget.luckyBoxEntity
                                                          ?.superBox ??
                                                      [])
                                                  .isNotEmpty
                                              ? widget
                                                  .luckyBoxEntity!
                                                  .superBox[state
                                                          .indexItemSelectedSuper ??
                                                      0]
                                                  .id
                                                  .toString()
                                              : '0',
                                          roomId: widget.room.id.toString(),
                                          quantity: (widget
                                                          .luckyBoxEntity
                                                          ?.superBox ??
                                                      [])
                                                  .isNotEmpty
                                              ? widget
                                                  .luckyBoxEntity!
                                                  .superBox[state
                                                          .indexItemSelectedSuper ??
                                                      0]
                                                  .userNum
                                                  .toString()
                                              : '0',
                                        ),
                                      );
                                    } else {
                                      di<LuckyBoxBloc>().add(
                                        SendLuckyBoxEvent(
                                          boxId: (widget.luckyBoxEntity
                                                          ?.normalBox ??
                                                      [])
                                                  .isNotEmpty
                                              ? widget
                                                  .luckyBoxEntity!
                                                  .normalBox[state
                                                          .indexItemSelectedNormal ??
                                                      0]
                                                  .id
                                                  .toString()
                                              : '0',
                                          roomId: widget.room.id.toString(),
                                          quantity: state.luckyBoxQuantity ?? '',
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.h,
                                    padding: EdgeInsetsDirectional.all(7.h),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          AssetsManager.sendBackground,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        StringManager.send.tr(),
                                        style: context.titleLarge
                                            .colorExt(ColorManager.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          10.hBox,
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              textAlign: TextAlign.center,
                              StringManager.goldCoins.tr(),
                              style:
                                  context.bodyMedium.colorExt(_labelColor),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              (state.isLuckyBoxTap ?? true)
                                  ? "${StringManager.boxTime.tr()} "
                                      "${(widget.luckyBoxEntity?.normalBox != null && (state.indexItemSelectedNormal ?? 0) < (widget.luckyBoxEntity?.normalBox.length ?? 0)) ? widget.luckyBoxEntity?.normalBox[state.indexItemSelectedNormal ?? 0].time : "0"} (${StringManager.hours.tr()})"
                                  : "${StringManager.boxTime.tr()} "
                                      "${(widget.luckyBoxEntity?.superBox != null && (state.indexItemSelectedSuper ?? 0) < (widget.luckyBoxEntity?.superBox.length ?? 0)) ? widget.luckyBoxEntity?.superBox[state.indexItemSelectedSuper ?? 0].time : "0"} ${StringManager.minutes.tr()}",
                              style: context.bodyMedium.colorExt(_labelColor),
                            ),
                          ),
                          8.hBox,
                          // Current coin balance + tap-to-recharge, same pattern
                          // as the gift bottom bar (gift_bottom_bar.dart).
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(23),
                                  child: Image.asset(
                                    AssetsManager.coinPayment,
                                    scale: 3,
                                  ),
                                ),
                                5.wBox,
                                ValueListenableBuilder<String>(
                                  valueListenable: RoomData.instance.myCoins,
                                  builder: (context, myCoins, _) => Text(
                                    myCoins,
                                    style: context.bodyMedium.w600
                                        .colorExt(_labelColor),
                                  ),
                                ),
                                10.wBox,
                                MultiTapCard(
                                  onTap: () =>
                                      context.pushNamedRoute(Routes.coinsPage),
                                  child: Row(
                                    children: [
                                      Text(
                                        StringManager.recharge.tr(),
                                        style: context.bodyMedium.w600
                                            .colorExt(ColorManager.red),
                                      ),
                                      2.wBox,
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12.h,
                                        color: ColorManager.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          8.hBox,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }
}






