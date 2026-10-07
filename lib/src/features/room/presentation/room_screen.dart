import 'dart:async';
import 'package:general/src/features/carom/carom_room_controller.dart';
import 'package:general/src/features/carom/game_room_hub.dart';
import 'package:general/src/features/ludo/ludo_room_controller.dart';
import 'package:general/src/features/ludo/widgets/ludo_animated_background.dart';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_ghost_guard.dart';
import 'package:general/src/core/realtime/realtime_config.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';
import 'package:general/src/features/games/domain/entities/game_entity.dart';
import 'package:general/src/features/room/presentation/component/room_header/exit_room/exit_side_panel_overlay.dart';
import 'package:general/src/features/room/presentation/component/seat_config/empty_seat_widget.dart';
import 'package:general/src/features/room/presentation/component/seat_config/locked_seat_widget.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_avatar_widget.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_event.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/dialog_lucky_box.dart';
import 'package:general/src/features/room/presentation/manager/room_mode/room_mode_cubit.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/room_modes/seat8_mode.dart';
import 'package:general/src/features/room/presentation/room_modes/seat2_mode.dart';
import 'package:general/src/features/room/presentation/room_modes/seat22_mode.dart';
import 'package:general/src/features/room/presentation/room_modes/seat30_mode.dart';
import 'package:general/src/features/room/presentation/room_modes/couples_mode.dart';
import 'package:general/src/features/room/presentation/youtube/view/cinema_mode_layout.dart';
import 'package:general/src/features/room/presentation/youtube/view/youtube_controller.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/component/messages/tabbed_messages_view.dart';
import 'package:general/src/features/room/presentation/component/buttom_bar/buttom_bar_widget.dart';
import 'package:general/src/features/room/presentation/component/widgets/seat_options_sheet.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_bloc.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_event.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_state.dart';
import 'package:general/src/features/vip/domain/entity/vip_bag_item_entity.dart';

class RoomScreen extends StatefulWidget {
  final MyDataModel userModel;
  final String roomId;
  final String ownerId;
  final bool isHost;
  final bool isLocked;
  final bool? isGame;
  final bool? isExit;
  final bool? fromDynamicLink;
  final GameDataEntity? gameDataEntity;
  final String? specialIdImage;
  final ImageColorEntity? imageColorEntity;

  const RoomScreen({
    super.key,
    required this.userModel,
    required this.isHost,
    required this.isLocked,
    required this.roomId,
    required this.ownerId,
    this.isGame,
    this.isExit,
    this.fromDynamicLink,
    this.gameDataEntity,
    this.specialIdImage,
    this.imageColorEntity,
  });

  @override
  State<RoomScreen> createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  /// LIVE-room avatars can still use GlobalKeys because each visible live
  /// avatar is unique. Audio-room seats must NOT use a per-user GlobalKey:
  /// during seat/rebuild transitions the same user can exist in two widget
  /// branches for one frame, which throws "Multiple widgets used the same
  /// GlobalKey" when the gift sheet opens.
  static Map<String, GlobalKey> seatAvatarKeys = {};

  /// AUDIO-room lucky-gift target registry.
  /// BuildContext is safe to overwrite when a seat is rebuilt and does not
  /// participate in Flutter's GlobalKey uniqueness rules.
  static final Map<String, BuildContext> seatAvatarContexts =
  <String, BuildContext>{};

  static Map<int, String> seatAvatarIds = {};

  static void registerSeatAvatarContext(
      String userId,
      BuildContext context,
      ) {
    if (userId.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      seatAvatarContexts[userId] = context;
    });
  }

  static void unregisterSeatAvatarContext(String userId) {
    if (userId.isEmpty) return;
    seatAvatarContexts.remove(userId);
  }

  final giftController = GiftController();

  /// Live subscription to audio-output device changes, so the room re-routes
  /// audio the moment a Bluetooth headset connects/disconnects mid-session.
  StreamSubscription<Set<AudioDevice>>? _audioDevicesSub;

  /// Guards the UTD Stream "service unavailable" notice so it is shown only
  /// once even if onConnectError fires repeatedly during connect/token retries.
  bool _streamNoticeShown = false;

  /// Live subscription to the VIP bag, used only to catch the moment it
  /// finishes loading so the Sound Wave attribute can be (re)published —
  /// see [_tryPublishSoundWaveAttribute].
  StreamSubscription<VipStates>? _vipBagSub;


  /// Configure the audio session for Bluetooth and route output to a connected
  /// headset (falling back to the loudspeaker). Delegates the actual routing to
  /// WebRTC's native BT-preferring logic via the kit, and re-applies it whenever
  /// a headset connects/disconnects. Fixes "audio plays from the phone speaker
  /// instead of Bluetooth".
  Future<void> _setupBluetoothAwareAudio(UTDRoomController controller) async {
    try {
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.allowBluetoothA2dp,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
          androidWillPauseWhenDucked: true,
        ),
      );
      // Apply BT routing through the KIT (forceHandleAudioRouting on Android),
      // which is the only thing that beats LiveKit's MODE_IN_COMMUNICATION.
      await controller.mediaController.applyBluetoothAudioRouting();
      // …and re-apply whenever a headset connects/disconnects.
      _audioDevicesSub?.cancel();
      _audioDevicesSub = session.devicesStream.listen((_) {
        controller.mediaController.applyBluetoothAudioRouting();
      });
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();

    loadCachedMicState();

    _deferRtmStart();

    setupRoomAndUser(
      isLocked: widget.isLocked,
      roomId: widget.roomId,
      context: context,
    );

    // The active tier's "Sound Wave" (privilege type 21) SVGA isn't on
    // /api/my-data at all -- it only exists in the per-user VIP bag from
    // /api/vips/user/list, which VipCenterBloc otherwise only loads lazily
    // when the VIP center screen itself is opened. Kick it off here so the
    // data is ready (or on its way) before the room needs it.
    //
    // NOTE: `userInRoomAttributes` (below) is only read ONCE, by
    // UTDAudioRoom._connect() at join time (see connect(userAttributes: ...)
    // in utd_audio_room.dart) -- it is never re-read on rebuild. The VIP bag
    // request alone regularly takes 3-4+ seconds, i.e. LONGER than the RTC
    // connect, so at connect time the bag (and therefore 'sw') is still
    // empty almost every join, and the wave silently never appears for the
    // rest of the session no matter how often this screen rebuilds. Once the
    // bag actually loads, _tryPublishSoundWaveAttribute() re-publishes 'sw'
    // onto the live RTC participant via updateSelfAttributes() instead.
    if (di<VipCenterBloc>().state.vipBag.isEmpty) {
      di<VipCenterBloc>().add(const GetVipBagEvent());
    }
    _vipBagSub = di<VipCenterBloc>().stream.listen((state) {
      if (state.vipBag.isNotEmpty) {
        _tryPublishSoundWaveAttribute();
      }
    });
  }

  /// Publishes the resolved Sound Wave SVGA (see
  /// [_resolveActiveSoundWaveSvga]) onto the local participant's live RTC
  /// attributes once the VIP bag has loaded and the room is connected (so
  /// `updateSelfAttributes` has a real participant to publish to).
  ///
  /// Deliberately NOT latched to "ran once": LiveKit rejects
  /// `setAttributes` with a `NOT_ALLOWED` signal error until the local
  /// participant's publish permission has actually been granted (observed:
  /// a fresh join starts as audience-like and gets upgraded to publish a
  /// moment later via `ParticipantPermissionsUpdatedEvent`/`canPublish`).
  /// `updateSelfAttributes` swallows that failure silently (debug-print
  /// only, never rethrown), so a call made before the upgrade lands
  /// invisibly fails -- an earlier version marked this "done" regardless,
  /// which meant the wave never got published for that whole session
  /// whenever the timing landed before the upgrade. Every call site below
  /// (VIP bag loaded, connection changed, canPublish changed) is safe to
  /// call repeatedly -- each just re-sends the same small attribute map.
  void _tryPublishSoundWaveAttribute() {
    if (di<VipCenterBloc>().state.vipBag.isEmpty) return;
    final controller = RoomData.instance.utdController;
    if (controller == null || !controller.isConnected) return;
    final sw = _resolveActiveSoundWaveSvga();
    if (sw.isEmpty) return;
    controller.updateSelfAttributes({'sw': sw});
  }

  /// Resolves the SVGA asset for the local user's currently-equipped
  /// SVIP "Sound Wave" perk (privilege `type == 21`), if any. Mirrors how
  /// `frame`/`frame_id`/`frame_type` are already resolved server-side onto
  /// MyDataModel for the Avatar Frame perk -- except the backend does NOT
  /// resolve this one onto /api/my-data, so it has to be picked out of the
  /// full per-tier privilege list in the VIP bag ourselves.
  ///
  /// A user can have SEVERAL bag entries flagged `using: true` at once (a
  /// separately-tracked plain VIP tier alongside an SVIP tier, for
  /// example). `/api/my-data`'s `vip_target_id` names the ONE tier the user
  /// most recently activated via VIP Center's "Use" button (e.g. switching
  /// SVIP 3 -> SVIP 8 updates this to SVIP 8's target_id) -- that's the
  /// tier whose wave should show. If that tier is found in the bag but
  /// simply has no type:21 perk (a plain VIP tier has no Sound Wave privilege
  /// at all), the correct result is NO wave -- not some other still-"using"
  /// tier's leftover wave, which would make switching to a perk-less tier
  /// look like it silently ignored the switch. The scan-all-`using:true`
  /// fallback below only fires when the bag hasn't loaded this specific
  /// target_id yet (e.g. right after a fresh VIP Center switch, before the
  /// bag refetch lands), since in that transient window checking only the
  /// first `using: true` entry in list order can miss a tier that does carry
  /// the perk.
  String _resolveActiveSoundWaveSvga() {
    final bag = di<VipCenterBloc>().state.vipBag;

    final primaryTargetId = MyDataModel.getInstance().vipTargetId;
    if (primaryTargetId != null && primaryTargetId.isNotEmpty) {
      for (final entry in bag) {
        if (entry.targetId.toString() != primaryTargetId) continue;
        final privileges = entry.vip?.privilegs ?? const <PrivilegsEntity>[];
        for (final privilege in privileges) {
          if (privilege.type == 21 && privilege.active == true) {
            return privilege.img1 ?? '';
          }
        }
        // Primary tier found in the bag but has no Sound Wave perk -- that's
        // final, don't fall through to another tier's wave.
        return '';
      }
    }

    for (final entry in bag) {
      if (entry.using != true) continue;
      final privileges = entry.vip?.privilegs ?? const <PrivilegsEntity>[];
      for (final privilege in privileges) {
        if (privilege.type == 21 && privilege.active == true) {
          return privilege.img1 ?? '';
        }
      }
    }
    return '';
  }

  void _deferRtmStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startRtm();
    });
  }

  void _startRtm() {
    RoomData.instance.initRtm(
      giftController: giftController,
      roomId: widget.roomId,
      userModelId: widget.userModel.id.toString(),
      isHost: widget.isHost,
      tickerProvider: this,
    );
  }

  @override
  void dispose() {
    _audioDevicesSub?.cancel();
    _vipBagSub?.cancel();
    RoomData.instance.utdController?.mediaController.canPublish
        .removeListener(_tryPublishSoundWaveAttribute);
    di<GiftBloc>().add(
      const ShowGiftsEvent(
        pathGift: "",
        isShowGift: false,
        giftType: ShowGiftType.svga,
      ),
    );
    di<LuckyGiftWinBloc>().add(const ClearLuckyWinEvent());
    di<GiftBloc>().add(const SetVideoVisibilityEvent(isVisible: false));
    di<MusicRoomBloc>().add(
      SetIndexSongPlayingRoomEvent(di<MusicRoomBloc>().state.nowPlaying),
    );
    if (!di<RoomStateManager>().isMinimized) {
      LuckyBoxVariables.luckyBoxMap['luckyBoxes'].clear();
      di<SetTimerLuckyBox>().remTimeSuperBox = -1;
      DialogLuckyBox.startTime = false;
    }
    super.dispose();
  }

  void _showExitDialog() {
    final dialogContext = SafeNavigator.context;
    if (dialogContext == null) return;
    // Side drawer (the room stays visible behind it) instead of a bottom sheet.
    ExitSidePanelOverlay.show(dialogContext);
  }

  List<UTDRoomMode> _buildRoomModes() {
    Widget Function(UTDParticipant, int) wrapCreator(
        Widget Function(int) seatCreator,
        ) {
      return (user, seatIndex) => seatCreator(seatIndex);
    }

    List<UTDParticipant> extractUsers(List<SeatState> seats) {
      return seats
          .where((s) => s.occupantUserId != null)
          .map((s) => UTDParticipant(id: s.occupantUserId!, name: ''))
          .toList();
    }

    return [
      // displayName was never set, so every card in the mode picker was
      // labelled with its raw id ("3", "2", "1"). The strings for these have
      // existed in StringManager all along and nothing referenced them.
      const UTDRoomMode(
        id: '3',
        seatCount: 9,
        displayName: StringManager.micMode9,
        rows: [
          [0],
          [1, 2, 3, 4],
          [5, 6, 7, 8],
        ],
      ),
      const UTDRoomMode(
        id: '2',
        seatCount: 12,
        displayName: StringManager.micMode12,
        rows: [
          [0, 1, 2, 3],
          [4, 5, 6, 7],
          [8, 9, 10, 11],
        ],
      ),
      const UTDRoomMode(
        id: '1',
        seatCount: 16,
        displayName: StringManager.micMode16,
        rows: [
          [0, 1, 2, 3],
          [4, 5, 6, 7],
          [8, 9, 10, 11],
          [12, 13, 14, 15],
        ],
      ),
      // 30 seats, six across, matching the reference layout. '4' was the only
      // unused id; rooms.mode is a tinyint so it stores as-is, and changeMicMode
      // on the backend validates nothing, so no server change is needed.
      //
      // It carries its own containerBuilder because the built-in grid's flat
      // 5px row gap packed five rows into the top third and left a dead band
      // above the chat, which then stretched to fill it.
      UTDRoomMode(
        id: '4',
        seatCount: 30,
        displayName: StringManager.micMode30,
        rows: const [
          [0, 1, 2, 3, 4, 5],
          [6, 7, 8, 9, 10, 11],
          [12, 13, 14, 15, 16, 17],
          [18, 19, 20, 21, 22, 23],
          [24, 25, 26, 27, 28, 29],
        ],
        containerBuilder: (seats, seatCreator) {
          final users = extractUsers(seats);
          return Seat30Mode(
            allUsers: users,
            audioVideoUsers: users,
            seatWidgetCreator: wrapCreator(seatCreator),
          );
        },
      ),
      UTDRoomMode(
        id: '5',
        seatCount: 9,
        rows: const [
          [0, 1, 2, 3],
          [4, 5, 6, 7],
          [8],
        ],
        containerBuilder: (seats, seatCreator) {
          final users = extractUsers(seats);
          return CinemaModeLayout(
            allUsers: users,
            audioVideoUsers: users,
            seatWidgetCreator: wrapCreator(seatCreator),
          );
        },
        backgroundBuilder: (context) {
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsManager.cinemaBackground),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height / 2.05,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsManager.cinemaBackgroundTop),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      UTDRoomMode(
        id: '8',
        seatCount: 8,
        displayName: StringManager.micMode8,
        rows: const [
          [0, 1],
          [2, 3],
          [4, 5],
          [6, 7],
        ],
        containerBuilder: (seats, seatCreator) {
          final users = extractUsers(seats);
          return Seat8Mode(
            allUsers: users,
            audioVideoUsers: users,
            seatWidgetCreator: wrapCreator(seatCreator),
          );
        },
        backgroundBuilder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetsManager.seat8ModeBackground),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
      UTDRoomMode(
        id: '6',
        seatCount: 2,
        displayName: StringManager.micMode2,
        rows: const [
          [0, 1],
        ],
        containerBuilder: (seats, seatCreator) {
          final users = extractUsers(seats);
          return Seat2Mode(
            allUsers: users,
            audioVideoUsers: users,
            seatWidgetCreator: wrapCreator(seatCreator),
          );
        },
        backgroundBuilder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetsManager.seat2ModeBackground),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
      UTDRoomMode(
        id: '7',
        seatCount: 22,
        displayName: StringManager.micMode22,
        rows: const [
          [0],
          [1],
          [2, 3, 4, 5, 6],
          [7, 8, 9, 10, 11],
          [12, 13, 14, 15, 16],
          [17, 18, 19, 20, 21],
        ],
        containerBuilder: (seats, seatCreator) {
          final users = extractUsers(seats);
          return Seat22Mode(
            allUsers: users,
            audioVideoUsers: users,
            seatWidgetCreator: wrapCreator(seatCreator),
          );
        },
      ),
      UTDRoomMode(
        id: '9',
        seatCount: 8,
        displayName: StringManager.couplesMode,
        // Reference seat size at the design width: couches are laid out 4-across
        // (two couches/row) so the size can't be inferred from `rows` (2-wide).
        // computeSeatSize still scales this gently with the device.
        seatSize: 67,
        rows: const [
          [0, 1],
          [2, 3],
          [4, 5],
          [6, 7],
        ],
        containerBuilder: (seats, seatCreator) {
          final users = extractUsers(seats);
          return CouplesMode(
            allUsers: users,
            audioVideoUsers: users,
            seatWidgetCreator: wrapCreator(seatCreator),
          );
        },
        backgroundBuilder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetsManager.coupleModeBg),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// The room engine host. Never null, and never a host we do not own.
  ///
  /// `rtc_engine_url` arrives from `/config/settings`, which can still be in
  /// flight when this screen builds — and the kit's own constants point at the
  /// RETIRED vendor (`udt-stream.com`). Falling back to them meant the token
  /// POST went to a host that answers 404, the kit retried behind its backoff,
  /// and the room sat on a spinner for minutes before any seat appeared. That is
  /// the "party room seat load 20 min" report, and it is not slowness: it is a
  /// request to the wrong company.
  ///
  /// Our engine is served by our own API host, so `EndPoints.domainURL` is
  /// always the right answer when the server-driven value has not landed yet.
  ///
  /// Trailing slashes are stripped: the kit appends absolute paths, and a base
  /// ending in `/` yields a double slash some proxies 404 rather than normalise.
  String get _engineBaseUrl {
    final url = RealtimeConfig.rtcEngineUrl.trim();
    final base = url.isEmpty ? EndPoints.domainURL : url;

    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  @override
  Widget build(BuildContext mainContext) {
    // Full-bleed room background: the app-wide status/nav bar style (in
    // app.dart) uses DARK icons for the app's light theme, which would be
    // invisible over this screen's own (usually dark/colorful) room
    // background image. This screen-local override keeps both bars
    // transparent -- so the room background truly extends edge-to-edge,
    // behind the status bar and the system navigation bar -- with LIGHT
    // icons that stay visible on top of it. It only applies while this
    // route is the top of the stack; leaving the room restores the
    // app-wide style automatically.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorManager.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorManager.transparent,
        systemNavigationBarDividerColor: ColorManager.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _showExitDialog();
        },
        child: BlocListener<RoomHandlerBloc, RoomHandlerStates>(
          bloc: di<RoomHandlerBloc>(),
          listener: (context, state) async {
            if (state is EnterRoomSuccesMessageState) {
              RoomBackground.imgBackground.value =
                  state.room.roomBackground ?? "";
              if (RoomData.instance.room.mode != state.room.mode) {
                YouTubeController.isCinemaMode.value = state.room.mode == '5';
              }
              RoomData.instance.showCp.value = state.room.cpIndexs ?? [];
              RoomData.instance.isCommentsClosed.value =
                  state.room.isCommentsClosed ?? false;
            }
          },
          // The audio-room kit is closed-source and renders its own layout
          // internally; wherever ITS background/seat area does not reach --
          // e.g. the strip reserved for the bottom controls bar -- whatever
          // is behind that strip shows through as a solid block, which is
          // exactly the "black bar behind Say Hi" gap the reference app in
          // the screenshot doesn't have (there the room wallpaper runs all
          // the way to the icons). Same screen-local-override technique as
          // the status/nav-bar AnnotatedRegion above: force the inherited
          // Scaffold background transparent for this subtree so that gap
          // shows our own full-bleed RoomBackground instead of a default
          // dark fill, if the kit reads the ambient theme for that colour.
          child: Theme(
            data: Theme.of(mainContext).copyWith(
              scaffoldBackgroundColor: ColorManager.transparent,
              canvasColor: ColorManager.transparent,
            ),
            child: MediaQuery.removePadding(
              context: mainContext,
              removeTop: true,
              removeBottom: true,
              child: UTDAudioRoom(
                // UTD Stream connection credentials: the kit sends these as
                // X-App-Id / X-App-Secret to authenticate every room/token call to
                // the UTD Stream service. REQUIRED — emptying them breaks room entry.
                // Server-driven (admin-editable via /config/settings); the
                // build-time default is only the cold-start fallback (prod by
                // default, test-overridable via dart-define) so an empty/late config
                // can NEVER blank them and break room entry (the bug that broke
                // release 1.0.21) and a TEST build never uses the prod id.
                appId:
                RealtimeConfig.utdStreamAppId ??
                    RealtimeConfig.defaultUtdStreamAppId,
                appKey:
                RealtimeConfig.utdStreamAppKey ??
                    RealtimeConfig.defaultUtdStreamAppKey,
                // Which engine serves the room. Both hosts are the same service for
                // us — the vendor split token issuance onto a separate edge, we do
                // not. Empty means the kit keeps its own default, so an unset
                // config leaves behaviour exactly as it was.
                baseUrl: _engineBaseUrl,
                tokenBaseUrl: _engineBaseUrl,
                // Only hand the kit an EXISTING controller when it is still
                // connected (minimize/PiP restore). A leftover-but-disposed
                // controller from a previous entry is non-null yet not connected —
                // the kit would reuse it (it only auto-creates a fresh one when the
                // passed controller is null) and then connect() does addListener on
                // a disposed ValueNotifier → the red "used after disposed" crash.
                // Passing null forces a fresh UTDRoomController for every new entry.
                controller:
                (RoomData.instance.utdController?.isConnected ?? false)
                    ? RoomData.instance.utdController
                    : null,
                userId: MyDataModel.getInstance().id.toString(),
                userName:
                MyDataModel.getInstance().name ??
                    MyDataModel.getInstance().id.toString(),
                roomId: widget.roomId,
                roomOwnerId:
                (widget.ownerId.isNotEmpty && widget.ownerId != '0')
                    ? widget.ownerId
                    : RoomData.instance.room.ownerId.toString(),
                // Admins passed to the kit to bake the JOIN-TIME LiveKit role.
                // The kit reads this exactly once in _connect() (which runs BEFORE
                // wireRoleSync seeds adminsInRoom from enter-room), so we must union
                // the enter-room baseline (room.admins, populated at build) with the
                // live map (adminsInRoom, which carries in-session `_role_change`
                // deltas). Using adminsInRoom alone here left it empty at join, so a
                // real admin connected as 'audience' (no moderation perms) — which
                // also made the UI gates hide their own buttons. The app UI gates
                // keep reading the live adminsInRoom; this union only affects the
                // one-shot join-time token. Normalize ids (.toString()).
                adminIds: <String>{
                  ...(RoomData.instance.room.admins ?? const <String>[]).map(
                        (e) => e.toString(),
                  ),
                  ...RoomData.instance.adminsInRoom.keys.map((e) => e.toString()),
                },
                // Both sources above are usually EMPTY at build: navigation runs
                // before the enter-room response (which carries the admin list).
                // The kit NEVER waits on this resolver — everyone joins instantly
                // with the best-known role; when it resolves and lists this user
                // as an admin, the kit self-upgrades via the engine role endpoint
                // (server-side permissions + `_role_change`), so stored admins
                // still always end with full powers (owner bug 2026-06-12 stays
                // fixed) without gating anyone's join.
                adminIdsResolver:
                    () async =>
                    (await RoomData.instance.adminsWhenLoaded)
                        .map((e) => e.toString())
                        .toSet(),
                // Sync probe at token time: enter_room now fires at TAP (before
                // the route push), so its response often lands during the route
                // transition — in that case the join uses an `admin` token
                // directly and no upgrade round-trip is needed.
                adminIdsNow:
                    () => <String>{
                  ...(RoomData.instance.room.admins ?? const <String>[]).map(
                        (e) => e.toString(),
                  ),
                  ...RoomData.instance.adminsInRoom.keys.map(
                        (e) => e.toString(),
                  ),
                },
                layoutMode: RoomData.instance.room.mode ?? '3',
                onSeatChanged: (seats) {
                  // Do NOT clear()+recreate every GlobalKey on each seat change:
                  // minting a fresh key detaches it from the rendered seat widget for
                  // a frame, so LuckyGiftController.getSeatPosition() reads a null
                  // currentContext and the gift animation never targets the seat.
                  // Keep stable per-userId keys: reuse existing, add new, drop gone.
                  final currentUserIds = <String>{};
                  seatAvatarIds.clear();

                  for (final seat in seats) {
                    final userId = seat.occupantUserId;
                    if (userId == null || userId.isEmpty) continue;

                    currentUserIds.add(userId);
                    seatAvatarIds[seat.index] = userId;
                  }

                  // Audio-room seats use BuildContext targets instead of
                  // GlobalKeys. Drop only users who are no longer seated.
                  seatAvatarContexts.removeWhere(
                        (uid, _) => !currentUserIds.contains(uid),
                  );

                  // Clear any stale audio-room GlobalKeys left by an older
                  // build/version. LIVE-room headers register their keys in a
                  // different screen and are unaffected by this audio callback.
                  seatAvatarKeys.removeWhere(
                        (uid, _) => !currentUserIds.contains(uid),
                  );
                },
                onConnectionChanged: (isConnected) {
                  if (isConnected) _tryPublishSoundWaveAttribute();
                },
                onControllerReady: (controller) {
                  // Request BLUETOOTH_CONNECT on Android 12+ for ALL room members
                  // (not just mic users), so listeners also route audio to Bluetooth.
                  if (Platform.isAndroid) {
                    // Serialized + never throws (central permission requester).
                    Methods.requestPermission(Permission.bluetoothConnect);
                  }
                  // Configure the audio session for Bluetooth (HFP/SCO + A2DP) and
                  // route audio to a connected headset, falling back to the
                  // loudspeaker. Single source of truth for routing — overrides the
                  // kit's join-time speaker decision and tracks headset changes.
                  _setupBluetoothAwareAudio(controller);
                  controller.navigatorKey = navKey;
                  controller.minimize.configure(
                    UTDMinimizeConfig(
                      // Measured off Fuvio's party PiP: a tall STADIUM capsule --
                      // fully rounded ends, radius = half the width -- about
                      // 76x108, docked bottom-right above the nav bar.
                      //
                      // The face carries the room cover and nothing else. Fuvio
                      // shows no leave or mic control on the capsule; you tap it to
                      // come back. At this size a 28px button would eat a third of
                      // the width and it stops reading as a PiP.
                      //
                      // Set through config rather than overlayBuilder, because that
                      // hook replaces the whole overlay -- drag and edge-snap with it.
                      overlayWidth: 76,
                      overlayHeight: 108,
                      borderRadius: 38,
                      showLeaveButton: false,
                      showMicToggle: false,
                      roomImage: EndPoints.getImage(
                        RoomData.instance.room.roomCover,
                      ),
                      onClose: () {
                        final navContext = SafeNavigator.context;
                        if (navContext == null) return;
                        di<RoomStateManager>().exitRoom(navContext);
                      },
                    ),
                  );
                  RoomData.instance.utdController = controller;
                  UTDSeatWidget.nameGradient = ColorManager.brandGradient1;
                  // Pick up a Ludo game that is already running in this room.
                  LudoRoomController.instance.onRoomEntered(
                    int.tryParse('${RoomData.instance.room.id}') ?? 0,
                  );
                  CaromRoomController.instance.onRoomEntered(
                    int.tryParse('${RoomData.instance.room.id}') ?? 0,
                  );
                  RoomData.instance.wireRoleSync(controller);
                  // Retry the Sound Wave attribute publish once the local
                  // participant's publish permission actually lands -- see
                  // _tryPublishSoundWaveAttribute for why a single
                  // pre-upgrade attempt isn't enough.
                  controller.mediaController.canPublish
                      .addListener(_tryPublishSoundWaveAttribute);
                  controller.onForceExit = () async {
                    final ctx = navKey.currentContext;
                    if (ctx == null) return;
                    Methods.showToast(
                      ctx,
                      message: StringManager.unableToConnect.tr(),
                      isError: true,
                    );
                    await di<RoomStateManager>().exitRoom(ctx);
                    final popCtx = navKey.currentContext;
                    if (popCtx != null) {
                      Navigator.popUntil(
                        popCtx,
                            (route) => route.settings.name == Routes.layout,
                      );
                    }
                  };
                },
                onConnectError: (error, stackTrace) async {
                  // Initial token-generation / connect failure. Room ENTRY is NOT
                  // tied to UTD Stream: enter_room (app REST) already ran, so the
                  // user STAYS in the room. UTD Stream only powers audio/video and
                  // realtime broadcast — those won't work without it, which is
                  // acceptable. Browsing, gift and lucky-gift sending (app REST)
                  // keep working. The kit's reconnection force-exit timer only ARMS
                  // after a SUCCESSFUL connect, so when connect never succeeds,
                  // staying here will NOT auto-exit later. Show a small
                  // non-blocking notice ONCE — do NOT exitRoom / pop. The genuine
                  // teardown paths (onForceExit / ban / live-ended) are untouched.
                  if (_streamNoticeShown) return;
                  _streamNoticeShown = true;
                  final ctx = navKey.currentContext;
                  if (ctx == null) return;
                  Methods.showToast(
                    ctx,
                    message: StringManager.liveServiceUnavailable.tr(),
                    isError: false,
                  );
                },
                config: UTDAudioRoomConfig(
                  turnOnMicrophoneWhenJoining: false,
                  // Seat layout: bigger photo slots, equal gaps between the
                  // first three rows, and the seat block pushed down a little.
                  seatLayout: const UTDSeatLayout(
                    avatarRatio: 0.82,
                    seatScale: 1.12,
                    firstRowGap: 6,
                    seatsTopPadding: 10,
                  ),
                  useSpeakerWhenJoining: true,
                  showControlsBar: false,
                  // The comment/message composer opens as its own separate
                  // ModalRoute+Scaffold (AudioRoomInRoomMessageInputBoard),
                  // which already floats correctly above the keyboard. Keep
                  // the room itself fixed so its background/seats/side
                  // buttons don't ALSO shift up when the keyboard opens.
                  resizeToAvoidBottomInset: false,
                  emptySeatBuilder:
                      (index, size) => EmptySeat(index: index, size: size),
                  lockedSeatBuilder:
                      (index, size) => LockedSeatWidget(index: index, size: size),
                  avatarBuilder:
                      (userId, size, attributes, isMuted, seatIndex, userName) =>
                      GhostSeatGuard(
                        userId: userId,
                        seatIndex: seatIndex,
                        size: size,
                        child: SeatAvatarWidget(
                        // Never attach a per-user GlobalKey to an AUDIO seat.
                        // A stale seat and a new seat can overlap for one frame
                        // while opening/closing overlays such as the gift sheet.
                        // ValueKey is safe here; exact lucky-gift targeting is
                        // registered from SeatAvatarWidget's BuildContext.
                        key: ValueKey(
                          'audio_seat_${seatIndex}_$userId',
                        ),
                        userId: userId,
                        attributes: attributes,
                        size: size,
                      ),
                      ),
                  userInRoomAttributes: {
                    'fr': MyDataModel.getInstance().frame ?? "",
                    'avatar': EndPoints.getImage(
                      MyDataModel.getInstance().profile?.image,
                    ),
                    'frt': MyDataModel.getInstance().frameType ?? "",
                    'cn': MyDataModel.getInstance().vip1?.colorName ?? "",
                    // Local user's name so their seat initial is their name letter,
                    // not '?' when the avatar URL fails to load.
                    'name': MyDataModel.getInstance().name ?? "",
                    // SVIP "Sound Wave" perk (privilege type 21) — unlike
                    // `fr`/`frt` (Avatar Frame), the backend does NOT resolve
                    // this onto /api/my-data, so it's picked out of the VIP
                    // bag ourselves (see _resolveActiveSoundWaveSvga above).
                    // Broadcasting it here makes it visible on every OTHER
                    // client's copy of this seat, same as the frame is.
                    'sw': _resolveActiveSoundWaveSvga(),
                  },
                  backgroundWidget: BlocBuilder<RoomOverlayCubit, RoomOverlayState>(
                    bloc: di<RoomOverlayCubit>(),
                    buildWhen: (prev, curr) => prev.showPk != curr.showPk,
                    builder: (context, modeState) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          const BackgroundWidget(isAudioRoom: true),
                          const Positioned.fill(child: LudoAnimatedBackground()),
                          if (modeState.showPk)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(AssetsManager.pkBackground),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  headerWidget: RoomHeader(
                    imageColorEntity: RoomData.instance.room.ownerImageColor,
                    specialIdImage: RoomData.instance.room.ownerSpecialId ?? "",
                  ),
                  messagesWidget: const TabbedMessagesView(),
                  // Ludo: while a game is active the seat grid becomes one
                  // horizontally scrolling mic-seat row above the lobby/board.
                  seatsOverrideActive: GameRoomHub.active,
                  seatsOverrideBuilder: (seats, seatCreator, seatSize) =>
                      GameRoomHub.buildView(
                        seatCount: seats.length,
                        seatSize: seatSize,
                        seatCreator: seatCreator,
                      ),
                  controlsBarWidget: const ButtomBarWidget(),
                  foregroundWidget: ForegroundWidget(
                    imageColorEntity: widget.imageColorEntity,
                    specialIdImage: widget.specialIdImage,
                    isAudioRoom: true,
                    giftButtonCallBack: () {
                      bottomDailog(
                        context: mainContext,
                        barrierColor: ColorManager.transparent,
                        widget: GiftScreen(
                          users: RoomService.instance.getAllUsers(),
                          roomData: RoomData.instance.room,
                          myDataModel: widget.userModel,
                          isSingleUser: false,
                          isAudioRoom: true,
                          userId: null,
                          userImage: null,
                          userName: null,
                        ),
                      );
                    },
                  ),
                  pkWidget: BlocBuilder<RoomOverlayCubit, RoomOverlayState>(
                    bloc: di<RoomOverlayCubit>(),
                    buildWhen: (prev, curr) => prev.showPk != curr.showPk,
                    builder: (context, modeState) {
                      if (!modeState.showPk) return const SizedBox();
                      return PKWidget(
                        scoreBlueTeam: PkController.scoreBlue,
                        scoreRedTem: PkController.scoreRed,
                        isHost:
                        MyDataModel.getInstance().id ==
                            RoomData.instance.room.ownerId,
                        ownerId: RoomData.instance.room.ownerId.toString(),
                        notifyRoom: activePK,
                        roomId: RoomData.instance.room.id.toString(),
                      );
                    },
                  ),
                ),
                onSeatTap: (index, seat) {
                  if (index == 0 && !widget.isHost && seat.isEmpty) {
                    return;
                  }
                  final user =
                  seat.occupantUserId != null
                      ? UTDParticipant(id: seat.occupantUserId!, name: '')
                      : null;
                  final navContext = SafeNavigator.context;
                  if (navContext == null) return;
                  showSeatOptionsSheet(navContext, index, user);
                },
                modes: _buildRoomModes(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}