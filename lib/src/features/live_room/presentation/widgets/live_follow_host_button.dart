import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';

/// TikTok-style "متابعة" pill — next to the broadcast card in the live header
/// and next to the host card in the stream details sheet.
///
/// Visible ONLY while the local user does NOT follow the host (state ships in
/// enter_room's `is_following_owner`) and is not the host. Tapping reuses the
/// EXISTING follow action ([FollowBloc] -> relations/follow) and animates the
/// pill out. Colored with the server-driven [ColorManager.primary].
class LiveFollowHostButton extends StatelessWidget {
  /// Compact variant rendered INSIDE the broadcast card (smaller pill at the
  /// card's end edge — owner 2026-06-12). The details sheet keeps the default.
  final bool dense;

  const LiveFollowHostButton({super.key, this.dense = false});

  void _follow() {
    final ownerId = LiveRoomData.instance.roomOrNull?.ownerId;
    if (ownerId == null) return;
    di<FollowBloc>().add(FollowEvent(
      userEntity: UserEntity(id: ownerId),
      relationType: RelationType.profile,
    ));
    // Optimistic hide + the one-per-session "followedLive" chat announcement —
    // FollowBloc itself emits success optimistically; on a network error the
    // server state simply re-shows the pill on next entry.
    LiveRoomData.instance.noteHostFollowed(ownerId);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LiveRoomData.instance.followsHost,
      builder: (context, follows, _) {
        final ownerId = LiveRoomData.instance.roomOrNull?.ownerId;
        final show = !follows &&
            ownerId != null &&
            MyDataModel.getInstance().id != ownerId;
        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: show
              ? Padding(
                  padding: dense
                      ? EdgeInsetsDirectional.only(end: 8.w)
                      : EdgeInsetsDirectional.only(start: 6.w),
                  child: InkWell(
                    onTap: _follow,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: dense
                          ? EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 5.h)
                          : EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: ColorManager.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        StringManager.follow.tr(),
                        style: context.bodyMedium.w600
                            .colorExt(Colors.white)
                            .copyWith(
                                fontSize: dense ? 10.5.sp : 12.sp,
                                height: 1.0),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
