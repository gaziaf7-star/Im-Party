import 'package:general/src/core/index.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:general/src/features/home/presentation/daily_prize/bloc/daily_prizes_bloc.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_item.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_picked.dart';

/// Weekly sign-in, drawn on the "Daily Check-in" frame artwork: the gift box
/// and ribbon title live in the image, the day cards sit in its white panel
/// and the claim button is laid over the image's purple pill.
class DailyPrizeDialog extends StatelessWidget {
  final bool isNeedCompleteInfoDialog;

  const DailyPrizeDialog({super.key, required this.isNeedCompleteInfoDialog});

  /// Opens the dialog after re-fetching the 7-day ladder, so "already
  /// claimed" is never stale (e.g. app left open since yesterday).
  static Future<void> show(BuildContext context) async {
    final bloc = di<DailyPrizesBloc>();
    if (!bloc.state.requestStateGetPrize.isLoading) {
      bloc.add(GetDailyPrizesEvent(context: context));
    }
    final loaded = await bloc.stream
        .firstWhere((s) => !s.requestStateGetPrize.isLoading)
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
    if (!loaded.requestStateGetPrize.isLoaded || !context.mounted) return;
    // The bloc already pops the dialog up itself for an unclaimed day.
    if (loaded.dailyPrizesEntity?.isReceived != true &&
        ConstantsManager.isOptionalUpdate == true) {
      return;
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: ColorManager.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: const DailyPrizeDialog(isNeedCompleteInfoDialog: false),
      ),
    );
  }

  static const String _frame = 'assets/icons/ui_icons/dailycard frame.png';

  /// Frame artwork is 411 x 606; the fractions below are measured on it.
  static const double _aspect = 606 / 411;
  static const double _panelTop = 0.335;
  static const double _panelBottom = 0.832;
  static const double _panelSide = 0.07;
  static const double _pillTop = 0.848;
  static const double _pillHeight = 0.089;
  static const double _pillLeft = 0.16;
  static const double _pillRight = 0.17;

  static const _textGrey = Color(0xFF6B5A7B);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DailyPrizesBloc, DailyPrizesState>(
      bloc: di<DailyPrizesBloc>(),
      // React only to a claim finishing. The claim state stays "loaded" after
      // a claim, so without this any later emission (e.g. a re-fetch) would
      // close a freshly opened dialog straight away.
      listenWhen: (prev, curr) =>
          prev.requestStateOpenPrize != curr.requestStateOpenPrize,
      listener: (context, state) {
        if (state.requestStateOpenPrize.isLoaded) {
          final entity = state.dailyPrizesEntity;
          final currentDay = entity?.currentDay ?? 0;
          final gifts = entity?.gifts;
          if (gifts != null && currentDay > 0 && currentDay <= gifts.length) {
            Navigator.pop(context);
            // Same "Congratulations" popup + claim sound as im_Chat.
            DailyPrizePicked.show(
              context,
              image: gifts[currentDay - 1].gift.image,
              name: gifts[currentDay - 1].gift.name,
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

  Widget _buildDialogContent(BuildContext context, DailyPrizesState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : ScreenUtil().screenWidth;
        final w = maxW.clamp(260.0, 370.0).toDouble();
        final h = w * _aspect;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(_frame, fit: BoxFit.fill),
                  ),
                  // Day cards inside the white panel. FittedBox keeps them
                  // inside the panel on very small screens instead of
                  // overflowing the artwork.
                  Positioned(
                    left: w * _panelSide,
                    right: w * _panelSide,
                    top: h * _panelTop,
                    bottom: h * (1 - _panelBottom),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: w * (1 - 2 * _panelSide),
                        child: _panel(context, state, w),
                      ),
                    ),
                  ),
                  Positioned(
                    left: w * _pillLeft,
                    right: w * _pillRight,
                    top: h * _pillTop,
                    height: h * _pillHeight,
                    child: _claimButton(context, state, h * _pillHeight),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 250.ms)
                .scale(
                  begin: const Offset(.85, .85),
                  curve: Curves.easeOutBack,
                  duration: 420.ms,
                ),
            SizedBox(height: 14.h),
            _closeButton(context),
          ],
        );
      },
    );
  }

  Widget _panel(BuildContext context, DailyPrizesState state, double w) {
    final totalDays = state.dailyPrizesEntity?.totalDays ?? 0;
    final tileH = w * 0.265;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: w * 0.01, bottom: w * 0.025),
          child: Text(
            StringManager.youSignInDay(day: totalDays.toString()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _textGrey,
              fontSize: w * 0.037,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _row(state, const [1, 2, 3, 4], tileH, w),
        SizedBox(height: w * 0.025),
        _row(state, const [5, 6, 7], tileH, w),
      ],
    );
  }

  Widget _row(DailyPrizesState state, List<int> days, double tileH, double w) {
    return Row(
      children: [
        for (final day in days)
          Expanded(
            flex: day == 7 ? 2 : 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.008),
              child: _dailyPrize(day, state, tileH, w)
                  .animate(delay: (40 * day).ms)
                  .fadeIn(duration: 260.ms)
                  .slideY(begin: .15, end: 0, duration: 260.ms),
            ),
          ),
      ],
    );
  }

  Widget _dailyPrize(int day, DailyPrizesState state, double tileH, double w) {
    final entity = state.dailyPrizesEntity;
    final currentDay = entity?.currentDay ?? 0;
    final isReceived = entity?.isReceived ?? false;
    final isThisDay = currentDay == day;
    final isPastDay = currentDay > day;
    final gifts = entity?.gifts;
    final image = (gifts != null && day - 1 < gifts.length)
        ? gifts[day - 1].gift.image
        : '';
    // TEMP debug: the exact URL each day card loads.
    debugPrint('[DAILY_IMG] day=$day gifts=${gifts?.length ?? 0} '
        'image="$image" url="${EndPoints.getImage(image)}"');

    return DailyPrizeItem(
      day: day,
      isThisDay: isThisDay,
      isLastDay: isPastDay,
      takenPrize: (isThisDay && isReceived) || isPastDay,
      image: image,
      height: tileH,
      scale: w,
    );
  }

  Widget _claimButton(
      BuildContext context, DailyPrizesState state, double pillH) {
    final received = state.dailyPrizesEntity?.isReceived == true;
    final loading = state.requestStateOpenPrize.isLoading;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading
          ? null
          : () {
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
      child: Center(
        child: loading
            ? SizedBox(
                width: pillH * 0.42,
                height: pillH * 0.42,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                received
                    ? StringManager.receivedGift.tr()
                    : StringManager.signIn.tr(),
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: received ? .75 : 1),
                  fontSize: pillH * 0.36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .3,
                  shadows: const [
                    Shadow(
                      color: Color(0x66480090),
                      blurRadius: 4,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.black.withValues(alpha: 0.3),
          border: Border.all(color: ColorManager.white, width: 1.8),
        ),
        child: Icon(Icons.close_rounded, size: 22.r, color: ColorManager.white),
      ),
    );
  }
}
