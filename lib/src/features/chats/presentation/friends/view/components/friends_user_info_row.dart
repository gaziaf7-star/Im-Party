part of '../friends_page.dart';

class FFFVUserInfoRow extends StatelessWidget {
  final UserEntity user;
  final Widget? endIcon;
  final bool? isUserVip;
  final VoidCallback? select;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const FFFVUserInfoRow({
    required this.user,
    this.endIcon,
    super.key,
    this.isUserVip,
    this.margin,
    this.padding,
    this.select,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? context.paddingSymmetric(horizontal: 20),
      padding: padding ?? context.paddingAll(20),
      decoration: const BoxDecoration(
        color: ColorManager.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: InkWell(
          onTap: select ??
              () {
                di<FetchUsersChatBloc>().add(
                  UpdateTotalMessages(
                    userId: user.uuid.toString(),
                    isIncreased: false,
                  ),
                );
                Navigator.pushNamed(
                  context,
                  Routes.messages,
                  arguments: MessagesParameter(
                    hasColorName: user.hasColorName ?? false,
                    name: user.name ?? '',
                    image: user.profile?.image ?? '',
                    userId: '${user.id}',
                  ),
                );
              },
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  UserImage(
                    borderRadius: 50.radius,
                    imageSize: 55.h,
                    image: EndPoints.getImage(
                      user.profile?.image ?? '',
                    ),
                    displayName: user.name,
                  ),
                  10.wBox,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientTextVip(
                        isVip: user.colorName != "",
                        width: 170.w,
                        text: user.name ?? "",
                        color: Methods.safeHexColor(user.colorName) ??
                            ColorManager.textPrimary,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.bodyMedium.size(14).w600.colorExt(
                              Methods.safeHexColor(user.colorName) ??
                                  ColorManager.textPrimary,
                            ),
                      ),
                      5.hBox,
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 215.w,
                          minWidth: 1.w,
                        ),
                        child: TextWidget(
                          '${(user.statistic?.bio ?? '').isEmpty ? StringManager.bio.tr() : user.statistic?.bio}',
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMedium.w500
                              .size(14)
                              .colorExt(ColorManager.secondaryText),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  endIcon ?? const SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
