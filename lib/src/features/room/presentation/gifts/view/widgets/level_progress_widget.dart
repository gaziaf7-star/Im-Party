import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_state.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../../../../reels_viewer/reels_viewer.dart';

class LevelProgressSection extends StatefulWidget {
  final Color levelTextColor;
  final Color progressBarColor;
  final Color progressBackgroundColor;
  final Color descriptionTextColor;
  final double progressBarHeight;
  final bool showDivider;
  final Color dividerColor;

  const LevelProgressSection({
    super.key,
    required this.levelTextColor,
    required this.progressBarColor,
    required this.progressBackgroundColor,
    required this.descriptionTextColor,
    required this.progressBarHeight,
    required this.showDivider,
    required this.dividerColor,
  });

  @override
  State<LevelProgressSection> createState() => _LevelProgressSectionState();
}

class _LevelProgressSectionState extends State<LevelProgressSection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMyLevelBloc, GetMyLevelState>(
      bloc: di<GetMyLevelBloc>(),
      buildWhen: (prev, curr) => prev.myLevel != curr.myLevel,
      builder: (context, state) {
        final level = state.myLevel;
        double precentage = level?.senderPer ?? 0;
        num senderRemining = level?.senderRemining ?? 0;
        int nextSenderLevel = level?.nextSenderLevel ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    "LV.${level?.senderLevel ?? 0}",
                    style: context.bodyMedium.copyWith(
                      color: widget.levelTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  8.wBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          barRadius: Radius.circular(5.r),
                          lineHeight: widget.progressBarHeight,
                          percent: precentage,
                          backgroundColor: widget.progressBackgroundColor,
                          progressColor: widget.progressBarColor,
                          animation: true,
                          animationDuration: 800,
                        ),
                        4.hBox,
                        TextWidget(
                          "${StringManager.youStillNeed.tr()} $senderRemining ${StringManager.toUpgarde.tr()} LV.$nextSenderLevel",
                          style: TextStyle(
                            color: widget.descriptionTextColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.showDivider) 15.hBox,
              if (widget.showDivider)
                Divider(
                  height: 1,
                  color: widget.dividerColor,
                ),
              15.hBox,
            ],
          ),
        );
      },
    );
  }
}
