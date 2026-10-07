import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/banned_users/view/banned_users_page.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/component/buttons/basic_tool/choose_mode_room.dart';
import 'package:general/src/features/room/presentation/component/buttons/basic_tool/room_effect_dailog.dart';
import 'package:general/src/features/room/presentation/component/buttons/emojie/emojie_widget.dart';
import 'package:general/src/features/carom/carom_room_controller.dart';
import 'package:general/src/features/carom/widgets/carom_create_sheet.dart';
import 'package:general/src/features/ludo/ludo_room_controller.dart';
import 'package:general/src/features/ludo/widgets/ludo_create_sheet.dart';
import 'package:general/src/features/room/presentation/lucky_box/lucky_box.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_bloc.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_events.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/music/view/component/music_widget.dart';
import 'package:general/src/features/room/presentation/music/view/music_server_page.dart';
import 'package:general/src/features/room/presentation/theme/view/theme_dialog.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import 'package:general/src/features/room/presentation/youtube/view/privacy_dialog.dart';
import 'package:general/src/features/room/room.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../manager/check_admin_owner_manager/check_admin_owner_bloc.dart';

part 'basic_tool_item.dart';

/// White background + black text + brand-gradient icons for this
/// "Functions in room" tools sheet, on request -- was a fixed dark-navy
/// background with a flat lavender icon/text tint.
const Color _kToolsSheetBg = Color(0xFFFFFFFF);
const Color _kToolsIconColor = Color(0xFF000000);

class ToolConfig {
  final String title;
  final String image;
  final double? height;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool Function(BuildContext, BasicToolDialog) isVisible;
  final Widget? additionalWidget;
  // Shows `image` as-is (no ShaderMask brand-gradient tint) -- every other
  // tile here is a flat glyph meant to be recolored, but an asset with its
  // own real artwork/colors (like the Lucky Bag icon) shouldn't be flattened.
  final bool noTint;

  ToolConfig({
    required this.title,
    required this.image,
    this.height,
    this.color,
    this.icon,
    this.onTap,
    required this.isVisible,
    this.additionalWidget,
    this.noTint = false,
  });
}

class BasicToolDialog extends StatefulWidget {
  final BuildContext parentContext;
  final String ownerId;
  final String userId;
  final bool isAdmin;
  final bool isOnMic;
  final EnterRoomModel roomData;

  const BasicToolDialog({
    super.key,
    required this.parentContext,
    required this.roomData,
    required this.ownerId,
    required this.userId,
    required this.isOnMic,
    required this.isAdmin,
  });

  @override
  State<BasicToolDialog> createState() => _BasicToolDialogState();
}

class _BasicToolDialogState extends State<BasicToolDialog> {
  late bool isAudio;

  @override
  void initState() {
    super.initState();
    isAudio = di<RoomStateManager>().isInAudioRoom;

    if (widget.ownerId == widget.userId) {
      di<MangerGetVipPrevBloc>().add(const GetVipPrevEvent());
    }
  }

  Future<void> _closeThenOpen(
      String action,
      FutureOr<void> Function(BuildContext context) open,
      ) async {
    debugPrint(' AUDIO_MORE action => $action');
    final parentContext = widget.parentContext;
    Navigator.of(context, rootNavigator: true).pop();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!parentContext.mounted) return;
    await open(parentContext);
  }

  // Quick games (Lucky Number / RPS / Dice) -- same send-message logic as
  // the old GamesQuickButton, reused here now that these live in the tools
  // sheet instead of their own bottom-bar icon.
  Map<String, dynamic> _quickGameUserData(String gameType) => {
    StringManager.gameType: gameType,
    "img": MyDataModel.getInstance().profile?.image ?? "",
    "bu": MyDataModel.getInstance().bubble ?? "",
    "buId": MyDataModel.getInstance().bubbleId.toString(),
    "sL": MyDataModel.getInstance().level?.senderImage ?? "",
    "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
    "v": MyDataModel.getInstance().vip1?.img1 ?? "",
    "c": MyDataModel.getInstance().vip1?.colorName ?? "",
    'type': 'games',
  };

  void _sendLuckyNum() => RoomData.instance.chatController?.sendMessage(
    "${Random().nextInt(9)},${Random().nextInt(9)},${Random().nextInt(9)}",
    userData: _quickGameUserData(StringManager.luckyNumGame),
  );

  void _sendRps() => RoomData.instance.chatController?.sendMessage(
    "${Random().nextInt(3)}",
    userData: _quickGameUserData(StringManager.rps),
  );

  void _sendDice() => RoomData.instance.chatController?.sendMessage(
    "${Random().nextInt(6)}",
    userData: _quickGameUserData(StringManager.diceGame),
  );

  List<ToolConfig> _getAudioToolConfigs() => [
    ToolConfig(
      title: LockRoomDialog.roomIsLoked
          ? StringManager.unlockRoom.tr()
          : StringManager.lockRoom.tr(),
      image: AssetsManager.lockRoomIcon,
      isVisible: (context, widget) => widget.ownerId == widget.userId,
      onTap: () => _closeThenOpen('lock_room', (parentContext) async {
        debugPrint(' OPEN Lock Room');
        if (LockRoomDialog.roomIsLoked) {
          await showDialog<void>(
            context: parentContext,
            builder: (context) => AnimatedDialog(
              title: StringManager.unLockRoom.tr(),
              description: StringManager.unLockRoomMsg.tr(),
              onTap: () {
                di<OnRoomBloc>().add(RemovePassRoomEvent(
                    roomId: widget.roomData.id.toString()));
                LockRoomDialog.roomIsLoked = false;
                RoomData.instance.isRoomLocked.value = false;
                sendRoomData(data: {
                  "messageContent": {
                    "message": "roomPassword",
                    "value": false
                  }
                });
                Navigator.pop(context);
              },
            ),
          );
        } else {
          await bottomDailog(
            context: parentContext,
            color: ColorManager.transparent,
            widget: const LockRoomDialog(),
          );
        }
      }),
    ),
    //////////////////////////////////////////////////////////////////
    ToolConfig(
      title: StringManager.emojis.tr(),
      image: "",
      icon: Icons.emoji_emotions,
      color: _kToolsIconColor,
      height: 35.h,
      isVisible: (context, widget) =>
      (RoomData.instance.utdController?.seatController
          .isUserOnSeat(widget.userId.toString()) ??
          false) &&
          ConstantsManager.isTheme1 &&
          !ConstantsManager.isTheme2,
      onTap: () {
        Navigator.pop(context);
        if (HomePage.isConnectToInternet == true) {
          bottomDailog(
            context: context,
            widget: EmojieWidget(
              userId: widget.userId,
              roomId: widget.roomData.id.toString(),
            ),
          );
        } else {
          Methods.showToast(
            context,
            message: StringManager.pleaseCheckInternet.tr(),
            isError: true,
          );
        }
      },
    ),
    ToolConfig(
      title: StringManager.theme.tr(),
      image: AssetsManager.themeIcon,
      height: 35.h,
      isVisible: (context, widget) => widget.ownerId == widget.userId,
      onTap: () => _closeThenOpen('theme', (parentContext) async {
        debugPrint(' OPEN Theme');
        di<ThemeBloc>().add(const GetThemesEvent());
        await bottomDailog(
          context: parentContext,
          widget: ThemePage(ownerId: widget.ownerId),
        );
      }),
    ),
    ToolConfig(
      title: StringManager.luckyBox.tr(),
      image: AssetsManager.audioRedPocketIcon,
      height: 35.h,
      noTint: true,
      isVisible: (context, widget) => true,
      // Was Navigator.pop(context) immediately followed by
      // bottomDailog(context: context, ...) using that SAME context -- once
      // popped, this tile's own context belongs to the now-closed tools
      // sheet, so the following bottomDailog call had nothing valid to
      // anchor to and silently opened nothing. Every other tile here uses
      // _closeThenOpen (waits for the pop to actually finish, then opens
      // the next sheet off widget.parentContext) -- Lucky Box just never
      // got switched over to it.
      onTap: () => _closeThenOpen('lucky_box', (parentContext) async {
        di<LuckyBoxBloc>().add(GetLuckyBoxesEvent());
        await bottomDailog(
          context: parentContext,
          widget: LuckyBox(
            roomData: widget.roomData,
          ),
        );
      }),
    ),
    // Ludo: opens the create sheet (1 vs 1 / Multi-player, Classic / Simple,
    // Magic). Audio room only -- the Ludo layout replaces the mic-seat grid.
    ToolConfig(
      title: 'Ludo',
      image: "",
      icon: Icons.casino_rounded,
      height: 35.h,
      isVisible: (context, widget) => di<RoomStateManager>().isInAudioRoom,
      onTap: () => _closeThenOpen('ludo', (parentContext) async {
        final ludo = LudoRoomController.instance;
        if (CaromRoomController.instance.isActive) {
          Methods.showToast(
            parentContext,
            message: 'Close Carrom first',
            isError: false,
          );
          return;
        }
        if (ludo.isActive) {
          Methods.showToast(
            parentContext,
            message: 'Ludo is already open',
            isError: false,
          );
          return;
        }
        if (ludo.hasGame) {
          ludo.reopen();
          return;
        }
        await showLudoCreateSheet(parentContext);
      }),
    ),
    // Carrom: same pattern as Ludo (create sheet -> lobby -> board in the room).
    ToolConfig(
      title: 'Carrom',
      image: "",
      icon: Icons.adjust_rounded,
      height: 35.h,
      isVisible: (context, widget) => di<RoomStateManager>().isInAudioRoom,
      onTap: () => _closeThenOpen('carom', (parentContext) async {
        final carom = CaromRoomController.instance;
        if (LudoRoomController.instance.isActive) {
          Methods.showToast(
            parentContext,
            message: 'Close Ludo first',
            isError: false,
          );
          return;
        }
        if (carom.isActive) {
          Methods.showToast(
            parentContext,
            message: 'Carrom is already open',
            isError: false,
          );
          return;
        }
        if (carom.hasGame) {
          carom.reopen();
          return;
        }
        await showCaromCreateSheet(parentContext);
      }),
    ),
    //////////////////////////////////////////////////////////////////
    // The one-tap quick games (Lucky Number / RPS / Dice) used to live
    // in their own bottom-bar icon (GamesQuickButton), which was removed
    // from the bar -- that took the games out entirely, with nowhere
    // left to reach them. Moved in here instead, on request, as three
    // separate tiles with the exact same send-message behavior.
    ToolConfig(
      title: StringManager.luckyNumGame.tr(),
      image: AssetsManager.number12,
      isVisible: (context, widget) => true,
      onTap: () {
        Navigator.pop(context);
        _sendLuckyNum();
      },
    ),
    ToolConfig(
      title: StringManager.rpsGameKey.tr(),
      image: AssetsManager.rpsGameIcon,
      isVisible: (context, widget) => true,
      onTap: () {
        Navigator.pop(context);
        _sendRps();
      },
    ),
    ToolConfig(
      title: StringManager.diceGame.tr(),
      image: AssetsManager.dices,
      isVisible: (context, widget) => true,
      onTap: () {
        Navigator.pop(context);
        _sendDice();
      },
    ),
    ToolConfig(
      // Mic mode now also hosts Cinema + PK as selectable "modes".
      title: StringManager.micMode.tr(),
      image: AssetsManager.micMode,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () => _closeThenOpen('mic_mode', (parentContext) async {
        debugPrint(' OPEN Mic Mode');
        final roomId = widget.roomData.id.toString();
        await bottomDailog(
          context: parentContext,
          widget: ChooseModeRoom(
            roomId: roomId,
            modeRoom: widget.roomData.mode.toString(),
            onCinemaTap: ConstantsManager.isShowCinemaMode
                ? () => _toggleCinema(roomId)
                : null,
            onPkTap:
            !ConstantsManager.isTheme1 ? () => _startPk(roomId) : null,
          ),
        );
      }),
    ),
    ToolConfig(
      // The other half of view mode. Applying already worked -- the kit
      // queues the request and the live room has a screen for it -- but the
      // PARTY room had no way in, so a host never saw who was waiting and
      // every Apply sat unanswered.
      title: StringManager.seatRequests.tr(),
      image: AssetsManager.seat,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      additionalWidget: const _SeatRequestBadge(),
      // Same _closeThenOpen pattern every other option here already uses:
      // the sheet's internal UTDRoomScope.of() needs a context descending
      // from the room's UTDRoomScope. This dialog's own `context` stops
      // being reliable the instant its route is popped, and navKey
      // .currentContext (the root navigator) never descends from that scope
      // at all -- both silently left showUTDRoomSheet's UTDRoomScope
      // .maybeOf(context) returning null, so the sheet never got re-wrapped
      // in a scope and crashed with "No UTDRoomScope found in context".
      // widget.parentContext is captured before this sheet ever opened and
      // is awaited-safe via the mounted check in _closeThenOpen.
      onTap: () => _closeThenOpen('seat_requests', (parentContext) async {
        final controller = RoomData.instance.utdController;
        if (controller == null) return;
        await UTDRequestQueueSheet.show(parentContext, controller: controller);
      }),
    ),
    ToolConfig(
      // View mode. The kit has had a 'request' seat mode and a
      // requestToSpeak() path all along, but nothing could switch a room
      // into it -- every caller of setupSeats passed the CURRENT mode
      // straight back. This is that missing switch.
      title: StringManager.viewMode.tr(),
      image: AssetsManager.seatRing,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () {
        Navigator.pop(context);
        _toggleViewMode();
      },
    ),
    ToolConfig(
      title: StringManager.effect.tr(),
      image: AssetsManager.effect,
      isVisible: (context, widget) => true,
      onTap: () => _closeThenOpen('effect', (parentContext) async {
        debugPrint(' OPEN Effect');
        await bottomDailog(
          context: parentContext,
          widget: const RoomEffectDailog(),
        );
      }),
    ),
    ToolConfig(
      title: StringManager.music.tr(),
      image: AssetsManager.musicIcon,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () {
        di<CheckAdminOwnerBloc>().add(CheckAdminOwnerEvent(
          context: context,
          params: CheckAdminOwnerParam(
            roomId: widget.roomData.id.toString(),
            type: 'music',
          ),
          callback: () async {
            await Methods.requestPermission(Permission.audio);
            // `context` here is the State.context getter: after the async
            // gap the dialog is often already popped/disposed, and the
            // getter itself throws (`_element!`) BEFORE `.mounted` can be
            // read — the live "Null check operator" fatal. State.mounted
            // is the unmount-safe check.
            if (!mounted) return;

            if (isAudio) {
              // Audio room: shared, synced music. Open the server-backed
              // upload/list page; playback is broadcast to all users and
              // controlled only by whoever starts it.
              context.popRoute();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MusicServerPage(),
                ),
              );
              return;
            }

            // Live (video) room: existing local-music behavior.
            di<MusicRoomBloc>().add(GetMusicRoomListEvent(callback: () {
              // Same unmount-safe guard: State.context throws when the
              // dialog State is already disposed by the time this lands.
              if (!mounted) return;
              context.popRoute();
              if (di<MusicRoomBloc>().state.musicesInRoom.isEmpty) {
                Navigator.pushNamed(
                  context,
                  Routes.musicPage,
                  arguments: widget.ownerId,
                );
              } else {
                bottomDailog(
                  context: context,
                  widget: const MusicDialog(),
                );
              }
            }));
          },
        ));
      },
    ),
    ToolConfig(
      title: StringManager.cleanComments.tr(),
      image: AssetsManager.clearChat,
      height: 35.h,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () {
        Navigator.pop(context);
        di<CheckAdminOwnerBloc>().add(CheckAdminOwnerEvent(
          context: context,
          params: CheckAdminOwnerParam(
            roomId: widget.roomData.id.toString(),
            type: 'cleat_chat',
          ),
          callback: () {
            final ctx = navKey.currentState?.context;
            if (ctx == null) return;
            showDialog(
              context: ctx,
              builder: (context) => AnimatedDialog(
                title: StringManager.cleanComments.tr(),
                description: StringManager.areYouSureDeleteChat.tr(),
                conText: StringManager.confirm.tr(),
                // White card / black text / gradient confirm button, on
                // request -- same pairing used elsewhere in the tools sheet.
                dialogBackgroundColor: ColorManager.white,
                descriptionColor: ColorManager.black,
                titleColor: ColorManager.black,
                cancelTextColor: ColorManager.black,
                confirmGradientColors: ColorManager.brandGradientColors,
                onTap: () {
                  RoomData.instance.chatController?.clearMessages();
                  final mapInformation = {
                    "messageContent": {"message": "removeChat"}
                  };
                  final map = jsonEncode(mapInformation);
                  sendRoomData(data: jsonDecode(map));
                  Navigator.pop(context);
                },
              ),
            );
          },
        ));
      },
    ),
    ToolConfig(
      title: StringManager.adminsTool.tr(),
      image: AssetsManager.admins,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () {
        Navigator.pop(context);
        bottomDailog(
          context: context,
          widget: MediaQuery(
            data: MediaQueryData.fromView(View.of(context)),
            child: AdminsRoomPage(
              isRoomManager: false,
              ownerId: widget.ownerId,
            ),
          ),
        );
      },
    ),
    ToolConfig(
      title: StringManager.hideRoom.tr(),
      image: AssetsManager.hideRoom,
      isVisible: (context, widget) => widget.ownerId == widget.userId,
      onTap: () => _closeThenOpen('hide_room', (parentContext) async {
        debugPrint(' OPEN Hide Room');
        final state = di<MangerGetVipPrevBloc>().state;
        if (state.requestState == RequestState.loaded) {
          final reslt =
          state.data.firstWhere((element) => element.key == "room");
          if (reslt.isAllowToUser != true) {
            await showDialog<void>(
              context: parentContext,
              builder: (context) => AnimatedDialog(
                onTap: () {
                  context.popRoute();
                  context.pushNamedRoute(Routes.vipScreen);
                },
                description: StringManager.thisFeatureisNotAvailableForYou(
                  vip: reslt.mine.toString(),
                ).tr(),
                title: reslt.titleAr ?? '',
                // Same white/black/gradient pairing as the rest of the
                // tools sheet, on request.
                dialogBackgroundColor: ColorManager.white,
                descriptionColor: ColorManager.black,
                titleColor: ColorManager.black,
                cancelTextColor: ColorManager.black,
                confirmGradientColors: ColorManager.brandGradientColors,
              ),
            );
          } else {
            await Navigator.of(parentContext).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => SettingScreen(roomData: widget.roomData),
              ),
            );
          }
        }
      }),
    ),
    ToolConfig(
      title: StringManager.bannedUsers.tr(),
      image: AssetsManager.userBlock,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () => _closeThenOpen('banned_user', (parentContext) async {
        debugPrint(' OPEN Banned User');
        await bottomDailog(
          context: parentContext,
          widget: MediaQuery(
            data: MediaQueryData.fromView(View.of(parentContext)),
            child: const BannedUsersPage(),
          ),
        );
      }),
    ),
    // Charisma (moved here from the room-info page). Owner-only toggle, with
    // the same PK/cinema guards as before.
    ToolConfig(
      title: StringManager.charisma.tr(),
      image: '',
      icon: Icons.auto_awesome,
      color: _kToolsIconColor,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () {
        context.popRoute();
        if (PkController.isPK.value || PkController.showPK.value) {
          Methods.showToast(context,
              message: StringManager.closePkFirst.tr(), isError: true);
        } else if (RoomData.instance.room.mode == '5' ||
            RoomData.instance.runningCinemaMode == true) {
          Methods.showToast(context,
              message: StringManager.closeCinemaMode.tr(), isError: true);
        } else {
          di<CharismaBloc>().add(
            StartCharismaEvent(roomId: widget.roomData.id.toString()),
          );
          RoomData.instance.runningCinemaMode = false;
        }
      },
    ),
    ToolConfig(
      title: StringManager.resetCharisma.tr(),
      image: '',
      icon: Icons.refresh,
      color: _kToolsIconColor,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () {
        context.popRoute();
        di<CharismaBloc>().add(
          ResetCharismaEvent(
            roomId: widget.roomData.id.toString(),
            ownerId: widget.ownerId,
            context: context,
          ),
        );
      },
    ),
    ToolConfig(
      title: RoomData.instance.isCommentsClosed.value
          ? StringManager.unlockComments.tr()
          : StringManager.lockComments.tr(),
      image: AssetsManager.closeComments,
      height: 25.h,
      color: _kToolsIconColor,
      isVisible: (context, widget) =>
      widget.ownerId == widget.userId || widget.isAdmin,
      onTap: () {
        if (RoomData.instance.isCommentsClosed.value) {
          RoomData.instance.isCommentsClosed.value = false;
          di<OnRoomBloc>().add(
            UnLockCommentsEvent(
              roomId: widget.roomData.id.toString(),
            ),
          );
        } else {
          RoomData.instance.isCommentsClosed.value = true;
          di<OnRoomBloc>().add(
            LockCommentsEvent(
              roomId: widget.roomData.id.toString(),
            ),
          );
        }
      },
    ),
  ];

  // Cinema toggle, invoked from the mic-mode selector (the tools sheet is
  // already closed, so use the global navigator context — State.context is dead).
  /// Flip the room between "anyone may take a seat" and "seats need approval".
  ///
  /// Two writes, deliberately: the kit's seat mode is what makes the app show
  /// Apply and route a failed take through requestToSpeak, while `free_mic` on
  /// the room is what the BACKEND enforces in up_microphone. Setting only the
  /// first would leave the rule client-side, which anyone with the API could
  /// ignore; setting only the second would leave the app with no idea.
  Future<void> _toggleViewMode() async {
    final ctx = navKey.currentContext;
    final controller = RoomData.instance.utdController;
    if (ctx == null || controller == null) return;

    final seats = controller.seatController;
    final turningOn = seats.seatMode.value != 'request';
    final nextMode = turningOn ? 'request' : 'free';

    final ok = await seats.setupSeats(
      identity: MyDataModel.getInstance().id.toString(),
      seatCount: seats.seats.value.length,
      seatMode: nextMode,
      modeId: RoomData.instance.room.mode,
    );

    if (!ok) {
      if (ctx.mounted) {
        Methods.showToast(ctx,
            message: StringManager.someThingWentWrong.tr(), isError: true);
      }
      return;
    }

    // Persist so the room comes back in the same mode, and so the server
    // rejects a seat grab made outside the app.
    // Fire and forget: the seat mode is already applied and the room is usable.
    // A failed persist only means the mode is not remembered for next time, and
    // must not block or undo the switch the host just made.
    RoomRemoteDataSourceImp(di())
        .updateRoomViewMode(
      roomId: RoomData.instance.room.id.toString(),
      freeMic: turningOn ? 1 : 0,
    )
        .catchError((Object e) =>
        Methods.printLog('view mode persist failed: $e'));

    if (ctx.mounted) {
      Methods.showToast(ctx,
          message: (turningOn
              ? StringManager.viewModeOn
              : StringManager.viewModeOff)
              .tr());
    }
  }

  void _toggleCinema(String roomId) {
    if (RoomData.instance.room.mode == '5') {
      RoomData.instance.runningCinemaMode = false;
      final controller = RoomData.instance.utdController;
      if (controller != null) {
        final mode = controller.resolveMode('3');
        controller.seatController.setupSeats(
          identity: MyDataModel.getInstance().id.toString(),
          seatCount: mode.seatCount,
          seatMode: controller.seatController.seatMode.value,
          modeId: '3',
        );
      }
      di<YoutubeBloc>().add(const InitialViewYoutubeVideoEvent());
      di<YoutubeBloc>().add(const DisposeViewYoutubeVideoEvent());
    } else {
      final ctx = navKey.currentContext;
      if (ctx == null) return;
      if (PkController.showPK.value || PkController.isPK.value) {
        Methods.showToast(ctx,
            message: StringManager.closePkFirst.tr(), isError: true);
      } else if (RoomData.instance.isCharismaVisible.value) {
        Methods.showToast(ctx, message: StringManager.closeCharisma.tr());
      } else {
        showDialog(
          context: ctx,
          builder: (_) => PrivacyDialog(roomId: roomId),
        );
      }
    }
  }

  // PK start, invoked from the mic-mode selector.
  void _startPk(String roomId) {
    final ctx = navKey.currentContext;
    if (ctx == null) return;
    if (RoomData.instance.room.mode != '3') {
      Methods.showToast(ctx, message: StringManager.cantOpenPk.tr());
    } else if (RoomData.instance.isCharismaVisible.value) {
      Methods.showToast(ctx,
          message: StringManager.closeCharisma.tr(), isError: true);
    } else if (PKWidget.isStartPK.value) {
      Methods.showToast(ctx, message: StringManager.cantClosePk.tr());
    } else {
      activePK();
      di<PKBloc>().add(ShowPKEvent(roomId: roomId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSpeaker = di<RoomStateManager>().isInAudioRoom &&
        !ConstantsManager.isTheme1;

    final tools = _getAudioToolConfigs()
        .where((tool) => tool.isVisible(context, widget))
        .toList();
    // Games are available to every room user. Keep using the app's existing
    // GamesView -> OpenGameBloc -> LeaderCCGameWebViewScreen flow; do not
    // introduce a second game/session implementation here.
    final Widget gamesWidget = GestureDetector(
      onTap: () async {
        if (HomePage.isConnectToInternet == true) {
          final BuildContext parentContext = widget.parentContext;
          final String activeRoomId = widget.roomData.id.toString();

          debugPrint('🎮 AUDIO MORE => open games room=$activeRoomId');

          // BasicToolDialog itself is a bottomDailog(). bottomDailog keeps the
          // global isDialogOpen lock until its 260ms closing animation ends.
          // Calling another bottomDailog after only 80/120ms is silently
          // ignored. Close this one first and wait until the lock is released.
          Navigator.of(context).pop();

          for (int i = 0; i < 30 && isDialogOpen; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 20));
          }

          if (!parentContext.mounted) return;

          await bottomDailog(
            context: parentContext,
            widget: GamesView(roomId: activeRoomId),
          );
        } else {
          Methods.showToast(
            context,
            message: StringManager.pleaseCheckInternet.tr(),
            isError: true,
          );
        }
      },
      child: BasicToolItem(
        title: StringManager.games.tr(),
        image: AssetsManager.gameIconHome,
        color: _kToolsIconColor,
      ),
    );
    return Container(
      // Size to content (scrolls if taller) instead of a fixed height that
      // clipped rows — so every tool is reachable.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.62,
      ),
      padding: context.paddingSymmetric(horizontal: 10),
      decoration: BoxDecoration(
        // Fixed dark-navy (was the panel-driven surfaceCardColor) -- locked
        // to this exact color on request, so it no longer depends on the
        // admin panel's theme.
        color: _kToolsSheetBg,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.r),
          topLeft: Radius.circular(15.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            3.hBox,
            Padding(
              padding: context.paddingOnly(top: 8, start: 10),
              child: Text(
                StringManager.basicTools.tr(),
                style: context.bodyMedium.bold
                    .colorExt(_kToolsIconColor)
                    .size(18),
              ),
            ),
            5.hBox,
            // Dynamic grid of tools
            BlocBuilder<MangerGetVipPrevBloc, MangerGetVipPrevState>(
              bloc: di<MangerGetVipPrevBloc>(),
              buildWhen: (prev, curr) =>
              prev.requestState != curr.requestState ||
                  prev.data != curr.data,
              builder: (context, state) {
                return GridView.builder(
                  shrinkWrap: true,
                  padding: context.paddingZero(),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    // Was 1 (square cells) -- BasicToolItem's label was
                    // bumped to maxLines: 2 earlier (so long labels like
                    // "Activate boss position" wrap instead of getting cut
                    // off), which made its content taller than a square
                    // cell could hold: "A RenderFlex overflowed by 2.4
                    // pixels" at basic_tool_item.dart:26. Slightly taller
                    // cells give that second text line room without
                    // clipping.
                    childAspectRatio: 0.85,
                  ),
                  // Always reserve one cell for Games, plus Speaker when
                  // that audio-room control is present. The old count omitted
                  // the Games cell whenever Speaker was visible.
                  itemCount: tools.length + (hasSpeaker ? 2 : 1),
                  itemBuilder: (context, index) {
                    if (index == 0 &&
                        hasSpeaker &&
                        !ConstantsManager.isTheme1) {
                      return const SpeakerButton();
                    } else if (index == tools.length + (hasSpeaker ? 1 : 0)) {
                      return gamesWidget;
                    }
                    final tool = tools[index - (hasSpeaker ? 1 : 0)];

                    return ValueListenableBuilder(
                      valueListenable: tool.title.contains(StringManager.pk)
                          ? PKWidget.isStartPK
                          : tool.title.contains(StringManager.comments)
                          ? RoomData.instance.isCommentsClosed
                          : ValueNotifier<bool>(false),
                      builder: (context, value, _) => InkWell(
                        onTap: tool.onTap,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            BasicToolItem(
                              title: tool.title
                                  .contains(StringManager.hideRoom.tr())
                                  ? (state.requestState ==
                                  RequestState.loaded &&
                                  state.data.any((e) => e.key == "room")
                                  ? (state.data
                                  .firstWhere(
                                      (e) => e.key == "room")
                                  .isActive ??
                                  false)
                                  ? StringManager.showRoom.tr()
                                  : StringManager.hideRoom.tr()
                                  : StringManager.hideRoom.tr())
                                  : tool.title,
                              image: tool.image,
                              icon: tool.icon,
                              height: tool.height,
                              color: tool.color,
                              noTint: tool.noTint,
                            ),
                            if (tool.additionalWidget != null)
                              tool.additionalWidget!,
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// How many people are waiting for a seat, shown on the tool tile.
///
/// Reads the kit's own queue, so it cannot drift from what the sheet lists.
class _SeatRequestBadge extends StatelessWidget {
  const _SeatRequestBadge();

  @override
  Widget build(BuildContext context) {
    final controller = RoomData.instance.utdController;
    if (controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder<List<SpeakerRequest>>(
      valueListenable: controller.seatController.pendingRequests,
      builder: (context, requests, _) {
        if (requests.isEmpty) return const SizedBox.shrink();
        return Positioned(
          top: 0,
          right: 0,
          child: Container(
            constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: ColorManager.redIcons,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: TextWidget(
                requests.length > 99 ? '99+' : '${requests.length}',
                style: context.bodySmall
                    .size(10)
                    .w600
                    .colorExt(ColorManager.inkOn(ColorManager.redIcons)),
              ),
            ),
          ),
        );
      },
    );
  }
}
