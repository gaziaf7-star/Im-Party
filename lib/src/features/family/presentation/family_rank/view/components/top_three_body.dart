part of '../family_rank_page.dart';

class TopThreeFamiliesBody extends StatelessWidget {
  final List<FamilyRankEntity> families;

  const TopThreeFamiliesBody({required this.families, super.key});

  @override
  Widget build(BuildContext context) {
    if (families.isEmpty) {
      return const EmptyStateWidget();
    }
    FamilyRankEntity? at(int i) => i < families.length ? families[i] : null;
    return RankPodium(
      frames: (rank) => switch (rank) {
        1 => (AssetsManager.charmRank1Frame, AssetsManager.rankCharmFrame1),
        2 => (AssetsManager.charmRank2Frame, AssetsManager.rankCharmFrame2),
        _ => (AssetsManager.charmRank3Frame, AssetsManager.rankCharmFrame3),
      },
      onTap: (rank) => openFamily(context, at(rank - 1)),
      avatar: (rank, size) {
        final family = at(rank - 1);
        return ClipOval(
          child: family == null
              ? Container(
                  width: size,
                  height: size,
                  color: Colors.white.withValues(alpha: 0.25),
                )
              : UserImage(
                  image: family.img ?? '',
                  displayName: family.name ?? '',
                  imageSize: size,
                  uniquId: '${family.id}',
                  boxFit: BoxFit.cover,
                ),
        );
      },
      info: (rank, compact) {
        final family = at(rank - 1);
        if (family == null) return null;
        return FamilyRankInfo(family: family, centered: true, compact: compact);
      },
    );
  }
}

void openFamily(BuildContext context, FamilyRankEntity? family) {
  if (family != null && family.id != null && family.id != 0) {
    Navigator.pushNamed(context, Routes.familyScreen,
        arguments: family.id.toString());
  }
}

/// Family name (+ flag), ID and score.
class FamilyRankInfo extends StatelessWidget {
  const FamilyRankInfo({
    super.key,
    required this.family,
    this.centered = false,
    this.compact = false,
    this.showValue = true,
  });

  final FamilyRankEntity family;
  final bool centered;
  final bool compact;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final flag = family.countryEntity?.photo ?? '';
    final rowAlign =
        centered ? MainAxisAlignment.center : MainAxisAlignment.start;
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: rowAlign,
          mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Long names scroll, like the other ranking pages.
            Flexible(
              child: SizedBox(
                height: 20.h,
                child: AutoScrollText(
                  text: family.name ?? '',
                  textAlign: centered ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: (compact ? 13 : 14).sp,
                  ),
                ),
              ),
            ),
            if (flag.isNotEmpty) ...[
              4.wBox,
              CountryIcon(country: flag, width: 18.w, height: 13.h),
            ],
          ],
        ),
        3.hBox,
        Text(
          'ID:${family.id ?? ''}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: (compact ? 12 : 13).sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showValue && (family.rank ?? '').isNotEmpty) ...[
          4.hBox,
          Row(
            mainAxisAlignment: rowAlign,
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageWidget(
                  image: AssetsManager.rankWealthIcon,
                  height: 16.h,
                  width: 16.w),
              4.wBox,
              Text(
                family.rank ?? '',
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
