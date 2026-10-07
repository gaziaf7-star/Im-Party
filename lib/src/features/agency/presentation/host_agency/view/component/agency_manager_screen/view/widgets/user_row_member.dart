part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class UserRowMember extends StatelessWidget {
  const UserRowMember({
    super.key,
    required this.agencyMemberModel,
    this.endIcon,
  });

  final AgencyMemberModel agencyMemberModel;
  final Widget? endIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(10),
      child: InkWell(
        onTap: () {
          Methods().userProfileNavigator(
            context: context,
            userId: agencyMemberModel.id.toString(),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserImage(
              image: agencyMemberModel.profile?.image ?? '',
              displayName: agencyMemberModel.name ?? '',
              imageSize: 40.w,
              // fit: BoxFit.cover,
            ),
            10.wBox,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientTextVip(
                      text: agencyMemberModel.name ?? "",
                      textStyle: context.bodyLarge.w600.size(14),
                      width: 135.w,
                      isVip: false,
                    ),
                    10.wBox,
                    if ((agencyMemberModel.level?.senderImg ?? "") != '')
                      UserLevelContainer(
                        height: 18.h,
                        width: 30.w,
                        image: EndPoints.getImage(
                            agencyMemberModel.level?.senderImg ?? ""),
                      ),
                    if ((agencyMemberModel.level?.receiverImg ?? "") != '')
                      UserLevelContainer(
                        height: 18.h,
                        width: 30.w,
                        image: EndPoints.getImage(
                            agencyMemberModel.level?.receiverImg ?? ""),
                      ),
                  ],
                ),
                TextWidget('ID: ${agencyMemberModel.uuid}'),
              ],
            ),
            const Spacer(),
            endIcon ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
