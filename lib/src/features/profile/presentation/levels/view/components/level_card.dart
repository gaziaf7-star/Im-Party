part of 'package:general/src/features/profile/presentation/levels/view/level_page.dart';

/// Per-tab HD colour theme for the level pages: a light-to-deep gradient
/// plus a matching deep text colour (so labels stay readable without
/// needing plain white-on-vivid), mirroring the reference design's
/// Wealth (purple) / Charm (pink-red) / Growth (teal) look.
class _LevelTheme {
  final List<Color> gradient;
  final Color textColor;
  final Color trackColor;

  const _LevelTheme(this.gradient, this.textColor, this.trackColor);
}

_LevelTheme _levelThemeFor(String type) {
  switch (type) {
    case 'reciever':
      return const _LevelTheme(
        [Color(0xFFFFD9E0), Color(0xFFFF4D6D)],
        Color(0xFF9A1B3A),
        Color(0xFFFFE3E9),
      );
    case 'charge':
    case 'room':
      return const _LevelTheme(
        [Color(0xFFDFF7EA), Color(0xFF12B886)],
        Color(0xFF065F46),
        Color(0xFFE3FBF0),
      );
    case 'sender':
    default:
      return const _LevelTheme(
        [Color(0xFFEDE7FE), Color(0xFF8B5CF6)],
        Color(0xFF4C1D95),
        Color(0xFFF1ECFF),
      );
  }
}

class LevelCard extends StatelessWidget {
  final bool isSender;
  final Color color;
  final String text;
  final String type;

  const LevelCard({
    super.key,
    required this.type,
    required this.isSender,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LevelBloc, AllLevelsState>(
      bloc: di<LevelBloc>(),
      buildWhen: (prev, curr) =>
      prev.userLevelsRequest != curr.userLevelsRequest ||
          prev.userLevels != curr.userLevels ||
          prev.changeImage != curr.changeImage,
      builder: (context, state) {
        final theme = _levelThemeFor(type);
        return HandlingDataWidget(
          titleStyle: context.bodyLarge.colorExt(ColorManager.black),
          reqState: state.userLevelsRequest,
          title: StringManager.noLevels.tr(),
          subTitle: StringManager.noLevelsMsg.tr(),
          onTap: () {
            di<LevelBloc>().add(GetUserLevels());
          },
          child: Stack(
            children: [
              Container(
                clipBehavior: Clip.none,
                padding: context.paddingAll(8),
                margin: context.paddingAll(25),
                width: 370.w,
                height: 180.h,
                decoration: BoxDecoration(
                  borderRadius: 16.radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.gradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.gradient[1].withValues(alpha: 0.35),
                      blurRadius: 16.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserImage(
                          image: MyDataModel.getInstance().profile?.image ?? '',
                          displayName: MyDataModel.getInstance().name ?? '',
                          borderRadius: 170.radius,
                          imageSize: 55.w,
                          border:
                          Border.all(color: ColorManager.white, width: 2),
                        ),
                        5.wBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                "$text ${StringManager.level(_getCurrentLevel(type, state))}",
                                style: context.bodyMedium.bold
                                    .size(18)
                                    .colorExt(theme.textColor),
                              ),
                              7.hBox,
                              LinearPercentIndicator(
                                barRadius: Radius.circular(10.r),
                                animateFromLastPercent: true,
                                width: 250.w,
                                animation: true,
                                padding: context.paddingZero(),
                                percent: _getPercent(type, state),
                                backgroundColor:
                                ColorManager.white.withValues(alpha: (0.55)),
                                progressColor: theme.textColor,
                              ),
                              SizedBox(
                                width: 250.w,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    TextWidget(
                                      StringManager.level(
                                          _getCurrentLevel(type, state)),
                                      style: context.bodyMedium
                                          .size(15)
                                          .colorExt(theme.textColor),
                                    ),
                                    TextWidget(
                                      StringManager.level(
                                          _getNextLevel(type, state)),
                                      style: context.bodyMedium
                                          .size(15)
                                          .colorExt(theme.textColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    10.hBox,
                    Container(
                      height: 80.h,
                      alignment: Alignment.center,
                      padding: context.paddingAll(10),
                      decoration: BoxDecoration(
                        color: ColorManager.white.withValues(alpha: (0.45)),
                        borderRadius: 12.radius,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 80.h,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextWidget(
                                    _getCurrentExp(type, state),
                                    style: context.bodyMedium.bold
                                        .size(15)
                                        .colorExt(theme.textColor),
                                  ),
                                  TextWidget(
                                    StringManager.currentExperienceLevel.tr(),
                                    style: context.bodySmall
                                        .size(12)
                                        .colorExt(theme.textColor),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40.h,
                              width: 1.w,
                              decoration: BoxDecoration(
                                color:
                                theme.textColor.withValues(alpha: (0.3)),
                                borderRadius: 5.radius,
                              ),
                            ),
                            SizedBox(
                              height: 80.h,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextWidget(
                                    _getRemaining(type, state),
                                    style: context.bodyMedium.bold
                                        .size(15)
                                        .colorExt(theme.textColor),
                                  ),
                                  TextWidget(
                                    StringManager.nextlevel.tr(),
                                    style: context.bodySmall
                                        .size(12)
                                        .colorExt(theme.textColor),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 30,
                child: Image.asset(
                  state.changeImage
                      ? AssetsManager.coinsVip
                      : AssetsManager.diamondsIcon,
                  width: 130.w,
                  fit: BoxFit.fill,
                  opacity: const AlwaysStoppedAnimation(0.12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCurrentLevel(String type, AllLevelsState state) {
    switch (type) {
      case 'sender':
        return state.userLevels?.level?.senderLevel.toString() ?? '';
      case 'reciever':
        return state.userLevels?.level?.reciverLevel.toString() ?? '';
      case 'charge':
        return state.userLevels?.chargeLevel?.currentLevel.toString() ?? '';
      case 'room':
        return state.userLevels?.roomLevel?.currentLevel.toString() ?? '';
      default:
        return '';
    }
  }

  String _getNextLevel(String type, AllLevelsState state) {
    switch (type) {
      case 'sender':
        return state.userLevels?.level?.nextSenderLevel.toString() ?? '';
      case 'reciever':
        return state.userLevels?.level?.nextReciverLevel.toString() ?? '';
      case 'charge':
        return state.userLevels?.chargeLevel?.nextLevel.toString() ?? '';
      case 'room':
        return state.userLevels?.roomLevel?.nextLevel.toString() ?? '';
      default:
        return '';
    }
  }

  double _getPercent(String type, AllLevelsState state) {
    switch (type) {
      case 'sender':
        return (state.userLevels?.level?.senderPer?.toDouble() ?? 0.0) / 100;
      case 'reciever':
        return (state.userLevels?.level?.reciverPer?.toDouble() ?? 0.0) / 100;
      case 'charge':
        return (state.userLevels?.chargeLevel?.progress?.toDouble() ?? 0.0);
      case 'room':
        return (state.userLevels?.roomLevel?.progress?.toDouble() ?? 0.0);
      default:
        return 0.0;
    }
  }

  String _getCurrentExp(String type, AllLevelsState state) {
    switch (type) {
      case 'sender':
        return state.userLevels?.level?.senderNum.toString() ?? '';
      case 'reciever':
        return state.userLevels?.level?.reciverNum.toString() ?? '';
      case 'charge':
        return state.userLevels?.chargeLevel?.currentExp.toString() ?? '';
      case 'room':
        return state.userLevels?.roomLevel?.currentExp.toString() ?? '';
      default:
        return '';
    }
  }

  String _getRemaining(String type, AllLevelsState state) {
    switch (type) {
      case 'sender':
        return state.userLevels?.level?.remSenderLevel.toString() ?? '';
      case 'reciever':
        return state.userLevels?.level?.remReceiverLevel.toString() ?? '';
      case 'charge':
        return state.userLevels?.chargeLevel?.remaining.toString() ?? '';
      case 'room':
        return state.userLevels?.roomLevel?.remaining.toString() ?? '';
      default:
        return '';
    }
  }
}