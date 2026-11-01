import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_show_agency/show_agency_bloc.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_hosts_agency.dart';
import 'package:general/src/features/games/domain/entities/agency_ranking_entity.dart';
import '../rank_theme.dart';

class OldTopThreeAgencyWidget extends StatelessWidget {
  final List<AgencyRankingEntity> agencyEntity;
  final String imageRank;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isCp;
  final bool isPhoto;

  const OldTopThreeAgencyWidget({
    super.key,
    this.agencyEntity = const [],
    required this.imageRank,
    this.isRoom,
    this.isCharm,
    this.isWealth,
    this.isCp,
    this.isPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    AgencyRankingEntity? at(int i) =>
        i < agencyEntity.length ? agencyEntity[i] : null;
    return RankPodium(
      isPhoto: isPhoto,
      frames: (rank) => switch (rank) {
        1 => (AssetsManager.wealthRank1Frame, AssetsManager.rankWealthFrame1),
        2 => (AssetsManager.wealthRank2Frame, AssetsManager.rankWealthFrame2),
        _ => (AssetsManager.wealthRank3Frame, AssetsManager.rankWealthFrame3),
      },
      onTap: (rank) => openAgency(context, at(rank - 1)),
      avatar: (rank, size) {
        final agency = at(rank - 1);
        return ClipOval(
          child: agency == null
              ? Container(
                  width: size,
                  height: size,
                  color: Colors.white.withValues(alpha: 0.25),
                )
              : UserImage(
                  image: agency.img,
                  displayName: agency.name,
                  imageSize: size,
                  uniquId: '${agency.id}',
                  boxFit: BoxFit.cover,
                ),
        );
      },
      info: (rank, compact) {
        final agency = at(rank - 1);
        if (agency == null) return null;
        return AgencyRankInfo(agency: agency, centered: true, compact: compact);
      },
    );
  }
}

/// Opens the agency's hosts page.
void openAgency(BuildContext context, AgencyRankingEntity? agency) {
  if (agency == null) return;
  di<ShowAgencyBloc>()
      .add(ShowAgencyEvent(agencyId: agency.id, isFirstLoading: true));
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const ShowHostsAgency(agencyData: null, isProfile: true),
    ),
  );
}

/// Agency name (scrolls when long), ID and score.
class AgencyRankInfo extends StatelessWidget {
  const AgencyRankInfo({
    super.key,
    required this.agency,
    this.centered = false,
    this.compact = false,
    this.showValue = true,
  });

  final AgencyRankingEntity agency;
  final bool centered;
  final bool compact;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final rowAlign =
        centered ? MainAxisAlignment.center : MainAxisAlignment.start;
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20.h,
          child: AutoScrollText(
            text: agency.name,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: (compact ? 13 : 14).sp,
            ),
          ),
        ),
        3.hBox,
        Text(
          'ID:${agency.id}',
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
              ImageWidget(
                  image: AssetsManager.rankWealthIcon,
                  height: 16.h,
                  width: 16.w),
              4.wBox,
              Text(
                agency.exp,
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

class LeaderboardCardWidget extends StatelessWidget {
  final AgencyRankingEntity? agencyEntity;
  final String frameImage;
  final String assetImage;
  final bool isUpper;
  final bool isPhoto;

  const LeaderboardCardWidget({
    this.agencyEntity,
    required this.frameImage,
    required this.assetImage,
    this.isUpper = false,
    required this.isPhoto,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        GestureDetector(
          onTap: () {
            di<ShowAgencyBloc>().add(
              ShowAgencyEvent(
                agencyId: agencyEntity?.id ?? 0,
                isFirstLoading: true,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const ShowHostsAgency(
                    agencyData: null,
                    isProfile: true,
                  );
                },
              ),
            );
          },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              UserImage(
                image: '${agencyEntity?.img}',
                displayName: agencyEntity?.name ?? '',
                imageSize: isUpper ? 75.h : 65.h,
                uniquId: '${agencyEntity?.id}',
                borderRadius: BorderRadius.circular(2),
                frameSize: 110.w,
                isAsset: true,
                boxFit: BoxFit.cover,
              ),
              ShowSVGA(
                svgaAssetPath: frameImage,
                height: isUpper ? 220.h : 180,
                width: isUpper ? 380.w : 200.w,
                fit: BoxFit.fill,
                isPhoto: isPhoto,
                pngImg: assetImage,
              ),
            ],
          ),
        ),
        if (agencyEntity?.name != null || agencyEntity?.exp != null)
          Container(
            width: 150.w,
            margin: context.paddingSymmetric(horizontal: 3),
            clipBehavior: Clip.none,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isUpper ? 185.hBox : 180.hBox,
                SizedBox(
                  width: 270.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextWidget(
                        agencyEntity?.name ?? '',
                        style: context.bodyMedium.size(15).w500.colorExt(
                              ColorManager.white,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      5.hBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: TextWidget(
                              formatNumber(agencyEntity?.exp.toString() ?? ''),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: context.bodyMedium.w500
                                  .colorExt(ColorManager.textPrimary),
                            ),
                          ),
                          3.0.wBox,
                          ImageWidget(
                            height: 20.h,
                            width: 20.w,
                            image: AssetsManager.rankWealthIcon,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String formatNumber(dynamic value) {
    double? number;

    if (value is int || value is double) {
      number = value.toDouble();
    } else if (value is String) {
      number = double.tryParse(value);
    }

    if (number == null) return '0';
    // List of abbreviations
    const List<Map<String, dynamic>> abbreviations = [
      {'suffix': 'Q', 'value': 1e15},
      {'suffix': 'T', 'value': 1e12},
      {'suffix': 'B', 'value': 1e9},
      {'suffix': 'M', 'value': 1e6},
      {'suffix': 'K', 'value': 1e3},
    ];

    for (final abbr in abbreviations) {
      if (number >= abbr['value']) {
        double shortened =
            (number / abbr['value']).truncateToDouble() * 100 / 100;
        return _stripTrailingZeros(shortened) + abbr['suffix'];
      }
    }

    double truncated = (number * 100).truncateToDouble() / 100;
    return '${_stripTrailingZeros(truncated)}\$';
  }

  static final RegExp _trailingZerosRegex = RegExp(r'\.0+$');
  static final RegExp _trailingDecimalZerosRegex = RegExp(r'(\.\d*?)0+$');

  String _stripTrailingZeros(double number) {
    return number
        .toString()
        .replaceAll(_trailingZerosRegex, '')
        .replaceAll(_trailingDecimalZerosRegex, r'\1');
  }
}
