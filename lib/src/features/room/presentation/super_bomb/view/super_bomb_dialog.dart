import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/custom_progress_indicator.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_bloc/get_super_bombs_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_theme_bloc/get_super_bombs_theme_bloc.dart';
import 'package:general/src/features/room/room.dart';

import '../../../domain/entities/super_bomb_entity.dart';

class SuperBombDialog extends StatefulWidget {
  const SuperBombDialog({super.key});

  @override
  State<SuperBombDialog> createState() => _SuperBombDialogState();
}

class _SuperBombDialogState extends State<SuperBombDialog> {
  @override
  void initState() {
    di<GetSuperBombsBloc>()
        .add(GetSuperBombsEvent(RoomData.instance.room.id.toString()));
    if (!di<GetSuperBombsBloc>().state.videoState.isLoaded) {
      di<GetSuperBombsBloc>().add(GetSuperBoomVideosEvent());
    }
    super.initState();
  }

  Widget _buildGiftWidget(String type, String gift) {
    switch (type) {
      case "svga":
        return CacheSvgaWidget(url: gift);
      default:
        return ImageViewWidget(
          url: gift,
          boxFit: BoxFit.contain,
        );
    }
  }

  // The admin panel accepts PNG as readily as SVGA for boom/progress art,
  // and this install uploaded PNGs. Feeding a PNG through ShowSVGA
  // unconditionally -- as this dialog used to -- threw "Filter error, bad
  // data" from the SVGA parser. Routing by GetSuperBombsThemeState's
  // declared type fixed that crash, but rendering the locally CACHED file
  // via Image.file then showed a broken-image icon instead when that cache
  // write was partial/corrupt. ImageViewWidget is the app's normal image
  // path (used successfully for reward art right below) -- it sniffs the
  // URL's own extension and fetches over the network with its own
  // retry/fallback, sidestepping the local cache entirely.
  Widget _buildBoomAsset({
    required String url,
    required double size,
    Key? key,
  }) {
    if (url.isEmpty) return SizedBox(key: key, width: size, height: size);
    return ImageViewWidget(
      key: key,
      url: url,
      height: size,
      width: size,
      boxFit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSuperBombsThemeBloc, GetSuperBombsThemeState>(
      bloc: di<GetSuperBombsThemeBloc>(),
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, themeState) {
        return BlocBuilder<GetSuperBombsBloc, GetSuperBombsState>(
          bloc: di<GetSuperBombsBloc>(),
          buildWhen: (prev, curr) =>
              prev.state != curr.state ||
              prev.data != curr.data ||
              prev.selectedIndex != curr.selectedIndex,
          builder: (context, state) {
            SuperBombDataEntity item = const SuperBombDataEntity(
              id: 0,
              level: 0,
              minTarget: 0,
              rewards: [],
              roomBooms: [],
              target: 0,
            );

            if (state.state.isLoaded) {
              final list = state.data?.data ?? [];

              if (list.isNotEmpty &&
                  state.selectedIndex >= 0 &&
                  state.selectedIndex < list.length) {
                item = list[state.selectedIndex];
              }
            }
            return HandlingDataWidget(
              reqState: state.state,
              title: '',
              subTitle: '',
              isNeedLoadingWidget: false,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16.r),
                        topLeft: Radius.circular(16.r),
                      ),
                      child: SizedBox(
                        height: ScreenUtil().screenHeight / 1.75,
                        width: ScreenUtil().screenWidth,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Straight from the API URL -- the theme bloc's
                            // cached File could be null while still
                            // downloading, and falling back to File("") threw
                            // a PathNotFoundException instead of just
                            // rendering blank.
                            Builder(builder: (context) {
                              final backgroundUrl = themeState
                                  .getLevelBackgroundUrl(
                                      state.selectedIndex + 1);
                              if (backgroundUrl.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return ImageViewWidget(
                                url: backgroundUrl,
                                boxFit: BoxFit.fill,
                              );
                            }),
                            Column(
                        children: [
                          // Title Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(width: 20),
                                6.0.wBox,
                                TextWidget(
                                  StringManager.superBomb.tr(),
                                  style: context.bodyLarge
                                      .colorExt(ColorManager.textPrimary)
                                      .size(15)
                                      .bold,
                                ),
                                6.0.wBox,
                                GestureDetector(
                                  onTap: () {
                                    di<GetSuperBombsBloc>()
                                        .add(GetSuperBoomRulesEvent());
                                    Navigator.pushNamed(
                                        context, Routes.superBoomRulesScreen);
                                  },
                                  child: Icon(
                                    Icons.help_outline,
                                    color: ColorManager.white
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Builder(
                            builder: (context) {
                              final levelUrl = themeState.getLevelBoomUrl(
                                  state.selectedIndex + 1);
                              // A level whose target equals its minTarget
                              // (the LAST level in this install's data has
                              // both at 500000) divides by zero here,
                              // handing getProgressAnimationUrl a NaN/
                              // Infinity value. Dart's num.clamp() throws
                              // on NaN, which crashed this Builder's frame
                              // mid-rebuild -- the boom art that was
                              // already painted stayed on screen looking
                              // fine until the NEXT rebuild tried to run
                              // this same broken math again and errored
                              // out again, at which point Flutter dropped
                              // to its red-box/blank fallback instead of
                              // the art. Guarding the denominator keeps
                              // this a plain 0% instead of a crash.
                              final targetSpan = item.target - item.minTarget;
                              final progressValue =
                                  (state.data?.data.isNotEmpty ?? false) &&
                                          targetSpan != 0
                                      ? (((item.roomBooms.isNotEmpty)
                                              ? double.parse(
                                                    item.roomBooms[0]
                                                        .totalGiftsValue
                                                        .toString(),
                                                  ) -
                                                  double.parse(
                                                    item.minTarget.toString(),
                                                  )
                                              : 0) /
                                          targetSpan *
                                          100)
                                      : 0.0;
                              final progressUrl = themeState
                                  .getProgressAnimationUrl(progressValue);
                              return Stack(
                                children: [
                                  _buildBoomAsset(
                                    key: ValueKey('boom-level-$levelUrl'),
                                    url: levelUrl,
                                    size: 110.h,
                                  ),
                                  _buildBoomAsset(
                                    key: ValueKey('boom-progress-$progressUrl'),
                                    url: progressUrl,
                                    size: 110.h,
                                  ),
                                ],
                              );
                            },
                          ),

                          10.hBox,

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  themeState.cachedLevelBoomFiles.length,
                                  (index) {
                                final isActive = index == state.selectedIndex;
                                return InkWell(
                                  onTap: () {
                                    di<GetSuperBombsBloc>()
                                        .add(SelectSuperBomb(index));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Builder(builder: (context) {
                                              final levelUrl = themeState
                                                  .getLevelBoomUrl(index + 1);
                                              final fullUrl = themeState
                                                  .getProgressAnimationUrl(
                                                      100);
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  _buildBoomAsset(
                                                    key: ValueKey(
                                                        'boom-tab-level-$levelUrl'),
                                                    url: levelUrl,
                                                    size: 50.h,
                                                  ),
                                                  _buildBoomAsset(
                                                    key: ValueKey(
                                                        'boom-tab-full-$fullUrl'),
                                                    url: fullUrl,
                                                    size: 50.h,
                                                  ),
                                                ],
                                              );
                                            }),
                                            4.hBox,
                                            Container(
                                              padding: context.paddingSymmetric(
                                                  horizontal: 8, vertical: 3.0),
                                              decoration: BoxDecoration(
                                                borderRadius: 10.radius,
                                                border: Border.all(
                                                  color: isActive
                                                      ? ColorManager.yellow
                                                      : ColorManager
                                                          .transparent,
                                                ),
                                              ),
                                              child: Text(
                                                "LV.${index + 1}",
                                                style: context.bodySmall
                                                    .colorExt(isActive
                                                        ? ColorManager.yellow
                                                        : ColorManager.white)
                                                    .size(10),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (index != 4)
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: ColorManager.white
                                                .withValues(alpha: 0.5),
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          5.hBox,

                          if (state.data?.data != null)
                            Padding(
                              padding: context.paddingSymmetric(horizontal: 20),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: ColorManager.yellow,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ProgressWithImage(
                                  progress: (((item.roomBooms.isNotEmpty)
                                          ? double.parse(
                                                state
                                                        .data
                                                        ?.data[
                                                            state.selectedIndex]
                                                        .roomBooms[0]
                                                        .totalGiftsValue ??
                                                    "0",
                                              ) -
                                              double.parse(
                                                state
                                                        .data
                                                        ?.data[
                                                            state.selectedIndex]
                                                        .minTarget
                                                        .toString() ??
                                                    "0",
                                              )
                                          : 0) /
                                      ((item.target) - (item.minTarget)) *
                                      100),
                                ),
                              ),
                            ),

                          8.hBox,

                          if (state.data?.data != null)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                StringManager.superBoomHint.tr(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color:
                                      ColorManager.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ),

                          8.0.hBox,

                          if ((item.rewards.isNotEmpty == true) &&
                              ((item.roomBooms.isEmpty == true) ||
                                  (item.roomBooms[0].topContributors.isEmpty ==
                                      true)))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 160.h,
                                    width: ScreenUtil().screenWidth * 0.35,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Positioned(
                                          top: 0,
                                          child: Container(
                                            width:
                                                ScreenUtil().screenWidth * 0.35,
                                            height: 160.h,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: ColorManager.white
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: _buildGiftWidget(
                                                (state
                                                            .data
                                                            ?.data[state
                                                                .selectedIndex]
                                                            .rewards
                                                            .isNotEmpty ==
                                                        true)
                                                    ? state
                                                            .data
                                                            ?.data[state
                                                                .selectedIndex]
                                                            .rewards[0]
                                                            .image
                                                            .split(".")
                                                            .last ??
                                                        ""
                                                    : '',
                                                (state
                                                            .data
                                                            ?.data[state
                                                                .selectedIndex]
                                                            .rewards
                                                            .isNotEmpty ==
                                                        true)
                                                    ? state
                                                            .data
                                                            ?.data[state
                                                                .selectedIndex]
                                                            .rewards[0]
                                                            .image ??
                                                        ""
                                                    : '',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  8.wBox,
                                  Expanded(
                                    child: SizedBox(
                                      height: 160.h,
                                      child: GridView.count(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        children: (state
                                                    .data
                                                    ?.data[state.selectedIndex]
                                                    .rewards
                                                    .skip(1)
                                                    .map(
                                                  (rewardPath) {
                                                    return Stack(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: ColorManager
                                                                .white
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Center(
                                                            child:
                                                                _buildGiftWidget(
                                                              rewardPath.image
                                                                  .split(".")
                                                                  .last,
                                                              rewardPath.image,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ) ??
                                                [])
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (state.data?.data != null &&
                              (item.roomBooms.isNotEmpty == true) &&
                              (item.roomBooms[0].topContributors.isNotEmpty ==
                                  true))
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: ColorManager.transparent,
                                        height: 130.h,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              height: 110.h,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xff293663),
                                                    Color(0xff1a284f),
                                                    Color(0xff0b1433),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                border: const Border(
                                                  top: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  left: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  right: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  bottom: BorderSide
                                                      .none, // No border at the bottom
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(12.5.r),
                                                  topRight:
                                                      Radius.circular(12.5.r),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -20,
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ImageViewWidget(
                                                        url: (state
                                                                        .data
                                                                        ?.data[state
                                                                            .selectedIndex]
                                                                        .roomBooms[
                                                                            0]
                                                                        .topContributors
                                                                        .length ??
                                                                    0) >
                                                                1
                                                            ? state
                                                                    .data
                                                                    ?.data[state
                                                                        .selectedIndex]
                                                                    .roomBooms[
                                                                        0]
                                                                    .topContributors[
                                                                        1]
                                                                    .img ??
                                                                ""
                                                            : "",
                                                        boxFit: BoxFit.fill,
                                                        width: 70.w,
                                                        height: 70.h,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      Image.asset(
                                                        AssetsManager
                                                            .topTwoFrame,
                                                        width: 70.w,
                                                        height: 70.h,
                                                      ),
                                                    ],
                                                  ),
                                                  5.hBox,
                                                  if ((state
                                                              .data
                                                              ?.data[state
                                                                  .selectedIndex]
                                                              .roomBooms[0]
                                                              .topContributors
                                                              .length ??
                                                          0) >
                                                      1)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          state
                                                                  .data
                                                                  ?.data[state
                                                                      .selectedIndex]
                                                                  .roomBooms[0]
                                                                  .topContributors[
                                                                      1]
                                                                  .totalGift ??
                                                              "0",
                                                          style:
                                                              const TextStyle(
                                                            color: ColorManager
                                                                .agencyYellow,
                                                          ),
                                                        ),
                                                        5.wBox,
                                                        Image.asset(
                                                          AssetsManager.coin,
                                                          width: 20.w,
                                                          height: 20.h,
                                                        )
                                                      ],
                                                    ),
                                                  if ((state
                                                              .data
                                                              ?.data[state
                                                                  .selectedIndex]
                                                              .roomBooms[0]
                                                              .topContributors
                                                              .length ??
                                                          0) >
                                                      1)
                                                    SizedBox(
                                                      width: 120.w,
                                                      child: Text(
                                                        item
                                                            .roomBooms[0]
                                                            .topContributors[1]
                                                            .name,
                                                        style: const TextStyle(
                                                          color: ColorManager
                                                              .white,
                                                        ),
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    10.wBox,
                                    Expanded(
                                      child: Container(
                                        color: ColorManager.transparent,
                                        height: 170.h,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              height: 130.h,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xff293663),
                                                    Color(0xff1a284f),
                                                    Color(0xff0b1433),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                border: const Border(
                                                  top: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  left: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  right: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  bottom: BorderSide
                                                      .none, // No border at the bottom
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(12.5.r),
                                                  topRight:
                                                      Radius.circular(12.5.r),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -10,
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ImageViewWidget(
                                                        url: item
                                                            .roomBooms[0]
                                                            .topContributors[0]
                                                            .img,
                                                        boxFit: BoxFit.fill,
                                                        width: 70.w,
                                                        height: 70.h,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      Image.asset(
                                                        AssetsManager
                                                            .topOneFrame,
                                                        width: 70.w,
                                                        height: 70.h,
                                                      ),
                                                    ],
                                                  ),
                                                  5.hBox,
                                                  Row(
                                                    children: [
                                                      Text(
                                                        item
                                                            .roomBooms[0]
                                                            .topContributors[0]
                                                            .totalGift,
                                                        style: const TextStyle(
                                                          color: ColorManager
                                                              .agencyYellow,
                                                        ),
                                                      ),
                                                      5.wBox,
                                                      Image.asset(
                                                        AssetsManager.coin,
                                                        width: 20.w,
                                                        height: 20.h,
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 120.w,
                                                    child: Text(
                                                      state
                                                              .data
                                                              ?.data[state
                                                                  .selectedIndex]
                                                              .roomBooms[0]
                                                              .topContributors[
                                                                  0]
                                                              .name ??
                                                          "",
                                                      style: const TextStyle(
                                                        color:
                                                            ColorManager.white,
                                                      ),
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    10.wBox,
                                    Expanded(
                                      child: Container(
                                        color: ColorManager.transparent,
                                        height: 130.h,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              height: 110.h,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xff293663),
                                                    Color(0xff1a284f),
                                                    Color(0xff0b1433),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                border: const Border(
                                                  top: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  left: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  right: BorderSide(
                                                      color: ColorManager.white,
                                                      width: 0.3),
                                                  bottom: BorderSide.none,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(12.5.r),
                                                  topRight:
                                                      Radius.circular(12.5.r),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -20,
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ImageViewWidget(
                                                        url: (state
                                                                        .data
                                                                        ?.data[state
                                                                            .selectedIndex]
                                                                        .roomBooms[
                                                                            0]
                                                                        .topContributors
                                                                        .length ??
                                                                    0) >
                                                                2
                                                            ? state
                                                                    .data
                                                                    ?.data[state
                                                                        .selectedIndex]
                                                                    .roomBooms[
                                                                        0]
                                                                    .topContributors[
                                                                        2]
                                                                    .img ??
                                                                ""
                                                            : "",
                                                        boxFit: BoxFit.fill,
                                                        width: 70.w,
                                                        height: 70.h,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      Image.asset(
                                                        AssetsManager
                                                            .topThreeFrame,
                                                        width: 70.w,
                                                        height: 70.h,
                                                      ),
                                                    ],
                                                  ),
                                                  5.hBox,
                                                  if ((state
                                                              .data
                                                              ?.data[state
                                                                  .selectedIndex]
                                                              .roomBooms[0]
                                                              .topContributors
                                                              .length ??
                                                          0) >
                                                      2)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          state
                                                                  .data
                                                                  ?.data[state
                                                                      .selectedIndex]
                                                                  .roomBooms[0]
                                                                  .topContributors[
                                                                      2]
                                                                  .totalGift ??
                                                              "0",
                                                          style:
                                                              const TextStyle(
                                                            color: ColorManager
                                                                .agencyYellow,
                                                          ),
                                                        ),
                                                        5.wBox,
                                                        Image.asset(
                                                          AssetsManager.coin,
                                                          width: 20.w,
                                                          height: 20.h,
                                                        )
                                                      ],
                                                    ),
                                                  if ((state
                                                              .data
                                                              ?.data[state
                                                                  .selectedIndex]
                                                              .roomBooms[0]
                                                              .topContributors
                                                              .length ??
                                                          0) >
                                                      2)
                                                    SizedBox(
                                                      width: 120.w,
                                                      child: Text(
                                                        item
                                                            .roomBooms[0]
                                                            .topContributors[2]
                                                            .name,
                                                        style: const TextStyle(
                                                          color: ColorManager
                                                              .white,
                                                        ),
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ProgressWithImage extends StatelessWidget {
  final double progress;

  const ProgressWithImage({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.none,
      borderRadius: BorderRadius.circular(10),
      child: CustomProgressIndicator(
        progress: (progress.clamp(0, 100)) / 100,
        height: 13,
        backgroundColor: ColorManager.grey.withValues(alpha: 0.3),
        progressColor: ColorManager.yellow,
        indicator: Text(
          "💥",
          style: TextStyle(
            fontSize: 20.sp,
          ),
        ),
      ),
    );
  }
}
