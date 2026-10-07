import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_state.dart';

/// Bottom bar with Chat + Follow buttons - Theme2 style
class Theme2VisitorActionBar extends StatefulWidget {
  final UserEntity? user;

  const Theme2VisitorActionBar({super.key, required this.user});

  @override
  State<Theme2VisitorActionBar> createState() => _Theme2VisitorActionBarState();
}

class _Theme2VisitorActionBarState extends State<Theme2VisitorActionBar> {
  bool isFollow = false;

  @override
  void initState() {
    super.initState();
    isFollow = widget.user?.isFollow ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      // Fixed white (was the panel-driven cardDecoration, which could
      // render any admin-picked color/gradient) -- guaranteed white on
      // request, matching the rest of this "white design" pass.
      decoration: BoxDecoration(
        color: ColorManager.white,
        border: Border(
          top: BorderSide(
            color: ColorManager.grey.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Chat button - purple solid
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final user = widget.user;
                  di<FetchUsersChatBloc>().add(UpdateTotalMessages(
                      userId: user?.id.toString(), isIncreased: false));
                  Navigator.pushNamed(
                    context,
                    Routes.messages,
                    arguments: MessagesParameter(
                      hasColorName: false,
                      name: user?.name ?? '',
                      image: user?.profile?.image ?? '',
                      userId: '${user?.id ?? 0}',
                    ),
                  );
                },
                child: Container(
                  height: 48.h,
                  // White with a primary-color border/icon/text (was a
                  // solid primary-color fill) -- matches the Follow
                  // button's own white-based look, on request.
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: ColorManager.primary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_rounded,
                          color: ColorManager.primary, size: 18.sp),
                      6.wBox,
                      Text(
                        StringManager.chat.tr(),
                        style: TextStyle(
                          color: ColorManager.primary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            12.wBox,
            // Follow button - white with purple border
            Expanded(
              child: BlocListener<FollowBloc, FollowState>(
                bloc: di<FollowBloc>(),
                listener: (context, state) {
                  if (state is FollowSuccessState) {
                    setState(() => isFollow = !isFollow);
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    if (isFollow) {
                      di<FollowBloc>().add(
                        UnFollowEvent(userId: '${widget.user?.id ?? 0}'),
                      );
                    } else {
                      di<FollowBloc>().add(
                        FollowEvent(
                            userEntity: widget.user ?? const UserEntity()),
                      );
                    }
                  },
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      // Fixed white for the unfollowed state (was
                      // surfaceCardColor, panel-driven and not guaranteed
                      // white).
                      color: isFollow
                          ? ColorManager.primary.withValues(alpha: 0.1)
                          : ColorManager.white,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: isFollow
                            ? ColorManager.primary
                            : ColorManager.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFollow ? Icons.check : Icons.add,
                          color: ColorManager.primary,
                          size: 18.sp,
                        ),
                        6.wBox,
                        Text(
                          isFollow
                              ? StringManager.followed.tr()
                              : StringManager.follow.tr(),
                          style: TextStyle(
                            color: ColorManager.primary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}