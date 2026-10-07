import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/room/presentation/component/room_header/exit_room/exit_side_panel_overlay.dart';
import 'package:general/src/features/room/presentation/share/room_share_dialog.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/vip/vip.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

class RoomHeader extends StatefulWidget {
  final String? specialIdImage;
  final ImageColorEntity? imageColorEntity;

  const RoomHeader({
    super.key,
    this.specialIdImage,
    this.imageColorEntity,
  });

  @override
  State<RoomHeader> createState() => _RoomHeaderState();
}

class _RoomHeaderState extends State<RoomHeader> {
  // Tried keying a shared/static GlobalKey by `RoomData.instance.room.id`
  // first, but `RoomData.instance` is a mutable global singleton: on a room
  // switch or a fast exit-then-re-enter, the OLD RoomHeader's Element can
  // still be mid-teardown (Navigator animating it out) for one more build
  // *after* `RoomData.instance.room` has already been overwritten to point
  // at the NEW room. Both the old and new RoomHeader then read the SAME
  // "current" room id from that singleton and fetch the SAME map entry --
  // Flutter's "Multiple widgets used the same GlobalKey" -- which made this
  // widget fail to build for that frame: the header vanished and the seat
  // grid rendered full-height with nothing above it.
  //
  // A `late final` field on State instead ties the key to THIS Element's
  // own lifetime, not to whatever the shared singleton currently says, so
  // two RoomHeaders never share a key even while briefly co-mounted.
  late final GlobalKey _measureKey = GlobalKey();

  void _reportHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final height = _measureKey.currentContext?.size?.height;
      if (height != null) RoomData.instance.headerHeight.value = height;
    });
  }

  @override
  Widget build(BuildContext context) {
    _reportHeight();
    return ValueListenableBuilder(
        valueListenable: OwnerOfRoom.isEditRoom,
        builder: (context, value, child) {
          return Padding(
            key: _measureKey,
            padding: context.paddingOnly(
              start: 8.0,
              end: 8.0,
              bottom: 8.0,
              top: 35.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (HomePage.isConnectToInternet == true) {
                          context.pushNamedRoute(
                            Routes.settingScreenRoom,
                            arguments: RoomData.instance.room,
                          );
                        } else {
                          Methods.showToast(
                            context,
                            message: StringManager.pleaseCheckInternet.tr(),
                            isError: true,
                          );
                        }
                      },
                      child: OwnerOfRoom(
                        roomName:
                            RoomData.instance.roomDataUpdates['room_name'] == ''
                                ? RoomData.instance.room.roomName ?? ''
                                : RoomData.instance
                                        .roomDataUpdates['room_name'] ??
                                    '',
                        roomData: RoomData.instance.room,
                        introRoom:
                            RoomData.instance.roomDataUpdates['room_intro'] ??
                                '',
                        roomImg:
                            RoomData.instance.roomDataUpdates['room_img'] == ''
                                ? RoomData.instance.room.roomCover ?? ""
                                : RoomData
                                        .instance.roomDataUpdates['room_img'] ??
                                    "",
                        imageColorEntity: widget.imageColorEntity,
                        specialIdImage: widget.specialIdImage,
                      ),
                    ),
                    Padding(
                      padding: context.paddingOnly(top: 10),
                      child: Row(
                        children: [
                          MultiTapCard(
                            onTap: () async {
                              if (ConstantsManager.isShareWithFriends == true) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  // White sheet on request -- was falling
                                  // through to the theme's default modal
                                  // background.
                                  backgroundColor: ColorManager.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r)),
                                  ),
                                  builder: (_) => RoomShareDialog(
                                      roomEntity: RoomData.instance.room),
                                );
                              } else {
                                await shareRoomLink(
                                    context, RoomData.instance.room);
                              }
                            },
                            child: Image.asset(
                              AssetsManager.shareRoom,
                              width: 20.w,
                              color: ColorManager.onDark,
                            ),
                          ),
                          10.wBox,
                          InkWell(
                            child: Image.asset(
                              AssetsManager.exitRoomIcon,
                              width: 26.w,
                              height: 26.w,
                              color: ColorManager.onDark,
                            ),
                            onTap: () {
                              ExitSidePanelOverlay.show(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                10.hBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RankWidget(roomEntity: RoomData.instance.room),
                    // No duration chip in a party room. A party is a place
                    // people come and go from, not a broadcast with a running
                    // time, and the number next to the rank read as a countdown.
                    // The LIVE room keeps its chip -- that one is a session with
                    // a real start and end.
                    const Spacer(),
                    StreamBuilder<List<UTDParticipant>>(
                      stream: RoomService.instance.getUserListStream(),
                      builder: (context, snapshot) {
                        final visitors =
                            snapshot.data ?? RoomService.instance.getAllUsers();
                        return NumberOfVisitor(
                          ownerId: '${RoomData.instance.room.ownerId}',
                          vistors: visitors,
                          myDataModel: MyDataModel.getInstance(),
                          roomData: RoomData.instance.room,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

bool equalsUserLists(
  List<UTDParticipant> prev,
  List<UTDParticipant> next,
) {
  if (prev.length != next.length) return false;
  for (int i = 0; i < prev.length; i++) {
    if (prev[i].id != next[i].id) return false;
  }
  return true;
}
