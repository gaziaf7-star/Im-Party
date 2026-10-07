import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_state.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';

class FollowButton extends StatefulWidget {
  final UserInRoomModel userData;
  final bool initialIsFollow;
  final FollowBloc followBloc;

  const FollowButton({
    super.key,
    required this.userData,
    required this.initialIsFollow,
    required this.followBloc,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollow;
  }

  @override
  void didUpdateWidget(covariant FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userData.id != widget.userData.id) {
      _isFollowing = widget.initialIsFollow;
      _isProcessing = false;
    }
  }

  void _onFollowTap() {
    final userId = widget.userData.id;
    if (userId == null) return;

    if (!HomePage.isConnectToInternet) {
      Methods.showToast(
        context,
        isError: true,
        message: StringManager.unableToConnect.tr(),
      );
      return;
    }

    if (_isProcessing) return;

    _isProcessing = true;

    setState(() {
      _isFollowing = !_isFollowing;
    });

    if (!_isFollowing) {
      widget.followBloc.add(
        UnFollowEvent(
          userId: '$userId',
          relationType: RelationType.profile,
        ),
      );
    } else {
      widget.followBloc.add(
        FollowEvent(
          userEntity: UserEntity(
            id: userId,
          ),
          relationType: RelationType.profile,
        ),
      );
      // If this profile is the LIVE host, hide the broadcast-card pill and
      // post the one-per-session "followedLive" chat line (no-op otherwise).
      LiveRoomData.instance.noteHostFollowed(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FollowBloc, FollowState>(
      bloc: widget.followBloc,
      listener: (context, state) {
        if (state is FollowSuccessState) {
          if (mounted) {
            setState(() {
              _isFollowing = true;
              _isProcessing = false;
            });
          }
        } else if (state is UnFollowSuccessState) {
          if (mounted) {
            setState(() {
              _isFollowing = false;
              _isProcessing = false;
            });
          }
        } else if (state is FollowErrorState) {
          if (mounted) {
            setState(() {
              _isFollowing = !_isFollowing;
              _isProcessing = false;
            });
            Methods.showToast(
              context,
              isError: true,
              message: state.error,
            );
          }
        } else if (state is UnFollowErrorState) {
          if (mounted) {
            setState(() {
              _isFollowing = !_isFollowing;
              _isProcessing = false;
            });
            Methods.showToast(
              context,
              isError: true,
              message: state.error,
            );
          }
        }
      },
      child: InkWell(
        onTap: _onFollowTap,
        child: Container(
          constraints: BoxConstraints(minWidth: 92.w),
          padding: context.paddingSymmetric(
            horizontal: 16.w,
            vertical: 9.h,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF7B2FF7),
                Color(0xFF3A7BFF),
              ],
            ),
            borderRadius: 30.radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isFollowing
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: Colors.white,
                size: 15.h,
              ),
              6.wBox,
              TextWidget(
                _isFollowing
                    ? StringManager.following.tr()
                    : StringManager.follow.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorManager.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
