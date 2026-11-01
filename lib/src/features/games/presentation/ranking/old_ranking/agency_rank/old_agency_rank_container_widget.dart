import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_show_agency/show_agency_bloc.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_hosts_agency.dart';
import 'package:general/src/features/games/domain/entities/agency_ranking_entity.dart';
import '../rank_theme.dart';
import 'old_top_three_agency_widget.dart';

class OldAgencyRankContainerWidget extends StatelessWidget {
  final List<AgencyRankingEntity>? agenciesEntity;
  final bool isRankRoom;
  final bool? isCp;
  final bool? isSender;
  final bool? isWealth;
  final Color? bgColor;

  const OldAgencyRankContainerWidget({
    required this.agenciesEntity,
    this.isRankRoom = false,
    super.key,
    this.bgColor,
    this.isSender,
    this.isWealth,
    this.isCp,
  });

  @override
  Widget build(BuildContext context) {
    final agencies = agenciesEntity ?? const <AgencyRankingEntity>[];
    return RankListPanel(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: isRankRoom ? 100.h : 10.h),
        itemCount: agencies.length,
        itemBuilder: (context, index) {
          final agency = agencies[index];
          return RankListCard(
            rank: index + 4,
            onTap: () => openAgency(context, agency),
            avatar: UserImage(
              image: agency.img,
              displayName: agency.name,
              imageSize: 56,
              boxFit: BoxFit.cover,
            ),
            info: AgencyRankInfo(agency: agency, showValue: false),
            valueIcon: AssetsManager.rankWealthIcon,
            value: agency.exp,
          );
        },
      ),
    );
  }
}

class UserInfoRankWidget extends StatelessWidget {
  final AgencyRankingEntity? agencyEntity;
  final void Function()? onTap;
  final int index;
  final bool? isSender;
  final bool? isWealth;
  final bool? isCp;

  const UserInfoRankWidget({
    this.onTap,
    required this.agencyEntity,
    super.key,
    required this.index,
    required this.isWealth,
    required this.isSender,
    required this.isCp,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorManager.transparent,
      shadowColor: ColorManager.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () {
          di<ShowAgencyBloc>().add(ShowAgencyEvent(
              agencyId: agencyEntity?.id ?? 0, isFirstLoading: true));
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const ShowHostsAgency(
                agencyData: null,
                isProfile: true,
                // id: widget.data_?.myAgency?.id,
              );
            },
          ));
        },
        child: Container(
          padding: context.paddingSymmetric(horizontal: 5, vertical: 5),
          margin: context.paddingSymmetric(vertical: 3.0, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                index >= 10 ? '$index' : '0$index',
                style:
                    context.bodyLarge.size(12).w700.colorExt(ColorManager.grey),
              ),
              10.wBox,
              UserImage(
                boxFit: BoxFit.cover,
                image: agencyEntity?.img ?? "",
                displayName: agencyEntity?.name ?? '',
                imageSize: 50,
                borderRadius: 90.radius,
              ),
              15.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 200.w,
                        minWidth: 1.w,
                      ),
                      child: TextWidget(
                        maxLines: 1,
                        agencyEntity?.name ?? "",
                        style: context.bodyMedium.w400
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ),
                    5.hBox,
                    TextWidget(
                      'ID: ${agencyEntity?.id ?? ""}',
                      style: context.bodyMedium
                          .size(12)
                          .colorExt(ColorManager.grey)
                          .w400,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              5.wBox,
              TextWidget(
                formatNumber(agencyEntity?.exp ?? 0),
                style: context.bodyMedium
                    .size(12)
                    .w700
                    .colorExt(ColorManager.gold3),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
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
