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
    final others = usersRank?.otherUsersEntity ?? const [];
    return RankListPanel(
      child: others.isEmpty
          ? const HandlingDataWidget(
              reqState: RequestState.empty,
              title: "NO Data",
              subTitle: "",
              child: SizedBox.shrink())
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: others.length,
              itemBuilder: (context, index) => OldUserInfoRankWidget(
                index: index + 4,
                userTopEntity: others[index],
                isRoom: isRankRoom,
                isWealth: isWealth,
                isCharm: isCharm,
                isSender: isSender,
              ),
            ),
    );
  }
}
