part of '../family_member_page.dart';

class _FamilyMembersBody extends StatelessWidget {
  const _FamilyMembersBody({
    required this.members,
    required this.admins,
    required this.scrollController,
    required this.data,
    required this.removeUserIndex,
    required this.familyId,
  });

  final List<MemberFamilyEntity> members;
  final List<MemberFamilyEntity> admins;
  final ScrollController scrollController;
  final MemberFamilyEntity? data;
  final ValueChanged<int> removeUserIndex;
  final int familyId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.paddingSymmetric(horizontal: 12),
      controller: scrollController,
      itemCount: admins.length + members.length + 1,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        if (index == 0) {
          if (data == null) {
            return const SizedBox();
          } else {
            return FamilyMember(
              memebr: data!,
              index: index,
            );
          }
        } else if (index <= admins.length) {
          final admin = admins[index - 1];

          return FamilyMember(
            memebr: admin,
            index: index,
          );
        } else {
          final member = members[index - admins.length - 1];
          return FamilyMember(
            memebr: member,
            index: index,
          );
        }
      },
    );
  }
}
