import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/presentation/room_controls/room_controls.dart';
import 'package:general/src/features/room/room.dart';

const Color _kPurple = Color(0xFFA510FB);
const Color _kInk = Color(0xFF1B1B1F);
const Color _kSoft = Color(0xFF8A8A99);

/// Which control the sheet manages.
enum RoomControlKind { allMute, commentLock }

/// Owner/admin sheet for All Mute or Comment Lock: one master switch, and
/// while it is on, a list of people with a switch each to let them speak /
/// comment anyway.
class RoomControlsSheet extends StatefulWidget {
  final RoomControlKind kind;

  const RoomControlsSheet({super.key, required this.kind});

  @override
  State<RoomControlsSheet> createState() => _RoomControlsSheetState();
}

class _RoomControlsSheetState extends State<RoomControlsSheet> {
  final RoomControls _controls = RoomControls.instance;
  StreamSubscription<List<UTDParticipant>>? _participantsSub;

  bool get _isMute => widget.kind == RoomControlKind.allMute;

  @override
  void initState() {
    super.initState();
    final c = RoomData.instance.utdController;
    c?.seatController.seats.addListener(_refresh);
    _participantsSub = c?.participantsStream.listen((_) => _refresh());
  }

  @override
  void dispose() {
    _participantsSub?.cancel();
    RoomData.instance.utdController?.seatController.seats
        .removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ValueListenableBuilder<RoomControlsState>(
      valueListenable: _controls.state,
      builder: (context, s, _) {
        final on = _isMute ? s.allMute : s.commentLock;
        final allowed = _isMute ? s.muteAllow : s.commentAllow;
        final people =
            _isMute ? _controls.seatedNormalUsers() : _controls.roomNormalUsers();
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h + bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2EA),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              14.hBox,
              _header(on),
              14.hBox,
              if (!on)
                _hint(_isMute
                    ? 'Turn on to mute everyone on a seat. Owner and admins '
                        'can still speak, and you can let chosen people speak.'
                    : 'Turn on to stop everyone from commenting. Owner and '
                        'admins can still comment, and you can let chosen '
                        'people comment.')
              else ...[
                Text(
                  _isMute
                      ? 'Allow to speak (${allowed.length})'
                      : 'Allow to comment (${allowed.length})',
                  style: TextStyle(
                    color: _kInk,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                4.hBox,
                Text(
                  _isMute
                      ? 'People on a seat. Leaving the seat ends the permission.'
                      : 'Everyone in the room.',
                  style: TextStyle(color: _kSoft, fontSize: 11.5.sp),
                ),
                8.hBox,
                if (people.isEmpty)
                  _hint(_isMute
                      ? 'Nobody is on a seat right now.'
                      : 'Nobody else is in the room right now.')
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: people.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFFF0F0F5),
                      ),
                      itemBuilder: (_, i) {
                        final id = people[i];
                        return _PersonRow(
                          userId: id,
                          allowed: allowed.contains(id),
                          onChanged: (v) => _isMute
                              ? _controls.setMuteAllowed(id, v)
                              : _controls.setCommentAllowed(id, v),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _header(bool on) {
    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: const BoxDecoration(
            gradient: ColorManager.brandGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isMute ? Icons.mic_off_rounded : Icons.speaker_notes_off_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
        ),
        12.wBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isMute ? 'All Mute' : 'All Comment Lock',
                style: TextStyle(
                  color: _kInk,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              2.hBox,
              Text(
                on
                    ? (_isMute ? 'On: seats are muted' : 'On: comments are locked')
                    : 'Off',
                style: TextStyle(
                  color: on ? _kPurple : _kSoft,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: on,
          activeTrackColor: _kPurple,
          onChanged: (v) =>
              _isMute ? _controls.setAllMute(v) : _controls.setCommentLock(v),
        ),
      ],
    );
  }

  Widget _hint(String text) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: const Color(0xFF5A4C7A), fontSize: 12.5.sp),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final String userId;
  final bool allowed;
  final ValueChanged<bool> onChanged;

  const _PersonRow({
    required this.userId,
    required this.allowed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(userId) ?? 0;
    final cached = UsersCache().getUser(id);
    if (cached != null || id <= 0) return _row(cached);
    return FutureBuilder<Map<int, UserInRoomModel>>(
      future: getUsersByIds([id]),
      builder: (_, snap) => _row(snap.data?[id]),
    );
  }

  Widget _row(UserInRoomModel? user) {
    final name = (user?.name?.isNotEmpty ?? false) ? user!.name! : 'User $userId';
    final shownId = (user?.uuid?.isNotEmpty ?? false) ? user!.uuid! : userId;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          UserImage(
            image: EndPoints.getImage(user?.image ?? ''),
            uniquId: userId,
            displayName: name,
            imageSize: 40.sp,
          ),
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _kInk,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ID: $shownId',
                  style: TextStyle(color: _kSoft, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: allowed,
            activeTrackColor: _kPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Small "ON" pill for the tools-sheet tile while the control is on.
class RoomControlOnBadge extends StatelessWidget {
  final RoomControlKind kind;

  const RoomControlOnBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RoomControlsState>(
      valueListenable: RoomControls.instance.state,
      builder: (_, s, __) {
        final on = kind == RoomControlKind.allMute ? s.allMute : s.commentLock;
        if (!on) return const SizedBox.shrink();
        return Positioned(
          top: 0,
          right: 6.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            decoration: BoxDecoration(
              gradient: ColorManager.brandGradient,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'ON',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}
