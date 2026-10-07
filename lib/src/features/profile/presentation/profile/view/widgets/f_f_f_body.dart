import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/components/fff_info_body.dart';

class FFLFBody extends StatelessWidget {
  const FFLFBody({
    super.key,
    required this.data,
    this.horizontalP,
    this.verticalP,
    this.isMyProfile,
    this.textColor,
    this.dividerColor,
    this.countFontSize,
    this.labelFontSize,
  });

  final UserEntity? data;
  final double? horizontalP;
  final double? verticalP;
  final bool? isMyProfile;
  final Color? textColor;
  final Color? dividerColor;

  /// Optional overrides passed straight through to each [FFLFInfoBody].
  /// Null (every existing caller) keeps the current defaults.
  final double? countFontSize;
  final double? labelFontSize;

  @override
  Widget build(BuildContext context) {
    final bool myProfile = isMyProfile ?? false;

    // Visitor profile (viewing another user, or how this user appears to
    // others): show ONLY total views + followers. Friends and the list of
    // people this user follows are private and intentionally hidden.
    if (!myProfile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FFLFInfoBody(
            textColor: textColor,
            countFontSize: countFontSize,
            labelFontSize: labelFontSize,
            isMyProfile: false,
            count: '${data?.totalViews ?? "0"}',
            title: StringManager.views.tr(),
            onTap: () {},
          ),
          FFLFInfoBody(
            textColor: textColor,
            countFontSize: countFontSize,
            labelFontSize: labelFontSize,
            isMyProfile: false,
            count: '${data?.numberOfFans ?? "0"}',
            title: StringManager.followers.tr(),
            onTap: () {},
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FFLFInfoBody(
          textColor: textColor,
          isMyProfile: myProfile,
          count: '${data?.numberOfFollowings ?? "0"}',
          title: StringManager.following.tr(),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.friendFollowing,
              arguments: 0,
            );
            di<FetchUserDataBloc>().add(const ReadCounterFollowingsEvent());
          },
        ),
        FFLFInfoBody(
          textColor: textColor,
          isMyProfile: myProfile,
          count: '${data?.numberOfFans ?? "0"}',
          title: StringManager.followers.tr(),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.friendFollowing,
              arguments: 1,
            );
            di<FetchUserDataBloc>().add(const ReadCounterFollowersEvent());
          },
        ),
        FFLFInfoBody(
          textColor: textColor,
          isMyProfile: myProfile,
          count: '${data?.numberOfFriends ?? "0"}',
          title: StringManager.friends.tr(),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.friendFollowing,
              arguments: 2,
            );
            di<FetchUserDataBloc>().add(const ReadCounterFriendsEvent());
          },
        ),
        if (myProfile)
          FFLFInfoBody(
            textColor: textColor,
            countFontSize: countFontSize,
            labelFontSize: labelFontSize,
            isMyProfile: myProfile,
            count: '${data?.profileVisitors ?? "0"}',
            title: StringManager.visitors.tr(),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.friendFollowing,
                arguments: 3,
              );
              di<FetchUserDataBloc>().add(const ReadCounterVistorsEvent());
              if (myProfile &&
                  di<FetchUserDataBloc>()
                      .state
                      .userEntity
                      ?.unreadCounterEntity
                      ?.visitor !=
                      0) {
                di<GetFollowerOrFollowingBloc>()
                    .add(const GetVisitorsEvent(loading: true));
              }
            },
          ),
      ],
    );
  }
}