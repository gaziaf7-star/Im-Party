import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import '../../../../domain/entities/family_member_entity.dart';

class FamilyMember extends StatelessWidget {
  final MemberFamilyEntity memebr;
  final int index;

  const FamilyMember({
    super.key,
    required this.memebr,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final String type = index == 0
        ? StringManager.owner.tr()
        : memebr.isFamilyAdmin
            ? StringManager.admin.tr()
            : StringManager.member.tr();
    final bool isMyFamily =
        MyDataModel.getInstance().familyId.toString() == memebr.familyId;
    return InkWell(
      highlightColor: ColorManager.transparent,
      overlayColor: WidgetStateColor.transparent,
      onLongPress: () {
        if (isMyFamily && !(index == 0)) {
          Methods.showCupertinoActionPicker(
              familyId: (memebr.familyId).toString(),
              userId: (memebr.id).toString(),
              context: context,
              familyStatus: memebr.familyStatus,
              amIAnAdmin: memebr.isFamilyAdmin,
              amITheOwner: index == 0);
        }
      },
      child: Container(
        padding: context.paddingOnly(start: 8, end: 8, top: 5, bottom: 15),
        margin: context.paddingOnly(bottom: 15),
        decoration: BoxDecoration(
          color: ColorManager.transparent,
          borderRadius: 5.radius,
          border: Border.all(width: 1, color: ColorManager.whiteGrey5),
        ),
        child: Row(
          children: [
            (index == 0)
                ? Image.asset(
                    AssetsManager.familyRank1,
                    scale: 10,
                  )
                : (index == 1)
                    ? Image.asset(
                        AssetsManager.familyRank2,
                        scale: 10,
                      )
                    : (index == 1)
                        ? Image.asset(
                            AssetsManager.familyRank3,
                            scale: 10,
                          )
                        : TextWidget('$index'),
            5.wBox,
            SizedBox(
              child: InkWell(
                onTap: () {
                  Methods().userProfileNavigator(
                    context: context,
                    userId: '${memebr.id}',
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      child: UserImage(
                        image: memebr.image,
                        displayName: memebr.name,
                        imageSize: 50.w,
                        frameSize: 55.w,
                        border: Border.all(
                          color: ColorManager.primary,
                          width: 2,
                        ),
                        isAsset: true,
                        borderRadius: 50.radius,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      child: Container(
                        padding: context.paddingAll(2),
                        decoration: BoxDecoration(
                          color: ColorManager.primary,
                          borderRadius: 4.radius,
                        ),
                        child: Center(
                          child: TextWidget(
                            type,
                            style: context.bodySmall.copyWith(
                              color: ColorManager.textPrimary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            10.wBox,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientName(child: Text(
                  memebr.name,
                  style: context.bodyLarge.w500,
                )),
                8.hBox,
                Row(
                  children: [
                    if (memebr.vipLevel != 0)
                      VipContainer(
                        vip: memebr.vipLevel.toString(),
                        height: 15,
                        width: 30,
                      ),
                  ],
                )
              ],
            ),
            const Spacer(),
            TextWidget(
              memebr.monthlyDiamond.toString(),
              style: context.bodyMedium.w500.size(15),
            )
          ],
        ),
      ),
    );
  }
}
