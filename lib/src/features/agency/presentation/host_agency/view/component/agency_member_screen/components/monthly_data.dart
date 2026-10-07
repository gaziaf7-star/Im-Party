import 'dart:developer';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/agency_host_report/agency_host_report_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/monthly_data_item_widget.dart';

class MonthlyData extends StatelessWidget {
  final AgencyHostReportState state;

  const MonthlyData({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(
        horizontal: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            StringManager.mounthlyData.tr(),
            style: context.bodyMedium.bold,
          ),
          10.hBox,
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MonthlyDataItemWidget(
                    title: StringManager.profits.tr(),
                    subIcon: Padding(
                      padding: context.paddingAll(5.0),
                      child: Image.asset(
                        AssetsManager.warning,
                        height: 20.h,
                        width: 20.h,
                      ),
                    ),
                    onTap: () {
                      _showDialog(context);
                    },
                    value:
                        '${Methods().convertToAbbreviatedString(state.data?.userSalary?.salary ?? '0')}\$',
                    textColor: ColorManager.primary,
                    icon: AssetsManager.moneyBag,
                    scale: 14,
                  ),
                  20.wBox,
                  MonthlyDataItemWidget(
                    title: StringManager.diamond.tr(),
                    value: (state.data?.diamonds ?? '0').toString(),
                    textColor: ColorManager.hanPurple,
                    icon: AssetsManager.agencydiamond,
                  ),
                ],
              ),
              10.hBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MonthlyDataItemWidget(
                    title: StringManager.onMicTime.tr(),
                    value: "${state.data?.liveMinutes ?? 0}",
                    textColor: ColorManager.blue2,
                    icon: AssetsManager.agencyclock,
                  ),
                  20.wBox,
                  MonthlyDataItemWidget(
                    title: StringManager.effectDays.tr(),
                    value: "${state.data?.activeDays ?? 0}",
                    textColor: ColorManager.darkPink,
                    icon: AssetsManager.agencycalendar,
                  ),
                ],
              ),
            ],
          ),
        ],
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
    log('number $number');

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

  Future<dynamic> _showDialog(
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        title: StringManager.profits.tr(),
        description: StringManager.profitsDescription.tr(),
        isHideConfirm: true,
        isUpdateDialog: false,
        showCloseIcon: true,
        // White background + black text (was the panel-driven
        // scaffoldBg/textPrimary/secondaryText), on request.
        dialogBackgroundColor: Colors.white,
        titleColor: ColorManager.black,
        descriptionColor: ColorManager.black,
      ),
    );
  }
}
