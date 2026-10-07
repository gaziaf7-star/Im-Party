part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

class UserInfoRow extends StatelessWidget {
  final UserEntity user_;

  const UserInfoRow({required this.user_, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Methods().userProfileNavigator(
        context: context,
        user_: user_,
        userId: user_.id.toString() == MyDataModel.getInstance().id.toString()
            ? null
            : user_.id.toString(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _UserProfileImage(
            key: const ValueKey("profile_image_default_theme"),
            user: user_,
          ),
          10.wBox,
          Expanded(
            child: _UserDetails(
              user: user_,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserProfileImage extends StatelessWidget {
  final UserEntity user;

  const _UserProfileImage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return UserImage(
      imageSize: 75.w,
      borderRadius: 60.radius,
      boxFit: BoxFit.cover,
      displayName: user.name ?? '',
      frame: user.frame ?? '',
      frameType: user.frameType ?? '',
      frameSize: 130.w,
      margin: context.paddingOnly(end: 10),
      image: EndPoints.getImage(user.profile?.image ?? ''),
    );
  }
}

class _UserDetails extends StatelessWidget {
  final UserEntity user;
  const _UserDetails({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        15.hBox,
        _UserNameRow(
            key: const ValueKey("user_name_default_theme"), user: user),
        _UserIDRow(key: const ValueKey("id_default_theme"), user: user),
        _UserBadgesRow(key: const ValueKey("badges_default_theme"), user: user),
        _UserBioRow(user: user),
      ],
    );
  }
}

class _UserNameRow extends StatelessWidget {
  final UserEntity user;
  const _UserNameRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: ConstantsManager.isTheme1 == true
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        (() {
          final isVip = user.vip != null &&
              (user.vip?.colorName ?? '').startsWith('#');
          final vipColor = Methods.safeHexColor(user.vip?.colorName) ??
              ColorManager.momentPostTextColor;

          return FittedBox(
            child: GradientTextVip(
              width: ConstantsManager.isTheme1 == true ? 200.w : 150.w,
              isVip: isVip,
              text: '${user.name}',
              color: vipColor,
              mainAxisAlignment: MainAxisAlignment.start,
              textAlign: TextAlign.center,
              textStyle: context.bodyMedium.w600
                  .size(
                ConstantsManager.isTheme1 == true ? 17.0 : 15.0,
              )
                  .colorExt(vipColor),
            ),
          );
        }()),
        if (ConstantsManager.isTheme1 == false) ...[
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.addMultiPicture,
                arguments: false,
              );
            },
            child: ImageWidget(
              color: ColorManager.headerColor,
              height: 30.h,
              width: 30.w,
              image: AssetsManager.userProfileIcon,
            ),
          ),
        ],
      ],
    );
  }
}

class _UserIDRow extends StatelessWidget {
  final UserEntity user;

  const _UserIDRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String? rawColor = user.imageColorEntity?.color;
    final Color resolvedColor = Methods.safeHexColor(rawColor) ??
        ColorManager.momentPostTextColor.withValues(alpha: 0.6);

    return IdWithCopyIcon(
      userId: user.uuid ?? '',
      isNeedCopyIcon: true,
      isSpecial: (user.specialId != null),
      specialImg: user.idImage ?? '',
      color: rawColor,
      img: user.imageColorEntity?.image,
      mainAxisAlignment: ConstantsManager.isTheme1 == true
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      idColor: ColorManager.momentPostTextColor.withValues(alpha: 0.6),
      idStyle: context.bodyMedium.w500.colorExt(resolvedColor).copyWith(
          height: 0.1,
          fontSize: ConstantsManager.isTheme1 == true ? 14.sp : 11.sp),
    );
  }
}

class _UserBadgesRow extends StatelessWidget {
  final UserEntity user;
  const _UserBadgesRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetUserBadgesBloc, GetUserBadgesState>(
      bloc: di<GetUserBadgesBloc>(),
      buildWhen: (prev, curr) => prev.userBadge?.top != curr.userBadge?.top,
      builder: (context, state) {
        final userBadgesData = state.userBadge?.top ?? [];

        return SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: Wrap(
            spacing: 5.w,
            runSpacing: 3.h,
            alignment: ConstantsManager.isTheme1 == true
                ? WrapAlignment.center
                : WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (user.country?.photo != null && user.isCountryHidden == false)
                ImageViewWidget(
                  url: user.country?.photo ?? "",
                  height: 22.h,
                  width: 20.w,
                ),

              // VIP Container
              if (user.vip != null && user.vip?.level != 0)
                VipContainer(
                  vip: user.vip!.img1 ?? '',
                  width: 35.w,
                  boxFit: BoxFit.contain,
                ),

              if ((user.level?.senderImage ?? '').isNotEmpty)
                LevelContainer(
                  boxFit: BoxFit.contain,
                  level: user.level?.senderLevel ?? 1,
                  image: user.level?.senderImage ?? "",
                ),

              if ((user.level?.receiverImage ?? '').isNotEmpty)
                LevelContainer(
                  boxFit: BoxFit.contain,
                  level: user.level?.reciverLevel ?? 1,
                  image: user.level?.receiverImage ?? "",
                ),

              // User badges from BlocBuilder
              if (userBadgesData.isNotEmpty)
                ...userBadgesData.map(
                      (badgeData) {
                    return badgeData.imageType == "svga"
                        ? CacheSvgaWidget(
                      url: EndPoints.getImage(badgeData.image),
                      boxFit: BoxFit.fill,
                      height: 22.5.h,
                      width: 70.h,
                    )
                        : ImageViewWidget(
                      url: EndPoints.getImage(badgeData.image),
                      height: 22.5.h,
                      width: 70.w,
                      boxFit: BoxFit.fill,
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

class _UserBioRow extends StatelessWidget {
  final UserEntity user;
  const _UserBioRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.edit, size: 10, color: ColorManager.greyColor),
        3.wBox,
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 50.w, maxWidth: 160.w),
          child: TextWidget(
            user.bio?.isEmpty == true
                ? StringManager.bio.tr()
                : (user.bio ?? ""),
            overflow: TextOverflow.ellipsis,
            style: context.bodyMedium
                .size(10)
                .bold
                .colorExt(ColorManager.secondaryText),
          ),
        ),
      ],
    );
  }
}