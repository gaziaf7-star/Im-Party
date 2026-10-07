import 'dart:ui' as ui;

import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/bloc/live_send_gift_bloc.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_recipients.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

/// Live-room gift send bar — the standalone counterpart of the audio room's
/// `GiftBottomBar`. Recipients come from [LiveGiftRecipients.userSelected]
/// (host + live guests), the normal send goes through [LiveSendGiftBloc] (which
/// broadcasts on the live channel), and lucky gifts bridge into the shared
/// lucky engine. Reuses the shared combo widgets (`NormalCandy`/`LuckyCandy`)
/// and the shared transaction statics (`GiftBottomBar.*`, `GiftScreen.chosenGift`).
class LiveGiftBottomBar extends StatefulWidget {
  const LiveGiftBottomBar({
    required this.roomData,
    required this.showData,
    required this.sizeFactor,
    required this.containerBackgroundColor,
    required this.containerTopPadding,
    required this.coinImageScale,
    required this.rechargeTextColor,
    required this.showRechargeArrow,
    required this.rechargeArrowColor,
    required this.sendButtonBorderWidth,
    required this.sendButtonBorderColor,
    required this.numberDropdownIconColor,
    required this.sendButtonGradientColors,
    required this.sendButtonBorderRadius,
    required this.dialogBackgroundColor,
    required this.dialogBorderColor,
    required this.selectionColor,
    required this.numberFormatPrefix,
    super.key,
  });

  final EnterRoomModel roomData;
  final bool showData;
  final double sizeFactor;
  final Color containerBackgroundColor;
  final double containerTopPadding;
  final double coinImageScale;
  final Color rechargeTextColor;
  final bool showRechargeArrow;
  final Color rechargeArrowColor;
  final double sendButtonBorderWidth;
  final Color sendButtonBorderColor;
  final Color numberDropdownIconColor;
  final List<Color> sendButtonGradientColors;
  final double sendButtonBorderRadius;
  final Color dialogBackgroundColor;
  final Color dialogBorderColor;
  final Color selectionColor;
  final String numberFormatPrefix;

  @override
  State<LiveGiftBottomBar> createState() => _LiveGiftBottomBarState();
}

class _LiveGiftBottomBarState extends State<LiveGiftBottomBar> {
  @override
  void initState() {
    getUserCoins();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LuckyGiftBannerBloc, LuckyGiftBannerState>(
      bloc: di<LuckyGiftBannerBloc>(),
      listener: (context, state) {
        if (state is SendLuckyGiftErrorStateState) {
          Methods.showToast(context, isError: true, message: state.error);
        }
      },
      child: BlocConsumer<LiveSendGiftBloc, LiveSendGiftState>(
        bloc: di<LiveSendGiftBloc>(),
        listener: (context, state) {
          if (state is LiveSendGiftSuccess) {
            GiftBottomBar.numberOfGift.value = 1;
          } else if (state is LiveSendGiftError) {
            Methods.showToast(context, message: state.error, isError: true);
            GiftBottomBar.numberOfGift.value = 1;
          } else if (state is LiveSendGiftLoading) {
            Methods.showToast(context, isLoading: true);
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: ui.TextDirection.ltr,
            child: ValueListenableBuilder<TypeCandy>(
              valueListenable: GiftBottomBar.typeCandy,
              builder: (context, typeCandy, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: typeCandy == TypeCandy.luckyCandy
                        ? ColorManager.transparent
                        : widget.containerBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    bottom: 5.h * widget.sizeFactor,
                    top: widget.containerTopPadding,
                  ),
                  child: Row(
                    children: [
                      if (widget.showData) ...[
                        const Spacer(flex: 1),
                        _coins(context),
                        5.wBox,
                        _recharge(context),
                      ],
                      Spacer(
                          flex: typeCandy == TypeCandy.luckyCandy ? 1 : 10),
                      if (typeCandy == TypeCandy.normalCandy)
                        NormalCandy(
                          sendGift: sendGift,
                          gradientColors: widget.sendButtonGradientColors,
                        )
                      else if (typeCandy == TypeCandy.luckyCandy)
                        LuckyCandy(
                          roomData: widget.roomData,
                          showData: widget.showData,
                          gradientColors: widget.sendButtonGradientColors,
                        )
                      else
                        _sendButton(context),
                      const Spacer(flex: 1),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ── Coins + recharge ──────────────────────────────────────────────────────

  Widget _coins(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(23.r * widget.sizeFactor),
          child:
              Image.asset(AssetsManager.coinPayment, scale: widget.coinImageScale),
        ),
        5.wBox,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.0 * widget.sizeFactor),
          child: ValueListenableBuilder<String>(
            valueListenable: RoomData.instance.myCoins,
            builder: (context, myCoins, _) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 10.w * widget.sizeFactor,
                  maxWidth: 100.w * widget.sizeFactor,
                ),
                child: FittedBox(
                  child: Text(
                    myCoins,
                    maxLines: 1,
                    style: context.bodyMedium
                        .colorExt(ColorManager.white)
                        .bold
                        .copyWith(fontSize: 14.sp * widget.sizeFactor),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _recharge(BuildContext context) {
    return ButtonWidget(
      onPressed: () => context.pushNamedRoute(Routes.coinsPage),
      title: Row(
        children: [
          TextWidget(
            StringManager.recharge.tr(),
            style: context.bodyLarge.w600
                .colorExt(widget.rechargeTextColor)
                .copyWith(fontSize: 12.sp * widget.sizeFactor * 1.3),
          ),
          if (widget.showRechargeArrow) ...[
            2.wBox,
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13.h * widget.sizeFactor, color: widget.rechargeArrowColor),
          ]
        ],
      ),
      backgroundColor: ColorManager.transparent,
      isFittedBox: false,
      paddingButton: context.paddingZero(),
      titleColor: ColorManager.orange,
      fontSize: 12.sp * widget.sizeFactor,
      width: 80.w * widget.sizeFactor,
      height: 30.h * widget.sizeFactor,
      radius: 8 * widget.sizeFactor,
    );
  }

  // ── Send button (count + send) ────────────────────────────────────────────

  Widget _sendButton(BuildContext context) {
    return Container(
      width: 130.w * widget.sizeFactor,
      height: 35.h * widget.sizeFactor,
      decoration: BoxDecoration(
        color: ColorManager.transparent,
        borderRadius: 30.radius,
        border: Border.all(
          width: widget.sendButtonBorderWidth,
          color: widget.sendButtonBorderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => showCustomDialog(
                context: context,
                widget: _countDialog(context),
              ),
              child: Row(
                mainAxisAlignment: widget.sizeFactor < 1.0
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: GiftBottomBar.numberOfGift,
                    builder: (context, value, _) => Text(
                      value.toString(),
                      style: context.bodyMedium
                          .size(16 * widget.sizeFactor)
                          .colorExt(ColorManager.whiteColor),
                    ),
                  ),
                  5.wBox,
                  Icon(Icons.keyboard_arrow_down,
                      color: widget.numberDropdownIconColor,
                      size: 18.sp * widget.sizeFactor),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<GiftBloc, GiftState>(
              bloc: di<GiftBloc>(),
              buildWhen: (prev, curr) =>
                  prev.isDownloadingGift != curr.isDownloadingGift,
              builder: (context, giftState) {
                final isDownloading = giftState.isDownloadingGift;
                return Container(
                  decoration: BoxDecoration(
                    gradient: widget.sendButtonGradientColors.isNotEmpty
                        ? LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: isDownloading
                                ? [
                                    ColorManager.grey.withValues(alpha: 0.75),
                                    ColorManager.grey.withValues(alpha: 0.95),
                                    ColorManager.grey,
                                    ColorManager.grey.withValues(alpha: 0.85),
                                  ]
                                : widget.sendButtonGradientColors,
                            stops:
                                isDownloading ? const [0.0, 0.35, 0.6, 1.0] : null,
                          )
                        : null,
                    color: widget.sendButtonGradientColors.isEmpty
                        ? (isDownloading
                            ? ColorManager.grey
                            : ColorManager.primary)
                        : null,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(widget.sendButtonBorderRadius),
                      bottomRight:
                          Radius.circular(widget.sendButtonBorderRadius),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(widget.sendButtonBorderRadius),
                      bottomRight:
                          Radius.circular(widget.sendButtonBorderRadius),
                    ),
                    onTap: isDownloading ? null : () => _onSendTapped(context),
                    child: Center(
                      child: Text(
                        StringManager.send.tr(),
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .colorExt(ColorManager.buttonTextColor)
                            .copyWith(fontSize: 14.sp * widget.sizeFactor),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSendTapped(BuildContext context) {
    if (!HomePage.isConnectToInternet) {
      showDialog(
        context: context,
        builder: (_) => AnimatedDialog(
          title: StringManager.noConnection.tr(),
          description: StringManager.internetConnection.tr(),
          needPopScope: false,
          isHideConfirm: true,
          cancelText: StringManager.cancel.tr(),
          isUpdateDialog: true,
          onTapCancel: () => Navigator.pop(context),
        ),
      );
      return;
    }
    if (LiveGiftRecipients.userSelected.value.isEmpty) {
      Methods.showToast(context,
          isError: true, message: StringManager.noUsersSelected.tr());
      return;
    }
    if (GiftScreen.chosenGift == null) {
      Methods.showToast(context,
          isError: true, message: StringManager.noGiftSelected.tr());
      return;
    }

    final isLuckyGift = GiftScreen.chosenGift?.type == 'lucky_gift' ||
        GiftBottomBar.giftType == TypeGift.lucky;
    if (isLuckyGift) {
      _startLuckyGift(context);
    } else {
      if (ConstantsManager.isVariantBuildA) {
        Navigator.pop(context);
        sendGift(1);
      } else {
        GiftBottomBar.typeCandy.value = TypeCandy.normalCandy;
      }
    }
  }

  /// Bridges the live recipient selection into the shared store the lucky engine
  /// reads (`GiftUser.userSelected`), then drives the shared lucky service.
  void _startLuckyGift(BuildContext context) {
    GiftUser.userSelected.value = {
      for (final e in LiveGiftRecipients.userSelected.value.entries)
        e.key: SelectedObject(
            userId: e.value.id, name: e.value.name, selected: true),
    };

    // Affordability of one full round (P × m × N) checked BEFORE the first
    // send — the old order fired the request first and only then decided
    // whether to show the candy.
    final selectedGiftPrice = GiftScreen.chosenGift?.price ?? 0;
    final numberOfGifts = GiftBottomBar.numberOfGift.value;
    final myCoins = int.tryParse(RoomData.instance.myCoins.value) ?? 0;
    final recipientCount = LiveGiftRecipients.userSelected.value.isEmpty
        ? 1
        : LiveGiftRecipients.userSelected.value.length;
    final roundCost = selectedGiftPrice * numberOfGifts * recipientCount;

    if (roundCost > myCoins) {
      Methods.showToast(context,
          isError: true, message: StringManager.goRecharge.tr());
      return;
    }

    LuckyGiftController.instance.numOfRequest = 1;
    LuckyGiftService.instance.resetGuard();
    LuckyGiftService.instance.startCombo();
    LuckyGiftService.instance.sendGift(roomOwnerId: '${widget.roomData.ownerId}');
    GiftBottomBar.typeCandy.value = TypeCandy.luckyCandy;
  }

  // ── Normal send (live channel) ────────────────────────────────────────────

  void sendGift(int? compoNum) {
    final selectedGiftPrice = GiftScreen.chosenGift?.price ?? 0;
    final numberOfGifts = GiftBottomBar.numberOfGift.value;
    final myCoins = int.tryParse(RoomData.instance.myCoins.value) ?? 0;

    final selected = LiveGiftRecipients.userSelected.value;
    final userSelected = selected.values.map((u) => u.id).toList();
    final userSelectedName = selected.values.map((u) => u.name).toList();
    final toUid = userSelected.join(',');

    if (userSelected.isEmpty) {
      Methods.showToast(context,
          isError: true, message: StringManager.noUsersSelected.tr());
      return;
    }

    final isBag = GiftBottomBar.giftType == TypeGift.bag;
    if (((selectedGiftPrice * numberOfGifts * userSelected.length) <= myCoins) ||
        isBag) {
      final num = (compoNum != null
              ? compoNum * GiftBottomBar.numberOfGift.value
              : GiftBottomBar.numberOfGift.value)
          .toString();
      di<LiveSendGiftBloc>().add(
        LiveSendGiftEvent(
          roomId: widget.roomData.id.toString(),
          id: di<GiftBloc>().state.giftId.toString(),
          toUid: toUid,
          num: num,
          typeGift: GiftBottomBar.giftType.value,
          userSelected: userSelected,
          userSelectedName: userSelectedName,
          selectedGiftPrice: selectedGiftPrice,
          numberOfGifts: numberOfGifts,
          myCoins: myCoins,
          giftData: GiftScreen.chosenGift,
        ),
      );
    } else {
      Methods.showToast(context,
          isError: true, message: StringManager.goRecharge.tr());
    }
  }

  Widget _countDialog(BuildContext context) {
    final numbers = [1, 5, 9, 99, 999, 9999];
    String formatNumber(int n) => widget.numberFormatPrefix.isEmpty
        ? '$n'
        : '$n${widget.numberFormatPrefix}';
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.235,
        margin: context.paddingOnly(bottom: 45, start: 150),
        width: 100.w,
        decoration: BoxDecoration(
          borderRadius: 5.radius,
          color: widget.dialogBackgroundColor,
          border: Border.all(color: widget.dialogBorderColor),
        ),
        child: Column(
          children: numbers.map((giftNum) {
            return InkWell(
              onTap: () {
                GiftBottomBar.numberOfGift.value = giftNum;
                Navigator.pop(context);
              },
              child: Container(
                padding: context.paddingAll(5),
                child: Center(
                  child: ValueListenableBuilder<int>(
                    valueListenable: GiftBottomBar.numberOfGift,
                    builder: (context, value, _) => Text(
                      formatNumber(giftNum),
                      style: TextStyle(
                        color: value == giftNum
                            ? widget.selectionColor
                            : ColorManager.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
