import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/room.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// Live-room gift recipient picker — the standalone counterpart of the audio
/// room's `GiftUser`. Recipients are resolved directly from the LIVE controller
/// (the host plus the on-stage guests), NOT from the audio seat controller, and
/// there is no audio seat-index badge. Selection is held in [userSelected],
/// which the live bottom bar reads to build the send.
class LiveGiftRecipients extends StatefulWidget {
  final bool useNewThemeLayout;
  final double containerHeight;
  final Color selectedBorderColor;
  final Color labelTextColor;
  final Color allButtonBackgroundColor;
  final Color allButtonTextColor;
  final double allButtonBorderRadius;

  const LiveGiftRecipients({
    super.key,
    required this.useNewThemeLayout,
    required this.containerHeight,
    required this.selectedBorderColor,
    required this.labelTextColor,
    required this.allButtonBackgroundColor,
    required this.allButtonTextColor,
    required this.allButtonBorderRadius,
  });

  /// Currently selected recipients, keyed by numeric user id (falls back to the
  /// list index for non-numeric ids). Read by the live bottom bar at send time.
  static final ValueNotifier<Map<int, UTDParticipant>> userSelected =
      ValueNotifier<Map<int, UTDParticipant>>({});

  static void clearAll() => userSelected.value = {};

  @override
  State<LiveGiftRecipients> createState() => _LiveGiftRecipientsState();
}

class _LiveGiftRecipientsState extends State<LiveGiftRecipients> {
  final Map<int, UserInRoomModel> _profiles = {};
  final Set<int> _pendingFetch = {};

  @override
  void initState() {
    super.initState();
    LiveGiftRecipients.userSelected.value = {};
  }

  /// Host first (full-bleed tile, not always in the seats list), then the
  /// occupied guest seats. Deduped by id.
  List<UTDParticipant> _recipients(List<live.SeatState> seats) {
    final controller = LiveRoomData.instance.liveController;
    final hostId = LiveRoomData.instance.room.ownerId.toString();
    final out = <UTDParticipant>[];
    final seen = <String>{};

    if (hostId.isNotEmpty && hostId != '0') {
      final hostAvatar = controller?.avatarUrlFor(hostId);
      out.add(
        UTDParticipant(
          id: hostId,
          name: controller?.displayNameFor(hostId) ?? '',
          attributes: {if (hostAvatar != null) 'avatar': hostAvatar},
        ),
      );
      seen.add(hostId);
    }
    for (final s in seats) {
      final id = s.occupantUserId;
      if (id == null || id.isEmpty || seen.contains(id)) continue;
      out.add(
        UTDParticipant(id: id, name: s.attributes['name'] ?? '', attributes: s.attributes),
      );
      seen.add(id);
    }
    return out;
  }

  /// Fetches any missing recipient profiles (for avatars/names), cache-first.
  void _ensureProfiles(List<UTDParticipant> recipients) {
    final missing = <int>[];
    for (final r in recipients) {
      final id = int.tryParse(r.id);
      if (id == null || _profiles.containsKey(id) || _pendingFetch.contains(id)) {
        continue;
      }
      final cached = UsersCache().getUser(id) ?? RoomData.instance.users[id];
      if (cached != null) {
        _profiles[id] = cached;
      } else {
        missing.add(id);
      }
    }
    if (missing.isEmpty) return;
    _pendingFetch.addAll(missing);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetched = await getUsersByIds(missing);
      if (!mounted) return;
      setState(() {
        _profiles.addEntries(
            fetched.entries.map((e) => MapEntry(e.key, e.value)));
        _pendingFetch.removeAll(missing);
      });
    });
  }

  String _avatarOf(UTDParticipant user, int userId) {
    final fromAttr = user.attributes['avatar'];
    if (fromAttr != null && fromAttr.isNotEmpty) return fromAttr;
    return _profiles[userId]?.image ?? '';
  }

  void _toggle(int userId, UTDParticipant user) {
    final next = {...LiveGiftRecipients.userSelected.value};
    if (next.containsKey(userId)) {
      next.remove(userId);
    } else {
      next[userId] = user;
    }
    LiveGiftRecipients.userSelected.value = next;
  }

  void _toggleAll(List<UTDParticipant> recipients) {
    if (LiveGiftRecipients.userSelected.value.isEmpty) {
      final all = <int, UTDParticipant>{};
      for (var i = 0; i < recipients.length; i++) {
        final id = int.tryParse(recipients[i].id) ?? i;
        all[id] = recipients[i];
      }
      LiveGiftRecipients.userSelected.value = all;
    } else {
      LiveGiftRecipients.userSelected.value = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = LiveRoomData.instance.liveController;
    final seatsNotifier =
        controller?.seatController.seats ?? ValueNotifier(<live.SeatState>[]);
    return Padding(
      padding: context.paddingAll(4.0),
      child: SizedBox(
        height: widget.containerHeight,
        child: ValueListenableBuilder<List<live.SeatState>>(
          valueListenable: seatsNotifier,
          builder: (context, seats, _) {
            final recipients = _recipients(seats);
            _ensureProfiles(recipients);
            return ValueListenableBuilder<Map<int, UTDParticipant>>(
              valueListenable: LiveGiftRecipients.userSelected,
              builder: (context, selected, __) =>
                  _row(context, recipients, selected),
            );
          },
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    List<UTDParticipant> recipients,
    Map<int, UTDParticipant> selected,
  ) {
    final avatarRadius = widget.useNewThemeLayout ? 16.w : 20.w;
    final imageSize = widget.useNewThemeLayout ? 28.w : 36.w;

    final list = SizedBox(
      height: widget.useNewThemeLayout ? 33.h : null,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: !widget.useNewThemeLayout,
        padding: EdgeInsets.zero,
        itemCount: recipients.length,
        itemBuilder: (context, index) {
          final user = recipients[index];
          final userId = int.tryParse(user.id) ?? index;
          final img = _avatarOf(user, userId);
          final isSelected = selected.containsKey(userId);
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: InkWell(
              onTap: () => _toggle(userId, user),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: isSelected
                    ? widget.selectedBorderColor
                    : ColorManager.transparent,
                child: ClipOval(
                  child: img.isNotEmpty
                      ? ImageViewWidget(
                          width: imageSize,
                          height: imageSize,
                          url: img,
                          boxFit: BoxFit.cover,
                          displayName: user.name,
                        )
                      : InitialsAvatar(name: user.name, size: imageSize),
                ),
              ),
            ),
          );
        },
      ),
    );

    final allButton = InkWell(
      onTap: () => _toggleAll(recipients),
      child: Container(
        padding: widget.useNewThemeLayout
            ? context.paddingAll(3)
            : context.paddingSymmetric(horizontal: 15, vertical: 7.0),
        decoration: BoxDecoration(
          color: widget.allButtonBackgroundColor,
          borderRadius: BorderRadius.circular(
              widget.useNewThemeLayout ? 50 : widget.allButtonBorderRadius),
        ),
        child: widget.useNewThemeLayout
            ? const Icon(Icons.keyboard_arrow_down_outlined,
                color: ColorManager.white)
            : Text('All',
                style: context.bodyMedium.colorExt(widget.allButtonTextColor)),
      ),
    );

    if (widget.useNewThemeLayout) {
      return Row(
        children: [
          TextWidget(StringManager.send,
              style: context.bodySmall.colorExt(widget.labelTextColor)),
          5.wBox,
          Flexible(child: list),
          allButton,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 325.w, child: list),
        allButton,
      ],
    );
  }
}
