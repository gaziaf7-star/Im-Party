import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_state.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/presentation/component/profile/new_profile_body.dart';

class NewFollowButton extends StatefulWidget {
  final UserInRoomModel userData;
  final bool initialIsFollow;
  final FollowBloc followBloc;

  /// Round heart button (filled red when following) instead of the image
  /// tile -- used by the room profile sheet's bottom action row.
  final bool heartStyle;

  const NewFollowButton({
    super.key,
    required this.userData,
    required this.initialIsFollow,
    required this.followBloc,
    this.heartStyle = false,
  });

  @override
  State<NewFollowButton> createState() => _NewFollowButtonState();
}

class _NewFollowButtonState extends State<NewFollowButton> {
  late bool _isFollowing;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollow;
  }

  @override
  void didUpdateWidget(covariant NewFollowButton oldWidget) {
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
      child: widget.heartStyle
          ? GestureDetector(
              onTap: _onFollowTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_isFollowing
                          ? const Color(0xFFFF3B6B)
                          : const Color(0xFF9EA0A8))
                      .withValues(alpha: .12),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: Icon(
                    _isFollowing
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(_isFollowing),
                    color: _isFollowing
                        ? const Color(0xFFFF3B6B)
                        : const Color(0xFF9EA0A8),
                    size: 26.sp,
                  ),
                ),
              ),
            )
          : ProfileButtomWidget(
        context: context,
        title: _isFollowing
            ? StringManager.following.tr()
            : StringManager.follow.tr(),
        onTap: _onFollowTap,
        image: _isFollowing
            ? AssetsManager.roomProfileAddAttention
            : AssetsManager.roomProfileAttentioned,
      ),
    );
  }
}
