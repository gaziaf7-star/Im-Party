import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';
import 'package:general/src/features/home/domain/home_use_case/create_room_use_case.dart';
import 'package:general/src/features/home/home.dart';

/// TikTok-style go-live entry.
///
/// The bottom bar's centre camera button opens a SMALL chooser (audio room /
/// live broadcast) instead of the old "start a show" page. Picking the
/// broadcast goes straight to the camera (the live room screen in host
/// preview): no create-room form — a live "room" still exists backend/admin-
/// side, but it is created silently here with a default title the host can
/// edit on the pre-live screen.
class GoLiveFlow {
  GoLiveFlow._();

  static bool _creating = false;

  /// The small audio/live chooser. [rooms] is the user's owned shows
  /// (from the home header's FetchMyRoomDataBloc state).
  ///
  /// No sheet panel and no dark scrim any more (on request) — the two round
  /// gradient badges float directly over whatever page is behind them,
  /// exactly like the reference image. `backgroundColor`/`barrierColor` are
  /// both transparent so nothing is drawn except the badges themselves; the
  /// barrier still exists and still catches an outside tap to dismiss, it
  /// just isn't painted.
  static Future<void> showStartDialog(
      BuildContext context,
      MyRoomsModel? rooms,
      ) {
    final ar = Methods.getLang() == 'ar';

    // Same fixed height as the bottom nav bar in layout_page.dart
    // (_kBarHeightBase there is also 72) — kept as a literal here rather than
    // importing that page's private constant, so the badges land floating
    // just ABOVE the nav bar instead of overlapping/covering it, matching
    // the reference image (nav bar still fully visible underneath).
    const double navBarHeight = 72;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      elevation: 0,
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.of(sheetCtx).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 28.h,
            // Was SafeArea(top: false) + a flat 28.h bottom padding, which
            // let the sheet sit flush with the very bottom of the screen —
            // right on top of the app's own bottom nav bar, hiding it. This
            // reserves that nav bar's own height (+ a small gap + the
            // device's safe-area inset) so the badges float just above it.
            bottom: 28.h + navBarHeight.h + 12.h + bottomInset,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (ConstantsManager.isAudioRoomsEnabled)
                _ChoiceCard(
                  // Was Icons.mic_rounded (a plain Material glyph) — now
                  // the real mic artwork, per the reference image.
                  imageAsset: AssetsManager.mic,
                  // Blue -> green diagonal gradient, matching the
                  // reference image's "Live Audio" badge.
                  gradientColors: const [
                    Color(0xFF00C6FF),
                    Color(0xFF00F260),
                  ],
                  // Literal "Live Audio" — was the dynamic "My Room"/"Audio
                  // Room" text; changed to match the reference image's
                  // label exactly, on request.
                  label: 'Live Audio',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    Methods.handleRoomEntry(context, rooms?.audio);
                  },
                ),
              if (ConstantsManager.isShowLive)
                _ChoiceCard(
                  // Was Icons.videocam_rounded — now the same camera
                  // artwork used elsewhere for the live/video option.
                  imageAsset: AssetsManager.streamIconUnActive,
                  // The app's own pink -> purple brand gradient, matching
                  // the reference image's "Live Video" badge and pairing
                  // with the bottom nav's own selected-gradient colour.
                  gradientColors: ColorManager.brandGradientColors,
                  // Literal "Live Video" — was "Go Live"; changed to match
                  // the reference image's label exactly, on request (Arabic
                  // keeps its own existing text, no reference was given for
                  // that language).
                  label: ar ? 'بث مباشر' : 'Live Video',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    startLive(context, rooms?.live);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Enters the host's live show. With no existing live, the backing room is
  /// created silently (type=live, default title = the host's name) — the user
  /// never sees a create-room form.
  static Future<void> startLive(BuildContext context, MyRoom? live) async {
    if (live != null) {
      _enterLive(context, id: live.id, name: live.name, cover: live.cover,
          background: live.roomBackground, mode: live.mode.toString(),
          giftPrice: live.giftPrice);
      return;
    }
    if (_creating) return;
    _creating = true;
    // Instant tap feedback while the room is created silently in the
    // background — was completely silent during this network round-trip
    // (the loading toast only fired later, inside navigateToRoom, once
    // creation finished), which made "Live Video" feel slow to enter.
    if (context.mounted) {
      Methods.showToast(context, isLoading: true);
    }
    final me = MyDataModel.getInstance();
    final defaultTitle = (me.name?.trim().isNotEmpty ?? false)
        ? (Methods.getLang() == 'ar' ? 'بث ${me.name}' : "${me.name}'s live")
        : (Methods.getLang() == 'ar' ? 'بث مباشر' : 'Live');
    try {
      final result = await di<CreateRoomUC>().call(
        CreateRoomParameter(
          roomName: defaultTitle,
          roomIntero: '',
          roomPassword: '',
          type: 'live',
        ),
      );
      result.fold(
            (failure) {
          if (context.mounted) {
            Methods.showToast(
              context,
              isError: true,
              message: NetworkExceptions.getErrorMessage(failure),
            );
          }
        },
            (success) {
          final room = success.data;
          if (room == null || !context.mounted) return;
          _enterLive(context, id: room.id, name: room.name, cover: room.cover,
              background: room.roomBackground, mode: room.mode.toString(),
              giftPrice: room.giftPrice);
        },
      );
    } finally {
      _creating = false;
    }
  }

  static void _enterLive(
      BuildContext context, {
        required int? id,
        String? name,
        String? cover,
        String? background,
        String? mode,
        String? giftPrice,
      }) {
    final me = MyDataModel.getInstance();
    di<RoomStateManager>().navigateToRoom(
      RoomEntryRequest(
        context: context,
        roomData: RoomEntity(
          ownerId: me.id,
          id: id,
          name: name,
          cover: cover,
          roomBackground: background,
          mode: mode,
          uuidOwnerRoom: me.uuid ?? "",
          giftPrice: giftPrice,
          ownerSpecialId: me.specialIdImage,
          ownerImageColor: me.imageColorEntity,
          streamType: "live",
          isLive: true,
        ),
        isLive: true,
      ),
    );
  }
}

/// One round icon "badge" in the go-live chooser sheet: a diagonal gradient
/// circle (per [gradientColors]) with the real icon artwork on top in plain
/// white, and a label underneath — matches the reference image exactly, and
/// replaces the old flat-tinted-circle + Material-glyph look.
class _ChoiceCard extends StatelessWidget {
  final String imageAsset;
  final List<Color> gradientColors;
  final String label;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.imageAsset,
    required this.gradientColors,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72.h,
            width: 72.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            // Tinted plain white so the badge reads the same regardless of
            // whatever baked-in colour the source artwork has — matches the
            // reference image's flat-white glyphs on the gradient circle.
            child: ImageWidget(
              image: imageAsset,
              height: 30.h,
              width: 30.h,
              color: Colors.white,
            ),
          ),
          10.hBox,
          // White + a soft shadow instead of the old fixed dark grey — now
          // that the sheet has no white panel/dark scrim behind it (on
          // request), a dark label would go unreadable against whatever page
          // content is showing through underneath.
          TextWidget(
            label,
            style: context.bodyMedium.w600.colorExt(Colors.white).copyWith(
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}