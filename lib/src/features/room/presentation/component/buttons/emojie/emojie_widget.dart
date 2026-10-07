import 'dart:math';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/GradientLoader.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/features/room/presentation/component/buttons/emojie/emojie_page_view.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_bloc.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_event.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_state.dart';
import 'package:general/src/features/room/room.dart';

class EmojieWidget extends StatefulWidget {
  final String userId;
  final String roomId;

  const EmojieWidget({
    required this.roomId,
    required this.userId,
    super.key,
  });

  @override
  State<EmojieWidget> createState() => _EmojieWidgetState();
}

class _EmojieWidgetState extends State<EmojieWidget>
    with TickerProviderStateMixin {
  late TabController? emojiController;

  @override
  void initState() {
    super.initState();

    // Fetch emoji categories first
    if (!di<EmojieBloc>().state.reqStateEmojisCategory.isLoaded) {
      di<EmojieBloc>().add(const FetchEmojisCategoryEvent());
    }

    _initializeTabController();
  }

  void _initializeTabController() {
    final state = di<EmojieBloc>().state;

    if (state.categories.isEmpty) {
      emojiController = null;
      return;
    }

    final tabLength = state.categories.length;
    emojiController = TabController(length: tabLength, vsync: this);

    emojiController?.addListener(() {
      EmojiePageView.index = emojiController?.index ?? 0;
      final index = emojiController?.index ?? 0;
      final state = di<EmojieBloc>().state;

      if (index < state.categories.length) {
        final category = state.categories[index];

        // Fetch emojis if not loaded
        if (state.getReqStateById(category.id) != RequestState.loaded) {
          di<EmojieBloc>().add(
            FetchEmojisByCategoryEvent(
              categoryId: category.id,
              typeId: category.id,
            ),
          );
        }
      }
    });

    // Eagerly fetch every category's emojis up front (was: only the first
    // tab) so the tab bar can show each category's own first emoji as its
    // tab image immediately, on request, instead of a plain text label
    // that would otherwise sit empty until that tab is opened.
    for (final category in state.categories) {
      if (state.getReqStateById(category.id) != RequestState.loaded) {
        di<EmojieBloc>().add(
          FetchEmojisByCategoryEvent(
            categoryId: category.id,
            typeId: category.id,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emojiController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmojieBloc, EmojieState>(
      bloc: di<EmojieBloc>(),
      listener: (context, state) {
        // Re-initialize tab controller when categories are loaded
        if (state.reqStateEmojisCategory == RequestState.loaded &&
            (emojiController == null || emojiController!.length == 0)) {
          setState(() {
            _initializeTabController();
          });
        }
      },
      builder: (context, state) {
        if (state.reqStateEmojisCategory == RequestState.loading) {
          // A centered gradient spinner (was a blank white box with no
          // feedback at all) — the sheet still has to wait on the network,
          // but a bare white box read as "stuck/slow"; showing immediate
          // progress makes the same wait feel fast.
          return Container(
            height: 342.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.r),
                topLeft: Radius.circular(15.r),
              ),
            ),
            child: Center(child: GradientLoader(size: 34.h)),
          );
        }

        if (state.reqStateEmojisCategory == RequestState.error) {
          return Container(
            height: 345.h,
            // White sheet background (was ColorManager.black), on request.
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.r),
                topLeft: Radius.circular(15.r),
              ),
            ),
            child: Center(
              child: ErrorView(
                onTap: () =>
                    di<EmojieBloc>().add(const FetchEmojisCategoryEvent()),
              ),
            ),
          );
        }

        final isOnSeat = (RoomData.instance.utdController?.seatController
            .isUserOnSeat(widget.userId) ??
            false) ||
            di<RoomStateManager>().isInVideoRoom;

        final showEmojiTabs = state.categories.isNotEmpty &&
            emojiController != null &&
            isOnSeat;
        final showAltGames = ConstantsManager.isVariantBuildA && !isOnSeat;

        // When neither the emoji tabs nor the games row will render, the
        // sheet would otherwise be a bare black box. Show a clean localized
        // empty/unavailable state (light text on the black sheet) instead.
        if (!showEmojiTabs && !showAltGames) {
          return Container(
            height: 345.h,
            // White sheet background (was ColorManager.black), on request.
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.r),
                topLeft: Radius.circular(15.r),
              ),
            ),
            child: Center(
              child: EmptyView(
                title: StringManager.noEmojis,
                subTitle: StringManager.noEmojisMsg,
                // Dark text (was white) now that the sheet is white.
                titleStyle: context.bodyMedium.colorExt(Colors.black87),
                subTitleStyle:
                context.bodySmall.colorExt(Colors.black54),
                onTap: () => di<EmojieBloc>()
                    .add(const FetchEmojisCategoryEvent()),
              ),
            ),
          );
        }

        return Container(
          height: showAltGames ? 100.h : 345.h,
          // White sheet background (was ColorManager.black), on request.
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15.r),
              topLeft: Radius.circular(15.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ConstantsManager.isVariantBuildA && !isOnSeat)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          RoomData.instance.chatController?.sendMessage(
                            "${Random().nextInt(9)},${Random().nextInt(9)},${Random().nextInt(9)}",
                            userData: {
                              StringManager.gameType:
                              StringManager.luckyNumGame,
                              "img":
                              MyDataModel.getInstance().profile?.image ??
                                  "",
                              "bu": MyDataModel.getInstance().bubble ?? "",
                              "buId": MyDataModel.getInstance()
                                  .bubbleId
                                  .toString(),
                              "sL": MyDataModel.getInstance()
                                  .level
                                  ?.senderImage ??
                                  "",
                              "rL": MyDataModel.getInstance()
                                  .level
                                  ?.receiverImage ??
                                  "",
                              "v": MyDataModel.getInstance().vip1?.img1 ?? "",
                              "c":
                              MyDataModel.getInstance().vip1?.colorName ??
                                  "",
                              'type': 'games',
                            },
                          );
                        },
                        child: Image.asset(
                          AssetsManager.number12,
                          // Tint removed (was Colors.white) -- the icon
                          // would vanish on the sheet's new white
                          // background, so it now keeps its own artwork
                          // color.
                          width: 35.w,
                        ),
                      ),
                      20.wBox,
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          RoomData.instance.chatController?.sendMessage(
                            "${Random().nextInt(3)}",
                            userData: {
                              StringManager.gameType: StringManager.rps,
                              "img":
                              MyDataModel.getInstance().profile?.image ??
                                  "",
                              "bu": MyDataModel.getInstance().bubble ?? "",
                              "buId": MyDataModel.getInstance()
                                  .bubbleId
                                  .toString(),
                              "sL": MyDataModel.getInstance()
                                  .level
                                  ?.senderImage ??
                                  "",
                              "rL": MyDataModel.getInstance()
                                  .level
                                  ?.receiverImage ??
                                  "",
                              "v": MyDataModel.getInstance().vip1?.img1 ?? "",
                              "c":
                              MyDataModel.getInstance().vip1?.colorName ??
                                  "",
                              'type': 'games',
                            },
                          );
                        },
                        child: Image.asset(
                          AssetsManager.rpsGameIcon,
                          // Tint removed (was Colors.white) -- see note
                          // above on the Lucky Number icon.
                          width: 35.w,
                        ),
                      ),
                      20.wBox,
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          RoomData.instance.chatController?.sendMessage(
                            "${Random().nextInt(6)}",
                            userData: {
                              StringManager.gameType: StringManager.diceGame,
                              "img":
                              MyDataModel.getInstance().profile?.image ??
                                  "",
                              "bu": MyDataModel.getInstance().bubble ?? "",
                              "buId": MyDataModel.getInstance()
                                  .bubbleId
                                  .toString(),
                              "sL": MyDataModel.getInstance()
                                  .level
                                  ?.senderImage ??
                                  "",
                              "rL": MyDataModel.getInstance()
                                  .level
                                  ?.receiverImage ??
                                  "",
                              "v": MyDataModel.getInstance().vip1?.img1 ?? "",
                              "c":
                              MyDataModel.getInstance().vip1?.colorName ??
                                  "",
                              'type': 'games',
                            },
                          );
                        },
                        child: Image.asset(
                          AssetsManager.dices,
                          // Tint removed (was Colors.white) -- see note
                          // above on the Lucky Number icon.
                          width: 35.w,
                        ),
                      ),
                    ],
                  ),
                ),

              // Tabs
              if (state.categories.isNotEmpty &&
                  emojiController != null &&
                  isOnSeat)
                Padding(
                  padding: context.paddingOnly(start: 20, top: 20, bottom: 10),
                  child: TabBar(
                    controller: emojiController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerHeight: 0,
                    indicatorWeight: 0,
                    indicatorPadding: context.paddingSymmetric(vertical: 2.0),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: context.bodyMedium.w600
                        .colorExt(ColorManager.buttonTextColor)
                        .size(14),
                    unselectedLabelStyle: context.bodyMedium
                        .colorExt(ColorManager.lightGray2)
                        .size(14),
                    // Brand gradient pill (was flat ColorManager.primary) for
                    // the selected category, matching the premium look used
                    // across the app.
                    indicator: BoxDecoration(
                      gradient: ColorManager.brandGradient,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(6.r),
                        left: Radius.circular(6.r),
                      ),
                    ),
                    labelPadding: context.paddingSymmetric(horizontal: 10),
                    // Each tab now shows that category's own first emoji as
                    // its image (was plain text), on request, so the tab
                    // strip reads like a row of small emoji/sticker
                    // previews instead of category names. Falls back to a
                    // tiny spinner for the brief moment before that
                    // category's own emojis have loaded.
                    tabs: state.categories.map((category) {
                      final categoryEmojis = state.getEmojisById(category.id);
                      return Tab(
                        height: 34.h,
                        child: categoryEmojis.isNotEmpty
                            ? _CategoryTabIcon(emoji: categoryEmojis.first)
                            : SizedBox(
                          width: 26.w,
                          height: 26.w,
                          child: Center(
                            child: SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: ColorManager.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Tab Views
              if (state.categories.isNotEmpty &&
                  emojiController != null &&
                  isOnSeat)
                Expanded(
                  child: TabBarView(
                    controller: emojiController,
                    children: state.categories.map((category) {
                      return EmojiePageView(
                        numberOfPages: 1,
                        userId: widget.userId,
                        roomId: widget.roomId,
                        categoryId: category.id,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Small tab-strip preview image for one emoji category -- shows that
/// category's own first emoji (whatever its underlying type is), sized to
/// fit inside the tab bar, on request ("tabbar a ja type ar emoni oi emoji
/// ar fast ta thakba image ar moto"). Mirrors the exact type switch used
/// for the full-size grid tiles in emojie_page_view.dart so the small
/// preview and the full tile render identically for the same asset type.
class _CategoryTabIcon extends StatelessWidget {
  const _CategoryTabIcon({required this.emoji});

  final EmojiEntity emoji;

  @override
  Widget build(BuildContext context) {
    final Widget preview = emoji.type == "svga"
        ? CacheSvgaWidget(url: EndPoints.getImage(emoji.emoji))
        : emoji.type == "vap"
        ? CachedVapWidget(url: emoji.emoji)
        : emoji.type == "alpha"
        ? CacheAlphaWidget(url: emoji.emoji)
        : emoji.type == "mp4"
        ? CacheVideoWidget(videoUrl: emoji.emoji)
        : ImageViewWidget(
      url: emoji.emoji,
      boxFit: BoxFit.contain,
    );

    return SizedBox(
      width: 26.w,
      height: 26.w,
      child: preview,
    );
  }
}