import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/home/domain/entities/host_level_entity.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'dart:math' as math;

class FloatingActionButtonBody extends StatelessWidget {
  const FloatingActionButtonBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: di<HomeBloc>(),
      buildWhen: (prev, curr) => prev.hostLevelsEntity != curr.hostLevelsEntity,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            bottomDailog(
              context: context,
              barrierColor: ColorManager.transparent,
              widget: Container(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight / 1.30,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(AssetsManager.icWeeklyTier1),
                  ),
                ),
                child: Column(
                  children: [
                    150.hBox,
                    Center(
                      child: Text(
                        state.hostLevelsEntity == null
                            ? StringManager.loading.tr()
                            : state.hostLevelsEntity?.eventType == "3"
                                ? StringManager.monthlyLevel.tr()
                                : state.hostLevelsEntity?.eventType == "2"
                                    ? StringManager.weeklyLevel.tr()
                                    : StringManager.dailyLevel.tr(),
                        style: context.bodyLarge
                            .size(Methods.getLang() == "ar" ? 28.5 : 32.5)
                            .w900
                            .colorExt(const Color(0xFFfed97c))
                            .copyWith(
                          fontFamily: "RobotoSlab",
                          shadows: [
                            const Shadow(
                              color: Color(0xFFfed97c),
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    25.hBox,
                    Expanded(
                      child: HandlingDataWidget(
                        reqState: state.reqStateHostLevels,
                        title: "",
                        subTitle: "",
                        child: Column(
                          children: [
                            Expanded(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationX(math.pi),
                                child: SnakeStepperWrapper(
                                  // 4 mean number of levels 3 not 4
                                  data: state.hostLevelsEntity,
                                  // 1 mean level 0 , 2 mean level 1
                                  currentStage: (() {
                                    final userStage = state.hostLevelsEntity
                                            ?.user?.currentStage ??
                                        0;
                                    return userStage == 0 ? 1 : userStage + 1;
                                  })(),
                                ),
                              ),
                            ),
                            5.hBox,
                            _UserDetailBody(
                              userEntity: state.hostLevelsEntity?.user,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Center(
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                PositionedDirectional(
                  bottom: 15.w,
                  child: ShakeImageWidget(
                    isShaking: (state.hostLevelsEntity?.user?.lastStage ?? 0) >
                        (state.hostLevelsEntity?.user?.currentStage ?? 0),
                    child: ImageWidget(
                      height: 90.h,
                      width: 90.w,
                      image: AssetsManager.icWeeklyTier7,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding:
                        context.paddingSymmetric(horizontal: 5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfed97c),
                      border: Border.all(
                        color: const Color(0xFFfed97c),
                        width: 4.w,
                      ),
                      borderRadius: 100.radius,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(AssetsManager.icWeeklyTier4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        state.hostLevelsEntity == null
                            ? StringManager.loading.tr()
                            : state.hostLevelsEntity?.eventType == "3"
                                ? StringManager.monthlyLevel.tr()
                                : state.hostLevelsEntity?.eventType == "2"
                                    ? StringManager.weeklyLevel.tr()
                                    : StringManager.dailyLevel.tr(),
                        style: context.bodyLarge
                            .size(12)
                            .w900
                            .colorExt(const Color(0xFFFFD746))
                            .copyWith(
                          fontFamily: "RobotoSlab",
                          shadows: [
                            const Shadow(
                              color: Color(0xFFFFD746),
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SnakeStepperWrapper extends StatefulWidget {
  final HostLevelsEntity? data;
  final int currentStage;

  const SnakeStepperWrapper({
    super.key,
    required this.data,
    required this.currentStage,
  });

  @override
  State<SnakeStepperWrapper> createState() => SnakeStepperWrapperState();
}

class SnakeStepperWrapperState extends State<SnakeStepperWrapper> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> stepKeys = {};

  @override
  void initState() {
    for (int index = 0;
        index < ((widget.data?.stages?.length ?? 0) + 1);
        index++) {
      stepKeys[index] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
    super.initState();
  }

  void _scrollToCurrentLevel() {
    final key = stepKeys[widget.currentStage - 1];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 200),
        alignment: 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ConstantsManager.LTR,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: context.paddingOnly(top: 20, bottom: 5),
              child: SnakeStepper(
                data: widget.data,
                currentStage: widget.currentStage,
                stepKeys: stepKeys,
              ),
            ),
          ),
          if (widget.data?.roles != null)
            PositionedDirectional(
              bottom: 10,
              end: Methods.getLang() == "ar" ? null : 20.w,
              start: Methods.getLang() == "ar" ? 20.w : null,
              child: Transform.translate(
                offset: Offset(0, 25.h),
                child: GestureDetector(
                  onTap: () => _showRulesDialog(context),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationX(math.pi),
                    child: Container(
                      height: 32.5.h,
                      width: 85.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFfed97c),
                        border: Border.all(
                          color: const Color(0xFFfed97c),
                          width: 4.w,
                        ),
                        borderRadius: 100.radius,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(AssetsManager.icWeeklyTier4),
                        ),
                      ),
                      child: Center(
                        child: TextWidget(
                          StringManager.rules,
                          style: context.bodyMedium.italic.w600.colorExt(
                            const Color(0xFFfed97c),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) async {
    return bottomDailog(
      context: context,
      barrierColor: ColorManager.transparent,
      widget: Center(
        child: Container(
          height: ScreenUtil().screenHeight / 2.2,
          width: ScreenUtil().screenWidth,
          margin: context.paddingSymmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: 15.radiusCircular,
              bottomRight: 15.radiusCircular,
            ),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                AssetsManager.icWeeklyTier6,
              ),
            ),
          ),
          child: Column(
            children: [
              45.hBox,
              Center(
                child: Text(
                  StringManager.rules.tr(),
                  style: context.bodyLarge
                      .size(25)
                      .w900
                      .colorExt(const Color(0xFFFFD746))
                      .italic
                      .copyWith(
                    fontFamily: "RobotoSlab",
                    shadows: [
                      const Shadow(
                        color: Color(0xFFFFD746),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                          color: const Color(0xFFFFD746), width: 2..w),
                      right: BorderSide(
                          color: const Color(0xFFFFD746), width: 2..w),
                      bottom: BorderSide(
                          color: const Color(0xFFFFD746), width: 2..w),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: 15.radiusCircular,
                      bottomRight: 15.radiusCircular,
                    ),
                  ),
                  child: Padding(
                    padding: context.paddingOnly(
                        start: 10, end: 10, top: 12.5, bottom: 2.5),
                    child: SingleChildScrollView(
                      child: TextWidget(
                        "${widget.data?.roles}",
                        style: context.bodyMedium
                            .size(15)
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SnakeStepper extends StatefulWidget {
  final int currentStage;
  final Map<int, GlobalKey> stepKeys;
  final HostLevelsEntity? data;

  const SnakeStepper({
    super.key,
    required this.currentStage,
    required this.stepKeys,
    required this.data,
  });

  @override
  State<SnakeStepper> createState() => _SnakeStepperState();
}

class _SnakeStepperState extends State<SnakeStepper> {
  @override
  Widget build(BuildContext context) {
    final int count = (widget.data?.stages?.length ?? 0) + 1;

    List<double> stageProgresses() {
      final stages = widget.data?.stages ?? [];
      return List.generate(count - 1, (index) {
        if (index >= stages.length) return 0.0;

        final stage = stages[index];
        final progress = stage.progress ?? 0.0;

        return progress.toDouble();
      });
    }

    final painter = ZigzagPathPainter(
      count: count,
      currentStage: widget.currentStage,
      stageProgresses: stageProgresses(),
    );

    return Padding(
      padding: context.paddingOnly(start: 70, end: 70, top: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepHeight = 160.h;
          final size = Size(260.w, stepHeight * count);
          painter.generatePath(size);
          final points = extractPointsFromPath(painter.generatedPath, count);
          LevelEntity? stageEntity(index) => widget.data?.stages?[index - 1];

          final stages = widget.data?.stages ?? [];
          int lastPickedLoopIndex = 0;
          for (int i = 0; i < stages.length; i++) {
            if (stages[i].isPickedStage == true) {
              lastPickedLoopIndex = i + 1;
            }
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: size,
                painter: painter,
              ),
              for (int index = 0; index < points.length; index++)
                Positioned(
                  key: widget.stepKeys[index],
                  left: (points[index]?.dx ?? 0) - (index == 0 ? 20.w : 25.w),
                  top: (points[index]?.dy ?? 0) - 20.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (index == lastPickedLoopIndex)
                        const _CurrentLevelBody(),
                      if (index != 0 && index != lastPickedLoopIndex)
                        _ActiveOrCompletedLevelBody(
                          index: index,
                          widget: widget,
                        ),
                      if (index > 0) ...{
                        _BoxContainerBody(
                          image: stageEntity(index)?.img ?? "",
                          index: index,
                          points: points,
                          isPickedStage:
                              stageEntity(index)?.isPickedStage ?? false,
                          constraints: constraints,
                        ),
                      },
                      if ((index + 1) > widget.currentStage &&
                          stageEntity(index)?.rewards?.isNotEmpty == true)
                        _RewardsContainerBody(
                          rewards: stageEntity(index)?.rewards ?? const [],
                          index: index,
                          points: points,
                          constraints: constraints,
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UserDetailBody extends StatelessWidget {
  final UserEntity? userEntity;
  const _UserDetailBody({required this.userEntity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      padding: context.paddingSymmetric(horizontal: 5, vertical: 3.5),
      margin: context.paddingOnly(start: 20, end: 20, bottom: 30),
      decoration: BoxDecoration(
        borderRadius: 30.radius,
        border: Border.all(
          color: const Color(0xFFfed97c),
          width: 5.0.w,
        ),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(AssetsManager.icWeeklyTier2),
        ),
      ),
      child: Row(
        children: [
          UserImage(
            imageSize: 45.h,
            image: userEntity?.image ?? "",
            displayName: userEntity?.name ?? '',
          ),
          5.wBox,
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        userEntity?.nextStage == userEntity?.lastStage
                            ? StringManager.reachedMaxLevel
                            : StringManager.nextStage,
                        style: context.bodyMedium
                            .size(userEntity?.nextStage == userEntity?.lastStage
                                ? 13.5
                                : 15)
                            .w500
                            .colorExt(ColorManager.textPrimary),
                      ),
                    ),
                    5.wBox,
                    TextWidget(
                      "${StringManager.stage.tr()} ${userEntity?.nextStage}",
                      style: context.bodyMedium.size(15).w500.colorExt(
                            const Color(0xFFfed97c),
                          ),
                    ),
                    10.wBox,
                  ],
                ),
                Row(
                  children: [
                    TextWidget(
                      StringManager.diamondAmountThisWeek,
                      style: context.bodyMedium
                          .size(11)
                          .colorExt(ColorManager.gray),
                    ),
                    const Spacer(),
                    TextWidget(
                      "${userEntity?.diamonds}",
                      style: context.bodyMedium
                          .size(15)
                          .colorExt(ColorManager.textPrimary),
                    ),
                    10.wBox,
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _RewardsContainerBody extends StatelessWidget {
  const _RewardsContainerBody({
    required this.rewards,
    required this.index,
    required this.points,
    required this.constraints,
  });
  final List<RewardEntity> rewards;
  final int index;
  final List<Offset?> points;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20.h,
      left: ((points[index]?.dx ?? 0) + 45 > constraints.maxWidth / 1.5)
          ? -205.0.w
          : 125.0.w,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(math.pi),
        child: Container(
          height: 60.h,
          width: 120.w,
          padding: context.paddingOnly(start: 5, end: 5),
          decoration: BoxDecoration(
            borderRadius: 6.radius,
            color: const Color(0xFF004942),
            border: Border.all(
              color: const Color(0xFFf9ed8c),
              width: 3,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                rewards.length,
                (index) {
                  return Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageViewWidget(
                            url: rewards[index].image ?? "",
                            height: 30.h,
                            width: 50.w,
                            boxFit: BoxFit.scaleDown,
                          ),
                          TextWidget(
                            "x${rewards[index].name?.split(" /").first}",
                            style: context.bodySmall
                                .size(10)
                                .colorExt(ColorManager.textPrimary),
                          ),
                        ],
                      ),
                      if (index != rewards.length - 1) 5.wBox,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoxContainerBody extends StatelessWidget {
  const _BoxContainerBody({
    required this.image,
    this.isPickedStage = false,
    required this.index,
    required this.points,
    required this.constraints,
  });

  final String image;
  final bool isPickedStage;
  final int index;
  final List<Offset?> points;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: isPickedStage == true ? -15.h : -25.h,
      start: ((points[index]?.dx ?? 0) + 45 > constraints.maxWidth / 1.5)
          ? isPickedStage == true
              ? -80.w
              : -95.0.w
          : isPickedStage == true
              ? 60.w
              : 30.0.w,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(math.pi),
        child: isPickedStage == true
            ? ImageWidget(
                width: 70.w,
                height: 70.h,
                image: AssetsManager.icWeeklyTier3,
              )
            :
            // default type or svg
            ImageViewWidget(
                url: image,
                width: 100.w,
                height: 110.h,
                isFromRoom: true,
              ),
      ),
    );
  }
}

class _ActiveOrCompletedLevelBody extends StatelessWidget {
  const _ActiveOrCompletedLevelBody({
    required this.index,
    required this.widget,
  });

  final int index;
  final SnakeStepper widget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final stage = widget.data?.stages?[index - 1];

        if (stage?.isPickedStage == false) {
          _showLevelRewardsDialog(context, stageIndex: index);
        }
      },
      child: Transform(
        alignment: AlignmentDirectional.center,
        transform: Matrix4.rotationX(math.pi),
        child: Container(
          width: 45.w,
          height: 45.h,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00766A),
            border: Border.all(
              color: const Color(0xFFf9ed8c),
              width: 3,
            ),
          ),
          child: Text(
            "LV$index",
            style: context.bodyMedium.italic.copyWith(
              color: const Color(0xFFfed97c),
              fontWeight: FontWeight.w600,
              shadows: [
                const Shadow(
                  color: Color(0xFFfed97c),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLevelRewardsDialog(
    BuildContext context, {
    required int stageIndex,
  }) async {
    return bottomDailog(
      context: context,
      barrierColor: ColorManager.transparent,
      widget: BlocBuilder<HomeBloc, HomeState>(
        bloc: di<HomeBloc>(),
        buildWhen: (prev, curr) =>
            prev.hostLevelsEntity != curr.hostLevelsEntity,
        builder: (context, state) {
          final stageData = state.hostLevelsEntity?.stages?[stageIndex - 1];
          final rewards = stageData?.rewards ?? const [];
          final diamondsStage = stageData?.diamond ?? 0;
          final userDiamonds =
              double.parse("${state.hostLevelsEntity?.user?.diamonds}");
          final stageId = "${stageData?.id}";
          final isPickedStage = stageData?.isPickedStage ?? false;
          final currentStage = state.hostLevelsEntity?.user?.currentStage ?? 0;

          return Center(
            child: Container(
              width: ScreenUtil().screenWidth,
              margin: context.paddingSymmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: 15.radius,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    AssetsManager.icWeeklyTier6,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  rewards.isNotEmpty ? 40.hBox : 30.hBox,
                  Center(
                    child: Text(
                      "${StringManager.stage.tr()} $stageIndex",
                      style: context.bodyLarge
                          .size(25)
                          .w900
                          .colorExt(const Color(0xFFFFD746))
                          .italic
                          .copyWith(
                        fontFamily: "RobotoSlab",
                        shadows: [
                          const Shadow(
                            color: Color(0xFFFFD746),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                            color: const Color(0xFFFFD746), width: 2..w),
                        right: BorderSide(
                            color: const Color(0xFFFFD746), width: 2..w),
                        bottom: BorderSide(
                            color: const Color(0xFFFFD746), width: 2..w),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: 15.radiusCircular,
                        bottomRight: 15.radiusCircular,
                      ),
                    ),
                    child: Column(
                      children: [
                        30.hBox,
                        Container(
                          width: ScreenUtil().screenWidth,
                          margin: context.paddingSymmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: 15.radius,
                            color: ColorManager.black.withValues(alpha: 0.5),
                          ),
                          child: Column(
                            children: [
                              10.hBox,
                              TextWidget(
                                StringManager.rewards,
                                style: context.bodyLarge.size(16).w600.colorExt(
                                      const Color(0xFFf9ed8c),
                                    ),
                              ),
                              10.hBox,
                              if (rewards.isNotEmpty) ...{
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      10.wBox,
                                      ...List.generate(
                                        rewards.length,
                                        (index) {
                                          return Row(
                                            children: [
                                              Container(
                                                padding:
                                                    context.paddingSymmetric(
                                                        horizontal: 20,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: ColorManager.black
                                                      .withValues(alpha: 0.3),
                                                  borderRadius: 8.radius,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ImageViewWidget(
                                                      url: rewards[index]
                                                              .image ??
                                                          "",
                                                      height: 40.h,
                                                      width: 50.w,
                                                      boxFit: BoxFit.scaleDown,
                                                    ),
                                                    TextWidget(
                                                      "x${rewards[index].name?.split(" /").first}",
                                                      style: context.bodySmall
                                                          .size(13)
                                                          .colorExt(ColorManager
                                                              .onDark),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (index != rewards.length - 1)
                                                10.wBox,
                                            ],
                                          );
                                        },
                                      ),
                                      10.wBox,
                                    ],
                                  ),
                                ),
                              } else ...{
                                TextWidget(
                                  StringManager.noRewardsMessage,
                                  textAlign: TextAlign.center,
                                  padding:
                                      context.paddingSymmetric(horizontal: 10),
                                  style: context.bodyMedium.w400.colorExt(
                                    const Color(0xFFf9ed8c),
                                  ),
                                )
                              },
                              10.hBox,
                            ],
                          ),
                        ),
                        Container(
                          width: ScreenUtil().screenWidth,
                          margin: context.paddingSymmetric(
                              horizontal: 10, vertical: 5),
                          padding: context.paddingOnly(
                              start: 15, end: 15, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: 15.radius,
                            color: ColorManager.black.withValues(alpha: 0.5),
                          ),
                          child: Column(
                            children: [
                              10.hBox,
                              TextWidget(
                                StringManager.tasks,
                                style: context.bodyLarge.size(16).w600.colorExt(
                                      const Color(0xFFf9ed8c),
                                    ),
                              ),
                              10.hBox,
                              Row(
                                children: [
                                  Expanded(
                                    child: TextWidget(
                                      "${StringManager.thisWeeksTotalHostDiamondIncome.tr()} ${Methods.formatCompactNumber(diamondsStage)}",
                                      style: context.bodyMedium
                                          .colorExt(ColorManager.textPrimary),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: currentStage >= stageIndex &&
                                            isPickedStage == false
                                        ? () {
                                            if (userDiamonds >= diamondsStage) {
                                              di<HomeBloc>().add(
                                                PickBoxEvent(
                                                  context: context,
                                                  stageId: stageId,
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        : () {
                                            Methods.printLog(
                                              "Stage $stageIndex is not the current stage",
                                            );
                                          },
                                    child: Container(
                                      height: 30.h,
                                      width: 85.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFfed97c),
                                        border: Border.all(
                                          color: const Color(0xFFfed97c),
                                          width: 3.w,
                                        ),
                                        borderRadius: 100.radius,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              AssetsManager.icWeeklyTier4),
                                        ),
                                      ),
                                      child: Center(
                                        child: TextWidget(
                                          userDiamonds >= diamondsStage
                                              ? StringManager.done_
                                              : StringManager.undone,
                                          style: context.bodyMedium.italic.w300
                                              .colorExt(
                                            const Color(0xFFfed97c),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        15.hBox,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CurrentLevelBody extends StatelessWidget {
  const _CurrentLevelBody();

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationX(math.pi),
      child: Container(
        width: 45.w,
        height: 45.h,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00766A),
          border: Border.all(
            color: const Color(0xFFf9ed8c),
            width: 2.w,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFf9ed8c),
              offset: Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: ImageWidget(
          image: AssetsManager.icWeeklyDirectionUp,
          color: const Color(0xFFf9ed8c),
          height: 25.h,
          width: 25.w,
        ),
      ),
    );
  }
}

class ZigzagPathPainter extends CustomPainter {
  final int count;
  final int currentStage;
  final List<double> stageProgresses;

  ZigzagPathPainter({
    required this.count,
    required this.currentStage,
    required this.stageProgresses,
  });

  Path? generatedPath;

  void generatePath(Size size) {
    final path = Path();
    double stepHeight = size.height / (count - 0.85);
    double widthLeft = size.width * 0.175;
    double widthRight = size.width * 0.9;

    path.moveTo(size.width / 2, 0);

    for (int i = 1; i < count; i++) {
      double y = stepHeight * i;
      double targetX = (i % 2 == 0) ? widthRight : widthLeft;

      double prevX = (i % 2 == 0) ? widthLeft : widthRight;
      double prevY = y - stepHeight;

      double control1X = prevX;
      double control1Y = prevY + stepHeight * 0.5;

      double control2X = targetX;
      double control2Y = prevY + stepHeight * 0.5;

      path.cubicTo(control1X, control1Y, control2X, control2Y, targetX, y);
    }

    generatedPath = path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    generatePath(size);

    if (generatedPath == null) return;

    final metrics = generatedPath!.computeMetrics().first;
    final totalLength = metrics.length;

    double totalProgress = 0;
    for (int i = 0; i < stageProgresses.length; i++) {
      totalProgress += stageProgresses[i];
    }

    double highlightLength = totalLength * (totalProgress / (count - 1));

    final Path highlightedPath = metrics.extractPath(0, highlightLength);
    final Path remainingPath =
        metrics.extractPath(highlightLength, totalLength);

    final shadowPaint = Paint()
      ..color = const Color(0xFFf9ed8c).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..strokeCap = StrokeCap.round;

    final highlightPaint = Paint()
      ..color = const Color(0xFFf9ed8c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final basePaint = Paint()
      ..color = const Color(0xFF004942)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(generatedPath!, shadowPaint);
    canvas.drawPath(remainingPath, basePaint);
    canvas.drawPath(highlightedPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant ZigzagPathPainter oldDelegate) =>
      oldDelegate.currentStage != currentStage ||
      oldDelegate.count != count ||
      !_listEquals(oldDelegate.stageProgresses, stageProgresses);

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class ShakeImageWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  const ShakeImageWidget({
    super.key,
    required this.child,
    this.isShaking = true,
  });

  @override
  State<ShakeImageWidget> createState() => _ShakeImageWidgetState();
}

class _ShakeImageWidgetState extends State<ShakeImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: -3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: -2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isShaking) {
      _startShakeLoop();
    }
  }

  @override
  void didUpdateWidget(ShakeImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking != oldWidget.isShaking) {
      if (widget.isShaking) {
        _startShakeLoop();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  void _startShakeLoop() async {
    while (mounted && widget.isShaking) {
      await _controller.forward();
      _controller.reset();
      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.15,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

List<Offset?> extractPointsFromPath(Path? path, int count) {
  final metrics = path?.computeMetrics().first;
  final length = metrics?.length;

  final List<Offset?> points = [];

  for (int i = 0; i < count; i++) {
    final t = (i / (count - 1)) * (length ?? 0);
    final pos = metrics?.getTangentForOffset(t)?.position;
    points.add(pos);
  }

  return points;
}
