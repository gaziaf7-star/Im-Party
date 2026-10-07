import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/games/domain/entities/online_user_entity.dart';
import 'package:general/src/features/games/presentation/meet/bloc/online_users/online_users_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_state.dart';

class ProfileCardItem extends StatelessWidget {
  const ProfileCardItem({
    super.key,
    required this.data,
    required this.index,
  });

  final UsersOnlineEntity data;
  final int index;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineUsersBloc, OnlineUsersStates>(
      bloc: di<OnlineUsersBloc>(),
      buildWhen: (prev, curr) => prev.users != curr.users,
      builder: (context, state) {
        final isFollowed = state.users[index].isFollow;

        return Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: 20.radius,
            color: ColorManager.white,
          ),
          child: Stack(
            children: [
              ImageViewWidget(
                url: data.image ?? '',
                displayName: data.name ?? '',
                boxFit: BoxFit.fill,
                height: 200.h,
                width: 155.w,
                radius: 20,
              ),
              Positioned(
                bottom: 5,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageViewWidget(
                      url: data.country?.photo ?? '',
                      height: 20.h,
                      width: 25.h,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 110.w,
                        minWidth: 5.w,
                      ),
                      child: TextWidget(
                        data.name ?? '',
                        style:
                            context.bodyLarge.colorExt(ColorManager.textPrimary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (MyDataModel.getInstance().id != data.id)
                BlocBuilder<FollowBloc, FollowState>(
                  bloc: di<FollowBloc>(),
                  buildWhen: (prev, curr) => prev != curr,
                  builder: (_, __) {
                    return Positioned(
                      right: 5,
                      bottom: 5,
                      child: InkWell(
                        onTap: () {
                          if (isFollowed == false) {
                            di<FollowBloc>().add(
                              FollowEvent(
                                relationType: RelationType.following,
                                index: index,
                                userEntity: UserEntity(id: data.id),
                              ),
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              Routes.messages,
                              arguments: MessagesParameter(
                                hasColorName: false,
                                name: data.name ?? "",
                                isNotFriend:
                                    data.isFriend == true ? false : true,
                                image: data.image ?? "",
                                userId: '${data.id ?? 0}',
                                message: StringManager.sayHello.tr(),
                              ),
                            );
                          }
                        },
                        child: ShowSVGA(
                          svgaAssetPath: isFollowed == true
                              ? AssetsManager.onlineHi
                              : AssetsManager.onlineLove,
                          height: 46.h,
                          width: 46.h,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
