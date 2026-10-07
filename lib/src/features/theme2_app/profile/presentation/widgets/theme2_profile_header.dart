import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/auth/auth.dart' hide PickImageEvent;
import 'package:general/src/features/profile/presentation/profile/view/page/edit_info_screen/bloc/edit_information/edit_information_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/edit_info_screen/edit_profile_screen.dart';

class Theme2ProfileHeader extends StatelessWidget {
  final MyDataEntity data;

  const Theme2ProfileHeader({super.key, required this.data});

  /// Quick-edit the username: opens the same bottom sheet the full edit screen
  /// uses, bound to the shared EditInformationBloc (saves via EditInformationEvent).
  void _editName(BuildContext context) {
    di<EditInformationBloc>().add(AssignInformationEvent());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder:
          (_) => EditInfoScreen(
            params: EditProfileParameter(
              content: '${data.name}',
              isUsername: true,
            ),
          ),
    );
  }

  /// Quick-edit the status/bio: reuses the same bottom sheet (isUsername: false).
  void _editBio(BuildContext context) {
    di<EditInformationBloc>().add(AssignInformationEvent());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder:
          (_) => EditInfoScreen(
            params: EditProfileParameter(
              content: '${data.bio}',
              isUsername: false,
            ),
          ),
    );
  }

  /// Quick-edit the profile photo: reuses the bloc's pick → crop → save flow.
  void _editPhoto(BuildContext context) {
    di<EditInformationBloc>().add(AssignInformationEvent());
    di<EditInformationBloc>().add(const PickImageEvent(fromCamera: false));
  }

  @override
  Widget build(BuildContext context) {
    final user = MyDataModel.getInstance().convertMyDataEntityToUserEntity(
      data,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        16.hBox,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with a photo quick-edit badge.
              SizedBox(
                height: (user.frame != null && user.frame != '') ? 130.w : 80.w,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    InkWell(
                      onTap:
                          () => Methods().userProfileNavigator(
                            context: context,
                            user_: user,
                            userId:
                                user.id.toString() ==
                                        MyDataModel.getInstance().id.toString()
                                    ? null
                                    : user.id.toString(),
                          ),
                      child: UserImage(
                        image: user.profile?.image ?? '',
                        displayName: user.name,
                        imageSize: 80.w,
                        borderRadius: 40.radius,
                        frame: user.frame ?? '',
                        frameType: user.frameType ?? '',
                        frameSize:
                            (user.frame != null && user.frame != '')
                                ? 130.w
                                : 80.w,
                        boxFit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _QuickEditBadge(onTap: () => _editPhoto(context)),
                    ),
                  ],
                ),
              ),
              8.hBox,
              Column(
                children: [
                  // Name + Level badge + name quick-edit.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: GradientName(child: Text(
                          user.name ?? '',
                          style: TextStyle(
                            color: ColorManager.textPrimary,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                      ),
                      6.wBox,
                      if ((user.level?.senderImage ?? '').isNotEmpty)
                        LevelContainer(
                          boxFit: BoxFit.contain,
                          level: user.level?.senderLevel ?? 1,
                          image: user.level?.senderImage ?? "",
                        ),
                      4.wBox,
                      _QuickEditPencil(onTap: () => _editName(context)),
                    ],
                  ),
                  4.hBox,
                  // VIP + ID row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user.vip != null && user.vip?.level != 0) ...[
                        VipContainer(
                          vip: user.vip!.img1 ?? '',
                          width: 35.w,
                          boxFit: BoxFit.contain,
                        ),
                        6.wBox,
                      ],
                      Text(
                        'ID:${user.uuid ?? user.id ?? ''}',
                        style: TextStyle(
                          color: ColorManager.secondaryText,
                          fontSize: 13.sp,
                        ),
                      ),
                      4.wBox,
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: '${user.uuid ?? user.id ?? ''}',
                            ),
                          );
                          Methods.showToast(
                            context,
                            message: StringManager.theTextHasBeenCopied.tr(),
                          );
                        },
                        child: Icon(
                          Icons.copy,
                          size: 14.sp,
                          color: ColorManager.greyText,
                        ),
                      ),
                    ],
                  ),
                  8.hBox,
                  // Status / bio + bio quick-edit.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          (data.bio ?? '').isNotEmpty
                              ? data.bio!
                              : StringManager.status.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ColorManager.secondaryText,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      4.wBox,
                      _QuickEditPencil(onTap: () => _editBio(context)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small circular pencil used for inline name/bio quick-edit.
class _QuickEditPencil extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickEditPencil({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(2.r),
        child: Icon(Icons.edit, size: 16.sp, color: ColorManager.greyText),
      ),
    );
  }
}

/// Camera badge anchored on the avatar for photo quick-edit.
class _QuickEditBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickEditBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: ColorManager.primary,
          shape: BoxShape.circle,
          border: Border.all(color: ColorManager.white, width: 1.5),
        ),
        child: Icon(
          Icons.photo_camera_outlined,
          size: 14.sp,
          color: ColorManager.white,
        ),
      ),
    );
  }
}

/// Stats row: متابعين | المتابعون | الأصدقاء | مشاهدات
class Theme2StatsRow extends StatelessWidget {
  final MyDataEntity data;

  const Theme2StatsRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final user = MyDataModel.getInstance().convertMyDataEntityToUserEntity(
      data,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        gradient: ColorManager.bodyBackgroundGradient,
        borderRadius: BorderRadius.circular(14.r),
      ),
      // Order (RTL reading): متابعين | المتابعون | الأصدقاء | مشاهدات
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            count: '${user.numberOfFans ?? 0}',
            label: StringManager.followers.tr(),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.friendFollowing,
                arguments: 1,
              );
              di<FetchUserDataBloc>().add(const ReadCounterFollowersEvent());
            },
          ),
          _StatItem(
            count: '${user.numberOfFollowings ?? 0}',
            label: StringManager.following.tr(),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.friendFollowing,
                arguments: 0,
              );
              di<FetchUserDataBloc>().add(const ReadCounterFollowingsEvent());
            },
          ),
          _StatItem(
            count: '${user.numberOfFriends ?? 0}',
            label: StringManager.friends.tr(),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.friendFollowing,
                arguments: 2,
              );
              di<FetchUserDataBloc>().add(const ReadCounterFriendsEvent());
            },
          ),
          // Total views = reels + moments + profile views (backend total_views).
          // Read straight from MyDataEntity; falls back to 0 when absent/null.
          // Display-only: there is no dedicated views screen.
          _StatItem(
            count: '${data.totalViews ?? 0}',
            label: StringManager.views.tr(),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback onTap;

  const _StatItem({
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: ColorManager.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          4.hBox,
          Text(
            label,
            style: TextStyle(color: ColorManager.secondaryText, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
