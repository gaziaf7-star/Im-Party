part of '../old_rank_screen.dart';

class OldRankContainerWidget extends StatelessWidget {
  final RankingEntity? usersRank;
  final bool isRankRoom;
  final bool? isCp;
  final bool? isSender;
  final bool? isWealth;
  final bool? isCharm;
  final Color? bgColor;

  const OldRankContainerWidget({
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
    return Column(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: (usersRank?.otherUsersEntity ?? []).isEmpty ||
                  (usersRank?.otherUsersEntity ?? []).length <= 3
              ? 280.h
              : null,
          decoration: BoxDecoration(
            color: ColorManager.white,
            border: Border.all(color: ColorManager.white),
            borderRadius: BorderRadius.only(
              topLeft: 20.radiusCircular,
              topRight: 20.radiusCircular,
            ),
          ),
          child: usersRank?.otherUsersEntity.isEmpty ?? false
              ?  const HandlingDataWidget(
                  reqState: RequestState.empty,
                  title: "NO Data",
                  subTitle: "",
                  child: SizedBox.shrink())
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: context.paddingOnly(
                    bottom: 10.h,
                    top: isRankRoom ? 20 : 0,
                    start: 10,
                    end: 10,
                  ),
                  itemBuilder: (context, index) {
                    return OldUserInfoRankWidget(
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
        ),
      ],
    );
  }
}
