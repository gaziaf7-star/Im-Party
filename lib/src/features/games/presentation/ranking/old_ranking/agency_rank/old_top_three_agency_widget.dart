import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_show_agency/show_agency_bloc.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_hosts_agency.dart';
import 'package:general/src/features/games/domain/entities/agency_ranking_entity.dart';

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
    return SizedBox(
      height: 420.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            top: -15.h,
            child: LeaderboardCardWidget(
              agencyEntity: agencyEntity.isNotEmpty ? agencyEntity[0] : null,
              frameImage: AssetsManager.wealthRank1Frame,
              isUpper: true,
              assetImage: AssetsManager.rankWealthFrame1,
              isPhoto: isPhoto,
            ),
          ),
          Positioned(
            bottom: 0.h,
            child: SizedBox(
              width: ScreenUtil().screenWidth,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: LeaderboardCardWidget(
                      agencyEntity:
                          agencyEntity.length > 2 ? agencyEntity[1] : null,
                      frameImage: AssetsManager.wealthRank2Frame,
                      assetImage: AssetsManager.rankWealthFrame2,
                      isPhoto: isPhoto,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: LeaderboardCardWidget(
                      agencyEntity:
                          agencyEntity.length > 2 ? agencyEntity[2] : null,
                      frameImage: AssetsManager.wealthRank3Frame,
                      assetImage: AssetsManager.rankWealthFrame3,
                      isPhoto: isPhoto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
