part of '../family_screen.dart';

class _AdminsAndMembersBody extends StatelessWidget {
  const _AdminsAndMembersBody({required this.showFamilyEntity});

  final ShowFamilyEntity? showFamilyEntity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          (showFamilyEntity!.members?.length ?? 0) + 1,
          (index) {
            if (index == 0) {
              return InkWell(
                onTap: () {
                  Methods().userProfileNavigator(
                    context: context,
                    userId: showFamilyEntity!.memberFamilyEntity?.id.toString(),
                  );
                },
                child: CardFamilyMemberWidget(
                  image: showFamilyEntity?.memberFamilyEntity?.image ?? '',
                  frame: showFamilyEntity?.memberFamilyEntity?.frame ?? '',
                  name: showFamilyEntity?.memberFamilyEntity?.name ?? '',
                  type: StringManager.owner.tr(),
                  amIOwner: true,
                  amIAdmin: false,
                ),
              );
            } else {
              return InkWell(
                onTap: () {
                  Methods().userProfileNavigator(
                    context: context,
                    userId: showFamilyEntity!.members![index - 1].id.toString(),
                  );
                },
                child: CardFamilyMemberWidget(
                  image: showFamilyEntity!.members![index - 1].image,
                  name: showFamilyEntity!.members![index - 1].name,
                  frame: showFamilyEntity!.members![index - 1].frame,
                  type: showFamilyEntity!.members![index - 1].isFamilyAdmin
                      ? StringManager.admin.tr()
                      : StringManager.member.tr(),
                  userId: showFamilyEntity!.members![index - 1].id,
                  ownerId: showFamilyEntity!.memberFamilyEntity?.id ?? 0,
                  isShowOptions: MyDataModel.getInstance().familyId ==
                      showFamilyEntity!.id,
                  familyId: showFamilyEntity!.id,
                  familyStatus:
                      showFamilyEntity!.members![index - 1].familyStatus,
                  amIOwner: false,
                  amIAdmin:
                      showFamilyEntity!.members![index - 1].isFamilyAdmin,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
