part of '../rank_room_page.dart';

class RankContainerWidget extends StatelessWidget {
  final List<UserTopEntity>? usersRank;
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
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: (usersRank??[]).isEmpty || (usersRank??[]).length<=4 ?350.h:null,
          decoration: BoxDecoration(
             /* color: ColorManager.white,
              border: Border.all(color: ColorManager.white),*/
              borderRadius: BorderRadius.only(
                topLeft: 20.radiusCircular,
                topRight: 20.radiusCircular,
              )),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: context.paddingOnly(bottom: 10.h, start: 10, end: 10,top: 0),
            itemBuilder: (context, index) {
              return UserInfoRankWidget(
                index: index + 4,
                userTopEntity: usersRank![index],
                isRoom: isRankRoom,
                isWealth:isWealth ,
                isCharm:isCharm ,
                isSender: isSender,
              );
            },
            itemCount: (usersRank?.length ?? 0),
          ),
        ),
      ],
    );
  }
}
