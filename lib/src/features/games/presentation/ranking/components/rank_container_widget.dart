part of '../rank_screen.dart';

class RankContainerWidget extends StatelessWidget {
  final RankingEntity? usersRank;
  final bool isRankRoom;
  final bool? isCp;
  final bool? isSender;
  final bool? isWealth;
  final bool? isCharm;
  final Color? bgColor;

  const RankContainerWidget({
    required this.usersRank,
    this.isRankRoom = false,
    super.key,
    this.bgColor,
    this.isSender,
    this.isWealth,
    this.isCharm,
    this.isCp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (usersRank?.otherUsersEntity ?? []).isEmpty ||
              (usersRank?.otherUsersEntity ?? []).length <= 3
          ? 350.h
          : null,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: ColorManager.white),
        borderRadius: BorderRadius.only(
          topLeft: 20.radiusCircular,
          topRight: 20.radiusCircular,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: context.paddingOnly(
          bottom: 10.h,
          top: isRankRoom ? 20 : 0,
          start: 0,
          end: 0,
        ),
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Divider(color: Colors.white.withValues(alpha: .5),),
        ),
        itemBuilder: (context, index) {
          return UserInfoRankWidget(
            index: index + 4,
            userTopEntity: usersRank?.otherUsersEntity[index],
            isRoom: isRankRoom,
            isWealth: isWealth,
            isCharm: isCharm,
            isSender: isSender,
          );
        },
        itemCount: usersRank?.otherUsersEntity.length ?? 0,
      ),
    );
  }
}
