import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/chat_repository.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_setting_manager/get_setting_bloc.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/send_message_all/send_message_all_bloc.dart';
import 'package:general/src/features/room/presentation/share/room_share_dialog.dart';
import 'package:general/src/features/room/room.dart';

/// WhatsApp-style share sheet for the live stream.
///
/// Two share paths:
///  - INTERNAL via Wats Jo: the user's recent chats (1:1 and groups, straight
///    from the offline-first drift rooms list), pick up to 5, send. The message
///    lands as a live card (`share_room:` wire) that joins the stream on tap —
///    DMs through the existing share fan-out API (server builds the image
///    card), groups through the offline-first group outbox.
///  - EXTERNAL: the regular OS share with the room dynamic link.
class LiveShareSheet {
  /// Single entry point for the live share action (viewer bottom bar + the
  /// host's (...) sheet): the Wats Jo sheet when in-app sharing is enabled,
  /// otherwise the plain OS share with the room link.
  static Future<void> open(BuildContext context) {
    final room = RoomData.instance.room;
    if (ConstantsManager.isShareWithFriends == true) {
      return show(context, room);
    }
    return shareRoomLink(context, room);
  }

  static Future<void> show(BuildContext context, EnterRoomModel room) {
    // The share wire includes the backend shared key — fetch it like the
    // internal share screen does (cheap, cached server settings).
    di<GetSettingBloc>().add(const GetSettingsEvent());
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LiveShareSheetBody(room: room),
    );
  }
}

class _LiveShareSheetBody extends StatefulWidget {
  final EnterRoomModel room;

  const _LiveShareSheetBody({required this.room});

  @override
  State<_LiveShareSheetBody> createState() => _LiveShareSheetBodyState();
}

class _LiveShareSheetBodyState extends State<_LiveShareSheetBody> {
  static const int _maxSelection = 5;

  /// Selected conversations by drift local id.
  final Set<int> _selected = {};
  bool _sending = false;

  String get _wire {
    final secretKey =
        di<GetSettingBloc>().state.settingModel?.sharedKey ?? '-';
    return 'share_room:$secretKey:${widget.room.roomName}\n'
        ':${widget.room.id}:Room';
  }

  void _toggle(Room room) {
    setState(() {
      if (_selected.contains(room.localId)) {
        _selected.remove(room.localId);
      } else if (_selected.length >= _maxSelection) {
        Methods.showToast(
          context,
          isError: true,
          message: StringManager.maxFiveChats.tr(),
        );
      } else {
        _selected.add(room.localId);
      }
    });
  }

  Future<void> _send(List<RoomWithLast> rooms) async {
    if (_selected.isEmpty || _sending) return;
    setState(() => _sending = true);

    final chosen =
        rooms.where((r) => _selected.contains(r.room.localId)).toList();
    final dmPeerIds = <int>[
      for (final r in chosen)
        if (r.room.type == RoomType.dm && r.room.peerUserId != null)
          r.room.peerUserId!,
    ];
    final groups = [
      for (final r in chosen)
        if (r.room.type == RoomType.group && (r.room.groupId ?? 0) > 0) r.room,
    ];

    // DMs: the share fan-out API — the server builds the image+wire card the
    // 1:1 thread already renders.
    if (dmPeerIds.isNotEmpty) {
      di<SendMessageAllBloc>().add(SendMessageAllEvent(
        type: 'one',
        exceptUsers: '',
        url: widget.room.roomCover ?? '',
        message: _wire,
        users: dmPeerIds.join(','),
      ));
    }

    // Groups: offline-first outbox — the group bubble renders the wire as a
    // live join card.
    for (final g in groups) {
      await di<ChatRepository>().sendGroup(
        roomLocalId: g.localId,
        serverGroupId: g.groupId!,
        sendPath: EndPoints.groupSendMessage(g.groupId!),
        body: _wire,
      );
    }

    _announceShare();
    if (!mounted) return;
    Methods.showToast(context, message: StringManager.success.tr());
    Navigator.pop(context);
  }

  /// One distinctive chat line for everyone in the live when a viewer shares
  /// the broadcast (owner spec 2026-06-12): "«فلان» شارك البث المباشر 📤" —
  /// the `sharedLive` sentinel is localized in LiveMessagesView.
  void _announceShare() {
    final me = MyDataModel.getInstance();
    LiveRoomData.instance.chatController?.sendMessage(
      '${me.name ?? ''} sharedLive',
      userData: {
        'img': me.profile?.image ?? '',
        'senderId': me.id?.toString() ?? '',
        'senderName': me.name ?? '',
        'type': 'message',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fixed white sheet / black text on request (was following the app body
    // theme background, which could be dark and made the request moot).
    // Height stays a fraction of the screen so this scales across devices.
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: ColorManager.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                12.hBox,
                Row(
                  children: [
                    Text(
                      StringManager.shareLiveTitle.tr(),
                      style:
                          context.bodyLarge.bold.colorExt(ColorManager.black),
                    ),
                    const Spacer(),
                    if (_selected.isNotEmpty)
                      Text(
                        '${_selected.length}/$_maxSelection',
                        style:
                            context.bodyMedium.colorExt(ColorManager.primary),
                      ),
                  ],
                ),
                10.hBox,
                Text(
                  StringManager.recentChats.tr(),
                  style: context.bodySmall
                      .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                ),
                6.hBox,
                Expanded(
            child: StreamBuilder<List<RoomWithLast>>(
              stream: di<RoomsDao>().watchRoomsWithLast(),
              builder: (context, snapshot) {
                final rooms = (snapshot.data ?? const <RoomWithLast>[])
                    .take(25)
                    .toList();
                if (rooms.isEmpty) {
                  return Center(
                    child: Text(
                      StringManager.noChats.tr(),
                      style: context.bodyMedium
                          .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, i) {
                          final room = rooms[i].room;
                          final selected =
                              _selected.contains(room.localId);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () => _toggle(room),
                            leading: UserImage(
                              image: room.avatarUrl ?? '',
                              displayName: room.title ?? '',
                              imageSize: 44.h,
                            ),
                            title: Text(
                              room.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyMedium.w600
                                  .colorExt(ColorManager.black),
                            ),
                            subtitle: room.type == RoomType.group
                                ? Text(
                                    StringManager.groups.tr(),
                                    style: context.bodySmall.colorExt(
                                        ColorManager.black
                                            .withValues(alpha: 0.6)),
                                  )
                                : null,
                            trailing: selected
                                ? _GradientIcon(
                                    icon: Icons.check_circle, size: 22.sp)
                                : Icon(
                                    Icons.radio_button_unchecked,
                                    color:
                                        ColorManager.black.withValues(alpha: 0.35),
                                  ),
                          );
                        },
                      ),
                    ),
                    10.hBox,
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: _selected.isEmpty || _sending
                            ? null
                            : () => _send(rooms),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primary,
                          disabledBackgroundColor:
                              ColorManager.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23.r),
                          ),
                        ),
                        child: _sending
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ColorManager.buttonTextColor,
                                ),
                              )
                            : Text(
                                StringManager.send.tr(),
                                style: context.bodyMedium.w700
                                    .colorExt(ColorManager.buttonTextColor),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
                10.hBox,
                Divider(
                    color: ColorManager.black.withValues(alpha: 0.1),
                    height: 1.h),
                8.hBox,
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    await shareRoomLink(context, widget.room);
                    // The system sheet gives no completion signal; sharing
                    // intent shown = announced (same as TikTok's behavior).
                    _announceShare();
                  },
                  child: Padding(
                    padding: context.paddingSymmetric(vertical: 8),
                    child: Row(
                      children: [
                        _GradientIcon(icon: Icons.share_outlined, size: 20.sp),
                        10.wBox,
                        Text(
                          StringManager.externalShare.tr(),
                          style: context.bodyMedium
                              .colorExt(ColorManager.black),
                        ),
                        const Spacer(),
                        _GradientIcon(
                            icon: Icons.arrow_forward_ios, size: 14.sp),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

/// Icon tinted with the brand gradient (pink -> purple,
/// [ColorManager.brandGradientColors]) instead of a flat color, on request.
class _GradientIcon extends StatelessWidget {
  const _GradientIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => ColorManager.brandGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Icon(icon, size: size, color: ColorManager.white),
    );
  }
}
