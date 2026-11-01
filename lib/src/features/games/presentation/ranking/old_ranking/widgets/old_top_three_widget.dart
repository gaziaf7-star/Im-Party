part of '../old_rank_screen.dart';

/// Opens what a ranking entry points to: the room for the room ranking,
/// otherwise the user's profile.
void openRankEntry(
    BuildContext context, UserTopEntity? entity, bool isRoomRank) {
  if (entity == null || entity.userId == 0) return;
  if (isRoomRank) {
    final room = entity.roomEntity;
    if (room == null) return;
    di<RoomStateManager>().navigateToRoom(
      RoomEntryRequest(
        context: context,
        roomData: RoomEntity(
          passwordStatus: room.passwordStatus,
          ownerId: entity.userId,
          id: room.id,
          name: room.name,
          cover: room.cover,
          roomBackground: room.background,
          mode: room.mode.toString(),
          uuidOwnerRoom: room.ownerUuid,
          giftPrice: room.giftPrice,
        ),
        isLive: false,
      ),
    );
  } else {
    Methods().userProfileNavigator(
      context: context,
      userId: '${entity.userId}',
    );
  }
}

/// Top three on purple podiums (centre #1 tallest, #2 left, #3 right). The
/// app's own rank frames are kept; name, gender, flag, levels, ID and score
/// sit on each podium's front.
class OldTopThreeWidget extends StatelessWidget {
  final List<UserTopEntity> usersEntity;
  final String imageRank;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isRoomRank;
  final bool? isCp;
  final bool? isNeedSmallIcon;
  final void Function()? onTapImage;
  final Color? nameColor;
  final bool isPhoto;

  const OldTopThreeWidget({
    super.key,
    this.usersEntity = const [],
    required this.imageRank,
    required this.isPhoto,
    this.isRoom,
    this.nameColor,
    this.isNeedSmallIcon,
    this.isCharm,
    this.isWealth,
    this.isRoomRank,
    this.isCp,
    this.onTapImage,
  });

  UserTopEntity? _at(int i) => i < usersEntity.length ? usersEntity[i] : null;

  (String, String) _frame(int rank) {
    if (isCharm == true) {
      return switch (rank) {
        1 => (AssetsManager.charmRank1Frame, AssetsManager.rankCharmFrame1),
        2 => (AssetsManager.charmRank2Frame, AssetsManager.rankCharmFrame2),
        _ => (AssetsManager.charmRank3Frame, AssetsManager.rankCharmFrame3),
      };
    }
    if (isWealth == true) {
      return switch (rank) {
        1 => (AssetsManager.wealthRank1Frame, AssetsManager.rankWealthFrame1),
        2 => (AssetsManager.wealthRank2Frame, AssetsManager.rankWealthFrame2),
        _ => (AssetsManager.wealthRank3Frame, AssetsManager.rankWealthFrame3),
      };
    }
    if (isRoomRank == true) {
      return switch (rank) {
        1 => (AssetsManager.roomRank1Frame, AssetsManager.rankRoomFrame1),
        2 => (AssetsManager.roomRank2Frame, AssetsManager.rankRoomFrame2),
        _ => (AssetsManager.roomRank3Frame, AssetsManager.rankRoomFrame3),
      };
    }
    return switch (rank) {
      1 => (AssetsManager.gameRank1Frame, AssetsManager.rankGamesFrame1),
      2 => (AssetsManager.gameRank2Frame, AssetsManager.rankGamesFrame2),
      _ => (AssetsManager.gameRank3Frame, AssetsManager.rankGamesFrame3),
    };
  }

  @override
  Widget build(BuildContext context) {
    return RankPodium(
      isPhoto: isPhoto,
      frames: _frame,
      onTap: (rank) => onTapImage != null
          ? onTapImage!()
          : openRankEntry(context, _at(rank - 1), isRoomRank == true),
      avatar: (rank, size) {
        final entity = _at(rank - 1);
        return ClipRRect(
          borderRadius: isRoomRank == true
              ? BorderRadius.circular(6)
              : BorderRadius.circular(size),
          child: entity == null
              ? Container(
                  width: size,
                  height: size,
                  color: Colors.white.withValues(alpha: 0.25),
                )
              : UserImage(
                  image: entity.avatar ?? '',
                  displayName: entity.name ?? '',
                  imageSize: size,
                  uniquId: '${entity.userId}',
                  boxFit: BoxFit.cover,
                ),
        );
      },
      info: (rank, compact) {
        final entity = _at(rank - 1);
        if (entity == null) return null;
        return RankUserInfo(
          entity: entity,
          isRoomRank: isRoomRank == true,
          valueIcon: rankValueIcon(
            isWealth: isWealth,
            isCharm: isCharm,
            isRoom: isRoomRank,
          ),
          centered: true,
          compact: compact,
        );
      },
    );
  }
}

/// Small icon shown next to a ranking score, per ranking type.
String rankValueIcon({bool? isWealth, bool? isCharm, bool? isRoom}) {
  if (isWealth == true) return AssetsManager.rankWealthIcon;
  if (isCharm == true) return AssetsManager.rankHeartIcon;
  if (isRoom == true) return AssetsManager.roomRankCoin;
  return AssetsManager.gameIconRank;
}

/// Name (+ gender + flag), level badges, ID and score: the text block used
/// on the podiums and in every list card.
class RankUserInfo extends StatelessWidget {
  const RankUserInfo({
    super.key,
    required this.entity,
    required this.isRoomRank,
    required this.valueIcon,
    this.centered = false,
    this.compact = false,
    this.showValue = true,
  });

  final UserTopEntity entity;
  final bool isRoomRank;
  final String valueIcon;
  final bool centered;
  final bool compact;
  final bool showValue;

  bool get _female {
    final g = (entity.gender ?? '').toLowerCase();
    return g.contains('female') || g == '2' || g == '0';
  }

  @override
  Widget build(BuildContext context) {
    final align =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final rowAlign =
        centered ? MainAxisAlignment.center : MainAxisAlignment.start;
    final nameColor = Methods.safeHexColor(entity.colorName) ?? Colors.white;
    final flag = entity.flag ?? '';
    final id = isRoomRank
        ? (entity.roomEntity?.id ?? entity.userId ?? '')
        : (entity.userId ?? '');
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: rowAlign,
          mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Flexible(
              child: GradientTextVip(
                isVip: (entity.colorName ?? '').isNotEmpty,
                width: compact ? 70.w : 110.w,
                text: entity.name ?? '',
                color: nameColor,
                mainAxisAlignment: rowAlign,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                textStyle: context.bodyMedium
                    .size(compact ? 13 : 14)
                    .w700
                    .colorExt(nameColor)
                    .copyWith(overflow: TextOverflow.ellipsis),
              ),
            ),
            if (!isRoomRank) ...[
              4.wBox,
              Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: _female
                      ? const Color(0xFFE858C9)
                      : const Color(0xFF4EA2FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _female ? Icons.female_rounded : Icons.male_rounded,
                  size: 11.sp,
                  color: Colors.white,
                ),
              ),
            ],
            if (flag.isNotEmpty) ...[
              4.wBox,
              CountryIcon(country: flag, width: 18.w, height: 13.h),
            ],
          ],
        ),
        3.hBox,
        if (!isRoomRank)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LevelContainer(image: entity.receiverImage, isComment: true),
                4.wBox,
                LevelContainer(image: entity.senderImage, isComment: true),
                if ((entity.vipLevelImage ?? '').isNotEmpty) ...[
                  4.wBox,
                  VipContainer(
                    vip: entity.vipLevelImage,
                    isComment: true,
                    boxFit: BoxFit.fill,
                    height: 20.h,
                    width: 20.w,
                  ),
                ],
              ],
            ),
          ),
        if (!isRoomRank) 2.hBox,
        Text(
          'ID:$id',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: (compact ? 12 : 13).sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showValue) ...[
          4.hBox,
          Row(
            mainAxisAlignment: rowAlign,
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageWidget(image: valueIcon, height: 16.h, width: 16.w),
              4.wBox,
              Text(
                '${entity.exp ?? 0}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (compact ? 13 : 14).sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
