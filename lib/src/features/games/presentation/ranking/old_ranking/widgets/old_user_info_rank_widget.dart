part of '../old_rank_screen.dart';

class OldUserInfoRankWidget extends StatelessWidget {
  final UserTopEntity? userTopEntity;
  final void Function()? onTap;
  final int index;
  final bool? isSender;
  final bool? isWealth;
  final bool? isCharm;
  final bool? isRoom;

  const OldUserInfoRankWidget({
    this.onTap,
    required this.userTopEntity,
    super.key,
    required this.index,
    required this.isSender,
    required this.isRoom,
    this.isWealth,
    this.isCharm,
  });

  @override
  Widget build(BuildContext context) {
    final entity = userTopEntity;
    final isRoomRank = isRoom == true;
    return RankListCard(
      rank: index,
      onTap: onTap ?? () => openRankEntry(context, entity, isRoomRank),
      avatar: UserImage(
        boxFit: BoxFit.cover,
        image: entity?.avatar ?? "",
        displayName: entity?.name ?? '',
        imageSize: 56,
        borderRadius: isRoomRank ? 10.radius : null,
      ),
      info: entity == null
          ? const SizedBox.shrink()
          : RankUserInfo(
              entity: entity,
              isRoomRank: isRoomRank,
              valueIcon: '',
              showValue: false,
            ),
      valueIcon:
          rankValueIcon(isWealth: isWealth, isCharm: isCharm, isRoom: isRoom),
      value: '${entity?.exp ?? 0}',
    );
  }
}
