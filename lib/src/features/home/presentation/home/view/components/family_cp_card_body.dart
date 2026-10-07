import 'package:general/src/features/home/presentation/daily_prize/bloc/daily_prizes_bloc.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_dialog.dart';

import '../../../../../../core/index.dart';

class FamilyCpCardBody extends StatelessWidget {
  const FamilyCpCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: 85.h,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.familyRankPage,
                      arguments: 2);
                },
                child: Container(
                  height: 100.h,
                  width: 182.w,
                  decoration: BoxDecoration(
                    borderRadius: 13.radius,
                    image: DecorationImage(
                        image: AssetImage(
                          AssetsManager.dailyPrizeCard,
                        ),
                        fit: BoxFit.fill),
                  ),
                  child: Row(
                    children: [
                      10.wBox,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          10.hBox,
                          TextWidget(StringManager.familyRank.tr(),
                              style: context.bodyMedium.w600
                                  .colorExt(ColorManager.textPrimary)
                                  .copyWith(letterSpacing: 0.5)),
                          TextWidget(StringManager.clickToSeeFamilies.tr(),
                              style: context.bodySmall
                                  .colorExt(ColorManager.textPrimary)
                                  .copyWith(letterSpacing: 0.3)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 10.wBox,
            Expanded(
              child: InkWell(
                onTap: () {
                  if (di<DailyPrizesBloc>()
                      .state
                      .requestStateGetPrize
                      .isLoaded) {
                    showDialog(
                      context: context,
                      builder: (_) => const Dialog(
                        backgroundColor: ColorManager.transparent,
                        insetPadding:
                            EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                        child: DailyPrizeDialog(
                          isNeedCompleteInfoDialog: true,
                        ),
                      ),
                    );
                  } else {
                    di<DailyPrizesBloc>()
                        .add(GetDailyPrizesEvent(context: context));
                  }
                },
                child: Container(
                  height: 100.h,
                  width: 182.w,
                  padding: context.paddingOnly(start: 10),
                  decoration: BoxDecoration(
                    borderRadius: 13.radius,
                    image: DecorationImage(
                        image: AssetImage(
                          AssetsManager.familyCardBackground,
                        ),
                        fit: BoxFit.fill),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.hBox,
                      TextWidget(StringManager.dailySignin.tr(),
                          style: context.bodyMedium.w600
                              .colorExt(ColorManager.textPrimary)
                              .copyWith(letterSpacing: 0.5)),
                      TextWidget(StringManager.toGetDailyPrize.tr(),
                          style: context.bodySmall
                              .colorExt(ColorManager.textPrimary)
                              .copyWith(letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
