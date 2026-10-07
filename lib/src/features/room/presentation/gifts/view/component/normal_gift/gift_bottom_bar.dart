import 'dart:ui' as ui;

import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/presentation/bloc/send_moment_gift_bloc/send_moment_gift_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_event.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

class GiftBottomBar extends StatefulWidget {
  const GiftBottomBar({
    required this.roomData,
    required this.showData,
    required this.isRoom,
    this.momentId,
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
  final bool isRoom;
  final String? momentId;
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

  static ValueNotifier<int> numberOfGift = ValueNotifier(1);
  static TypeGift giftType = TypeGift.normal;
  static ValueNotifier<TypeCandy> typeCandy = ValueNotifier(TypeCandy.non);

  @override
  State<GiftBottomBar> createState() => _GiftBottomBarState();
}

class _GiftBottomBarState extends State<GiftBottomBar> {
  bool _closeSheetAfterSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadUserCoins();
  }

  Future<void> _loadUserCoins() async {
    try {
      await getUserCoins();
    } catch (error) {
      Methods.printLog(
        'GiftBottomBar getUserCoins failed: ${NetworkExceptions.getErrorMessage(NetworkExceptions.getDioException(error))}',
      );
    }
  }

  @override
  void dispose() {
    GiftUserOnly.userSelected = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LuckyGiftBannerBloc, LuckyGiftBannerState>(
      bloc: di<LuckyGiftBannerBloc>(),
      listener: (context, state) {
        if (state is SendLuckyGiftErrorStateState) {
          Methods.showToast(
            context,
            isError: true,
            message: state.error,
          );
        }
      },
      child: BlocConsumer<SendGiftBloc, SendGiftStates>(
        bloc: di<SendGiftBloc>(),
        builder: (context, state) {
          return Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Builder(builder: (context) {
              return Container(
                decoration: BoxDecoration(
                  color: GiftBottomBar.typeCandy.value == TypeCandy.luckyCandy
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (widget.showData) ...[
                      const Spacer(flex: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(23.r * widget.sizeFactor),
                            child: Image.asset(
                              AssetsManager.coinPayment,
                              scale: widget.coinImageScale,
                            ),
                          ),
                          5.wBox,
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.0 * widget.sizeFactor),
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
                                      style: context.bodyMedium
                                          .colorExt(ColorManager.white)
                                          .bold
                                          .copyWith(
                                          fontSize:
                                          14.sp * widget.sizeFactor),
                                      maxLines: 1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      5.wBox,
                      ButtonWidget(
                        onPressed: () =>
                            context.pushNamedRoute(Routes.coinsPage),
                        title: Row(
                          children: [
                            TextWidget(
                              StringManager.recharge.tr(),
                              style: context.bodyLarge.w600
                                  .colorExt(widget.rechargeTextColor)
                                  .copyWith(
                                  fontSize:
                                  12.sp * widget.sizeFactor * 1.3),
                            ),
                            if (widget.showRechargeArrow) ...[
                              2.wBox,
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13.h * widget.sizeFactor,
                                color: widget.rechargeArrowColor,
                              ),
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
                      ),
                    ],
                    Spacer(
                        flex: GiftBottomBar.typeCandy.value ==
                            TypeCandy.luckyCandy
                            ? 1
                            : 10),
                    // Candy / Gift Section
                    ValueListenableBuilder<TypeCandy>(
                      valueListenable: GiftBottomBar.typeCandy,
                      builder: (context, typeCandy, _) {
                        if (typeCandy == TypeCandy.normalCandy) {
                          return NormalCandy(
                            sendGift: widget.isRoom ? sendGift : sendMomentGift,
                            isMoment: !widget.isRoom,
                            gradientColors: widget.sendButtonGradientColors,
                          );
                        } else if (typeCandy == TypeCandy.luckyCandy) {
                          return LuckyCandy(
                            roomData: widget.roomData,
                            showData: widget.showData,
                            gradientColors: widget.sendButtonGradientColors,
                          );
                        } else {
                          // Custom Gift Button
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
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      showCustomDialog(
                                        context: context,
                                        widget: sendDialog(context),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              12.r * widget.sizeFactor),
                                          bottomLeft: Radius.circular(
                                              12.r * widget.sizeFactor),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        widget.sizeFactor < 1.0
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          ValueListenableBuilder<int>(
                                            valueListenable:
                                            GiftBottomBar.numberOfGift,
                                            builder: (context, index, _) {
                                              return Text(
                                                GiftBottomBar.numberOfGift.value
                                                    .toString(),
                                                style: context.bodyMedium
                                                    .size(
                                                    16 * widget.sizeFactor)
                                                    .colorExt(ColorManager
                                                    .whiteColor),
                                              );
                                            },
                                          ),
                                          5.wBox,
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color:
                                            widget.numberDropdownIconColor,
                                            size: 18.sp * widget.sizeFactor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: BlocBuilder<GiftBloc, GiftState>(
                                    bloc: di<GiftBloc>(),
                                    buildWhen: (prev, curr) =>
                                    prev.isDownloadingGift !=
                                        curr.isDownloadingGift,
                                    builder: (context, giftState) {
                                      final isDownloading =
                                          giftState.isDownloadingGift;
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: widget
                                              .sendButtonGradientColors
                                              .isNotEmpty
                                              ? LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: isDownloading
                                                ? [
                                              ColorManager.grey
                                                  .withValues(
                                                  alpha: 0.75),
                                              ColorManager.grey
                                                  .withValues(
                                                  alpha: 0.95),
                                              ColorManager.grey,
                                              ColorManager.grey
                                                  .withValues(
                                                  alpha: 0.85),
                                            ]
                                                : widget
                                                .sendButtonGradientColors,
                                            stops: isDownloading
                                                ? const [
                                              0.0,
                                              0.35,
                                              0.6,
                                              1.0
                                            ]
                                                : null,
                                          )
                                              : null,
                                          color: widget.sendButtonGradientColors
                                              .isEmpty
                                              ? (isDownloading
                                              ? ColorManager.grey
                                              : ColorManager.primary)
                                              : null,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(
                                                widget.sendButtonBorderRadius),
                                            bottomRight: Radius.circular(
                                                widget.sendButtonBorderRadius),
                                          ),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(
                                                widget.sendButtonBorderRadius),
                                            bottomRight: Radius.circular(
                                                widget.sendButtonBorderRadius),
                                          ),
                                          onTap: isDownloading
                                              ? null
                                              : () {
                                            if (!HomePage
                                                .isConnectToInternet) {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    AnimatedDialog(
                                                      title: StringManager
                                                          .noConnection
                                                          .tr(),
                                                      description: StringManager
                                                          .internetConnection
                                                          .tr(),
                                                      needPopScope: false,
                                                      isHideConfirm: true,
                                                      cancelText:
                                                      StringManager.cancel
                                                          .tr(),
                                                      isUpdateDialog: true,
                                                      onTapCancel: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                              );
                                              return;
                                            }
                                            if (GiftUser.userSelected
                                                .value.isEmpty) {
                                              Methods.showToast(
                                                context,
                                                isError: true,
                                                message: StringManager
                                                    .noUsersSelected
                                                    .tr(),
                                              );
                                              return;
                                            }
                                            if (GiftScreen.chosenGift ==
                                                null) {
                                              Methods.showToast(
                                                context,
                                                isError: true,
                                                message: StringManager
                                                    .noGiftSelected
                                                    .tr(),
                                              );
                                              return;
                                            }
                                            // Check if it's a lucky gift based on the chosen gift's type
                                            final isLuckyGift = GiftScreen
                                                .chosenGift
                                                ?.type ==
                                                'lucky_gift' ||
                                                GiftBottomBar.giftType ==
                                                    TypeGift.lucky;
                                            if (isLuckyGift) {
                                              // Affordability of one full
                                              // round (P × m × N) BEFORE
                                              // the first send — the old
                                              // order fired the request
                                              // first, then checked.
                                              final selectedGiftPrice =
                                                  GiftScreen.chosenGift
                                                      ?.price ??
                                                      0;
                                              final numberOfGifts =
                                                  GiftBottomBar
                                                      .numberOfGift.value;
                                              final myCoins =
                                                  int.tryParse(RoomData
                                                      .instance
                                                      .myCoins
                                                      .value) ??
                                                      0;
                                              List<String> userSelected =
                                              [];
                                              GiftUser.userSelected.value
                                                  .forEach((key, value) =>
                                                  userSelected.add(
                                                      value.name));
                                              final recipients =
                                              userSelected.isEmpty
                                                  ? 1
                                                  : userSelected
                                                  .length;
                                              final roundCost =
                                                  selectedGiftPrice *
                                                      numberOfGifts *
                                                      recipients;
                                              if (roundCost > myCoins) {
                                                Methods.showToast(
                                                  context,
                                                  isError: true,
                                                  message: StringManager
                                                      .goRecharge
                                                      .tr(),
                                                );
                                                return;
                                              }
                                              LuckyGiftController.instance
                                                  .numOfRequest = 1;
                                              LuckyGiftService.instance
                                                  .resetGuard();
                                              LuckyGiftService.instance
                                                  .startCombo();
                                              LuckyGiftService.instance
                                                  .sendGift(
                                                roomOwnerId:
                                                '${widget.roomData.ownerId}',
                                              );
                                              GiftBottomBar
                                                  .typeCandy.value =
                                                  TypeCandy.luckyCandy;
                                            } else {
                                              if (ConstantsManager
                                                  .isVariantBuildA) {
                                                // Send first. Closing the
                                                // dialog before dispatching
                                                // the request deactivated the
                                                // GiftScreen subtree while
                                                // its global notifiers were
                                                // still updating.
                                                _closeSheetAfterSuccess =
                                                true;
                                                sendGift(1);
                                              } else {
                                                GiftBottomBar
                                                    .typeCandy.value =
                                                    TypeCandy.normalCandy;
                                              }
                                            }
                                          },
                                          child: Center(
                                            child: Text(
                                              StringManager.send.tr(),
                                              textAlign: TextAlign.center,
                                              style: context.bodyMedium
                                                  .colorExt(ColorManager
                                                  .buttonTextColor)
                                                  .copyWith(
                                                  fontSize: 14.sp *
                                                      widget.sizeFactor),
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
                      },
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              );
            }),
          );
        },
        listener: (_, state) {
          if (state is SuccessSendGiftStates) {
            GiftBottomBar.numberOfGift.value = 1;
            di<GetMyLevelBloc>().add(
              const GetMyLevelData(),
            );

            // Variant A wants the panel out of the way so the full-screen
            // SVGA gift can be seen. Close only after the send API succeeds
            // and only after the current frame is complete.
            if (_closeSheetAfterSuccess) {
              _closeSheetAfterSuccess = false;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                final navigator =
                Navigator.maybeOf(context);

                if (navigator != null &&
                    navigator.canPop()) {
                  navigator.pop();
                }
              });
            }
          } else if (state is ErrorSendGiftStates) {
            _closeSheetAfterSuccess = false;

            Methods.showToast(
              context,
              message: state.error,
              isError: true,
            );

            GiftBottomBar.numberOfGift.value = 1;
          } else if (state is LoadingSendGiftStates) {
            // Do not create another root OverlayEntry while a modal gift
            // route is already animating. The Send button remains responsive
            // and the API request itself is already protected by the Bloc.
          }
        },
      ),
    );
  }

  Widget sendDialog(BuildContext context) {
    final numbers = [1, 5, 9, 99, 999, 9999];

    String formatNumber(int number) {
      return widget.numberFormatPrefix.isEmpty
          ? '$number'
          : '$number${widget.numberFormatPrefix}';
    }

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.235,
        margin: context.paddingOnly(
          bottom: 45,
          start: 150,
        ),
        width: 100.w,
        decoration: BoxDecoration(
          borderRadius: 5.radius,
          color: widget.dialogBackgroundColor,
          border: Border.all(
            color: widget.dialogBorderColor,
          ),
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
                    builder: (context, value, _) {
                      return Text(
                        formatNumber(giftNum),
                        style: TextStyle(
                          color: value == giftNum
                              ? widget.selectionColor
                              : ColorManager.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void sendGift(int? compoNum) {
    final selectedGiftPrice = GiftScreen.chosenGift?.price ?? 0;
    final numberOfGifts = GiftBottomBar.numberOfGift.value;
    final myCoins = int.tryParse(RoomData.instance.myCoins.value) ?? 0;
    List<String> userSelected = [];
    List<String> userSelectedName = [];

    GiftUser.userSelected.value.forEach((key, value) {
      userSelected.add(value.userId);
    });
    GiftUser.userSelected.value.forEach((key, value) {
      userSelectedName.add(value.name);
    });
    String toUid = "";
    for (int i = 0; i < userSelected.length; i++) {
      toUid += '${userSelected[i].toString()},';
    }

    if (((selectedGiftPrice * numberOfGifts * userSelected.length) <=
        myCoins) ||
        (GiftBottomBar.giftType == TypeGift.bag)) {
      (userSelected.isEmpty && GiftUserOnly.userSelected == "")
          ? di<SendGiftBloc>().add(
        SendGiftesEvent(
          roomId: widget.roomData.id.toString(),
          id: di<GiftBloc>().state.giftId.toString(),
          toUid: "",
          num: GiftBottomBar.numberOfGift.value.toString(),
          userSelected: userSelected,
          userSelectedName: userSelectedName,
          myCoins: myCoins,
          selectedGiftPrice: selectedGiftPrice,
          numberOfGifts: numberOfGifts,
          giftData: GiftScreen.chosenGift,
          typeGift: GiftBottomBar.giftType.value,
          toZego: false,
        ),
      )
          : compoNum != null
          ? di<SendGiftBloc>().add(
        SendGiftesEvent(
          roomId: widget.roomData.id.toString(),
          id: di<GiftBloc>().state.giftId.toString(),
          toUid: GiftUserOnly.userSelected == ""
              ? toUid.substring(0, toUid.length - 1)
              : GiftUserOnly.userSelected,
          num: (compoNum * GiftBottomBar.numberOfGift.value)
              .toString(),
          userSelected: userSelected,
          userSelectedName: userSelectedName,
          myCoins: myCoins,
          selectedGiftPrice: selectedGiftPrice,
          numberOfGifts: numberOfGifts,
          typeGift: GiftBottomBar.giftType.value,
          giftData: GiftScreen.chosenGift,
          toZego: false,
        ),
      )
          : di<SendGiftBloc>().add(
        SendGiftesEvent(
          roomId: widget.roomData.id.toString(),
          id: di<GiftBloc>().state.giftId.toString(),
          toUid: GiftUserOnly.userSelected == ""
              ? toUid.substring(0, toUid.length - 1)
              : GiftUserOnly.userSelected,
          num: GiftBottomBar.numberOfGift.value.toString(),
          userSelected: userSelected,
          userSelectedName: userSelectedName,
          myCoins: myCoins,
          selectedGiftPrice: selectedGiftPrice,
          numberOfGifts: numberOfGifts,
          toZego: false,
          giftData: GiftScreen.chosenGift,
          typeGift: GiftBottomBar.giftType.value,
        ),
      );
    } else {
      Methods.showToast(
        context,
        isError: true,
        message: StringManager.goRecharge.tr(),
      );
    }
  }

  void sendMomentGift(int? compoNum) {
    final selectedGiftPrice = GiftScreen.chosenGift?.price ?? 0;
    final numberOfGifts = GiftBottomBar.numberOfGift.value;
    final myCoins = int.tryParse(RoomData.instance.myCoins.value) ?? 0;

    if ((selectedGiftPrice * numberOfGifts * 1) <= myCoins) {
      if (GiftScreen.chosenGift!.giftType == "alpha") {
        di<AlphaGiftManagerBloc>().add(ShowAlphaGift(
          imgFile:
          (GiftScreen.chosenGift?.img?.trim().isNotEmpty ?? false)
              ? GiftScreen.chosenGift!.img!
              : (GiftScreen.chosenGift?.showImg ?? ""),
          isFamousGift: false,
        ));
      }

      di<GiftBloc>().add(ShowGiftsEvent(
        pathGift:
        (GiftScreen.chosenGift?.img?.trim().isNotEmpty ?? false)
            ? GiftScreen.chosenGift!.img!
            : (GiftScreen.chosenGift?.showImg ?? ""),
        isShowGift: true,
        isFamousGift: false,
        giftType: GiftScreen.chosenGift!.giftType == "svga"
            ? ShowGiftType.svga
            : GiftScreen.chosenGift!.giftType == "mp4"
            ? ShowGiftType.mp4
            : GiftScreen.chosenGift!.giftType == "alpha"
            ? ShowGiftType.alpha
            : ShowGiftType.vap,
      ));

      di<SendMomentGiftBloc>().add(SendGiftsEvent(
        momentID: widget.momentId ?? "",
        giftId: di<GiftBloc>().state.giftId.toString(),
        number: numberOfGifts.toString(),
      ));
    } else {
      Methods.showToast(
        context,
        isError: true,
        message: StringManager.goRecharge.tr(),
      );
    }
  }
}
