import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/daily_prize/bloc/daily_prizes_bloc.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_item.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_picked.dart';

class DailyPrizeDialog extends StatelessWidget {
  final bool isNeedCompleteInfoDialog;

  const DailyPrizeDialog({super.key, required this.isNeedCompleteInfoDialog});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DailyPrizesBloc, DailyPrizesState>(
      bloc: di<DailyPrizesBloc>(),
      listener: (context, state) {
        if (state.requestStateOpenPrize.isLoaded) {
          final entity = state.dailyPrizesEntity;
          final currentDay = entity?.currentDay ?? 0;
          final gifts = entity?.gifts;
          if (gifts != null && currentDay > 0 && currentDay <= gifts.length) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: ColorManager.transparent,
                child: DailyPrizePicked(
                  image: gifts[currentDay - 1].gift.image,
                  name: gifts[currentDay - 1].gift.name,
                ),
              ),
            );
          }
          return;
        }

        if (state.requestStateOpenPrize.isError) {
          Methods.showToast(
            context,
            message: state.openPrizeMessage,
            isError: true,
          );
          Navigator.pop(context);

          return;
        }
      },
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.requestStateGetPrize,
          title: StringManager.noDataYet.tr(),
          subTitle: StringManager.noDataYet.tr(),
          child: _buildDialogContent(context, state),
        );
      },
    );
  }

  /// Brand colors for this dialog only — a premium purple-to-pink gradient
  /// matching the gift-box artwork, hardcoded so the look stays consistent
  /// regardless of the admin panel's `ColorManager.primary` brand color.
  static const _gradientTop = Color(0xFF8E7CF7);
  static const _gradientMid = Color(0xFFB07AE0);
  static const _gradientEnd = Color(0xFFE29AD6);
  static const _goldAccent = Color(0xFFFE7E07);

  Widget _buildDialogContent(BuildContext context, DailyPrizesState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // This dialog had no way out. Sign in only pops on a SUCCESSFUL claim;
        // both failure branches show a toast and leave the sheet standing, and
        // when the ladder has no gift for today every tap lands in that branch.
        // Back and the barrier were not getting through either, so a fresh
        // install was left staring at an unclosable sheet over the whole feed.
        _buildCloseButton(context),
        8.hBox,
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: ScreenUtil().screenWidth,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_gradientTop, _gradientMid, _gradientEnd],
                ),
                borderRadius: 20.radius,
                boxShadow: [
                  BoxShadow(
                    color: _gradientTop.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderText(
                      context, state.dailyPrizesEntity?.totalDays ?? 0),
                  20.hBox,
                  _row(context, state, [1, 2, 3, 4]),
                  10.hBox,
                  _row(context, state, [5, 6, 7]),
                  25.hBox,
                  _buildClaimButton(context, state),
                  25.hBox,
                ],
              ),
            ),
            // Decorative gift-box artwork, peeking over the card's top edge —
            // mirrors the reference design.
            Positioned(
              top: -26.h,
              right: 12.w,
              child: IgnorePointer(
                child: Image.asset(
                  AssetsManager.dailyRewardGiftBox,
                  width: 88.w,
                  height: 88.w,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Sits on the dimmed barrier just above the card, so it never fights the
  /// header artwork for the corner.
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.black.withValues(alpha: 0.35),
          border: Border.all(color: ColorManager.white, width: 1.5),
        ),
        child: Icon(Icons.close, size: 18.r, color: ColorManager.white),
      ),
    );
  }

  Widget _buildHeaderText(BuildContext context, int totalDays) {
    return Padding(
      padding: context.paddingOnly(start: 20, top: 26, end: 84, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            StringManager.weeklySignIn.tr(),
            style: context.titleLarge.bold
                .size(20)
                .colorExt(ColorManager.white),
          ),
          6.hBox,
          TextWidget(
            StringManager.youSignInDay(day: totalDays.toString()),
            style: context.bodySmall.w600
                .colorExt(ColorManager.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  Widget _row(
      BuildContext context,
      DailyPrizesState state,
      List<int> days,
      ) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          return Expanded(
            flex: day == 7 ? 2 : 1,
            child: _dailyPrize(day, state),
          );
        }).toList(),
      ),
    );
  }

  Widget _dailyPrize(int day, DailyPrizesState state) {
    final entity = state.dailyPrizesEntity;
    final currentDay = entity?.currentDay ?? 0;
    final isReceived = entity?.isReceived ?? false;

    final isThisDay = currentDay == day;
    final isPastDay = currentDay > day;

    final isTodayReceived = isThisDay && isReceived;

    final isPreviousDayReceived = isPastDay;

    final showCheck = isTodayReceived || isPreviousDayReceived;

    final image = entity?.gifts[day - 1].gift.image ?? '';

    return DailyPrizeItem(
      day: day,
      isThisDay: isThisDay,
      isLastDay: isPastDay,
      takenPrize: showCheck,
      image: image,
    );
  }

  Widget _buildClaimButton(BuildContext context, DailyPrizesState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ButtonWidget(
          onPressed: () {
            final entity = state.dailyPrizesEntity;
            final currentDay = entity?.currentDay ?? 0;
            final result = entity?.gifts;

            if (entity?.isReceived == true) {
              Methods.showToast(
                context,
                message: StringManager.receivedGift.tr(),
                isError: true,
              );
            } else if (result != null &&
                currentDay > 0 &&
                currentDay <= result.length) {
              di<DailyPrizesBloc>().add(OpenDailyPrizesEvent());
            } else {
              Methods.showToast(
                context,
                message: StringManager.noGiftsToday.tr(),
                isError: true,
              );
            }
          },
          isLoading: state.requestStateOpenPrize.isLoading,
          title: StringManager.signIn.tr(),
          width: ScreenUtil().screenWidth * 0.4,
          height: 45.h,
          backgroundColors: const [_gradientTop, _gradientEnd],
          titleColor: ColorManager.white,
        ),
      ],
    );
  }
}