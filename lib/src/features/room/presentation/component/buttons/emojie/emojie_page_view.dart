import 'dart:convert';
import 'dart:math';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_bloc.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_event.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_state.dart';
import 'package:general/src/features/room/room.dart';

class EmojiePageView extends StatefulWidget {
  final String userId;
  final String roomId;
  final int categoryId;

  static int index = 0;

  const EmojiePageView({
    required this.numberOfPages,
    required this.roomId,
    required this.userId,
    required this.categoryId,
    super.key,
  });

  final int numberOfPages;

  @override
  State<EmojiePageView> createState() => _EmojiePageViewState();
}

class _EmojiePageViewState extends State<EmojiePageView> {
  final ValueNotifier<int> _pageIndexNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmojieBloc, EmojieState>(
      bloc: di<EmojieBloc>(),
      buildWhen: (prev, curr) => prev.getReqStateById(widget.categoryId) != curr.getReqStateById(widget.categoryId) || prev.getEmojisById(widget.categoryId) != curr.getEmojisById(widget.categoryId) || prev.categories != curr.categories,
      builder: (context, state) {
        final reqState = state.getReqStateById(widget.categoryId);
        final emojis = state.getEmojisById(widget.categoryId);
        // final message = state.getMessageById(widget.categoryId);

        if (reqState == RequestState.error) {
          return Center(
            child: ErrorView(
              onTap: () {
                final category = state.categories.firstWhere(
                  (c) => c.id == widget.categoryId,
                );
                di<EmojieBloc>().add(
                  FetchEmojisByCategoryEvent(
                    categoryId: category.id,
                    typeId: category.id,
                  ),
                );
              },
            ),
          );
        } else if (reqState == RequestState.loading) {
          return const Center(child: LoadingView());
        } else if (reqState == RequestState.loaded) {
          if (emojis.isEmpty) {
            return Center(
              child: EmptyView(
                title: StringManager.noEmojis,
                subTitle: StringManager.noEmojisMsg,
                // Dark text (was ColorManager.white) — the emoji sheet's
                // background is white now, so white text here was invisible.
                titleStyle:
                    context.bodyMedium.colorExt(ColorManager.momentPostTextColor),
                subTitleStyle: context.bodySmall.colorExt(
                    ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
                onTap: () {
                  final category = state.categories.firstWhere(
                    (c) => c.id == widget.categoryId,
                  );
                  di<EmojieBloc>().add(
                    FetchEmojisByCategoryEvent(
                      categoryId: category.id,
                      typeId: category.id,
                    ),
                  );
                },
              ),
            );
          }

          int emojisPerPage = 15;

          List<List<EmojiEntity>> emojiPages = [];
          for (int i = 0; i < emojis.length; i += emojisPerPage) {
            int end = i + emojisPerPage;
            if (end > emojis.length) {
              end = emojis.length;
            }
            emojiPages.add(emojis.sublist(i, end));
          }

          return Column(
            children: [
              SizedBox(
                height: 250.h,
                child: PageView.builder(
                  itemCount: emojiPages.length,
                  onPageChanged: (value) => _pageIndexNotifier.value = value,
                  itemBuilder: (context, pageIndex) {
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      padding: context.paddingAll(0),
                      itemCount: pageIndex == 0 &&
                              ConstantsManager.isVariantBuildA &&
                              EmojiePageView.index == 0
                          ? emojiPages[pageIndex].length + 3
                          : emojiPages[pageIndex].length,
                      itemBuilder: (context, index) {
                        if (index == 0 &&
                            pageIndex == 0 &&
                            ConstantsManager.isVariantBuildA &&
                            EmojiePageView.index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(13),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                RoomData.instance.chatController?.sendMessage(
                                  "${Random().nextInt(9)},${Random().nextInt(9)},${Random().nextInt(9)}",
                                  userData: {
                                    StringManager.gameType:
                                        StringManager.luckyNumGame,
                                    "img": MyDataModel.getInstance()
                                            .profile
                                            ?.image ??
                                        "",
                                    "bu":
                                        MyDataModel.getInstance().bubble ?? "",
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
                                    "v": MyDataModel.getInstance()
                                            .vip1
                                            ?.img1 ??
                                        "",
                                    "c": MyDataModel.getInstance()
                                            .vip1
                                            ?.colorName ??
                                        "",
                                    'type': 'games',
                                  },
                                );
                              },
                              // Tint removed (was Colors.white) -- vanished
                              // on the sheet's white background; keeps its
                              // own artwork color, matching emojie_widget.dart.
                              child: Image.asset(
                                AssetsManager.number12,
                              ),
                            ),
                          );
                        }

                        if (index == 1 &&
                            pageIndex == 0 &&
                            ConstantsManager.isVariantBuildA &&
                            EmojiePageView.index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(13),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                RoomData.instance.chatController?.sendMessage(
                                  "${Random().nextInt(3)}",
                                  userData: {
                                    StringManager.gameType: StringManager.rps,
                                    "img": MyDataModel.getInstance()
                                            .profile
                                            ?.image ??
                                        "",
                                    "bu":
                                        MyDataModel.getInstance().bubble ?? "",
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
                                    "v": MyDataModel.getInstance()
                                            .vip1
                                            ?.img1 ??
                                        "",
                                    "c": MyDataModel.getInstance()
                                            .vip1
                                            ?.colorName ??
                                        "",
                                    'type': 'games',
                                  },
                                );
                              },
                              // Tint removed (was Colors.white) -- see note
                              // above on the Lucky Number icon.
                              child: Image.asset(
                                AssetsManager.rpsGameIcon,
                              ),
                            ),
                          );
                        }

                        if (index == 2 &&
                            pageIndex == 0 &&
                            ConstantsManager.isVariantBuildA &&
                            EmojiePageView.index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(13),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                RoomData.instance.chatController?.sendMessage(
                                  "${Random().nextInt(6)}",
                                  userData: {
                                    StringManager.gameType:
                                        StringManager.diceGame,
                                    "img": MyDataModel.getInstance()
                                            .profile
                                            ?.image ??
                                        "",
                                    "bu":
                                        MyDataModel.getInstance().bubble ?? "",
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
                                    "v": MyDataModel.getInstance()
                                            .vip1
                                            ?.img1 ??
                                        "",
                                    "c": MyDataModel.getInstance()
                                            .vip1
                                            ?.colorName ??
                                        "",
                                    'type': 'games',
                                  },
                                );
                              },
                              // Tint removed (was Colors.white) -- see note
                              // above on the Lucky Number icon.
                              child: Image.asset(
                                AssetsManager.dices,
                              ),
                            ),
                          );
                        }

                        final emoji = emojiPages[pageIndex][pageIndex == 0 &&
                                ConstantsManager.isVariantBuildA &&
                                EmojiePageView.index == 0
                            ? index - 3
                            : index];

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);

                            EmojieController().showingEmojie(
                              userId: widget.userId,
                              emojieData: EmojieData(
                                emojie: emoji.emoji,
                                emojieId: emoji.id,
                                length: emoji.tLength,
                                type: emoji.type,
                              ),
                              timeEmojie: emoji.tLength,
                            );

                            sendRoomData(
                              data: jsonDecode(getMessagaRealTime(
                                emoji.id,
                                emoji.emoji,
                                emoji.tLength,
                                widget.userId,
                                emoji.type,
                              )),
                            );
                          },
                          child: Padding(
                            padding: context.paddingAll(10),
                            // The grid preview must stay a still picture (like
                            // the gift picker) -- only the seat overlay plays
                            // the actual animation once an emoji is sent.
                            // vap/alpha/mp4 have no static-frame renderer yet,
                            // so those keep their live preview for now.
                            child: emoji.type == "vap"
                                ? CachedVapWidget(url: emoji.emoji)
                                : emoji.type == "alpha"
                                    ? CacheAlphaWidget(url: emoji.emoji)
                                    : emoji.type == "mp4"
                                        ? CacheVideoWidget(
                                            videoUrl: emoji.emoji,
                                          )
                                        : emoji.showImg
                                                .toLowerCase()
                                                .endsWith('.svga')
                                            ? CacheSvgaWidget(
                                                url: EndPoints.getImage(
                                                    emoji.showImg),
                                                autoPlay: false,
                                              )
                                            : ImageViewWidget(
                                                url: emoji.showImg,
                                                boxFit: BoxFit.contain,
                                              ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (emojiPages.length > 1)
                ValueListenableBuilder<int>(
                  valueListenable: _pageIndexNotifier,
                  builder: (context, currentPage, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(emojiPages.length, (index) {
                        return Container(
                          margin: context.paddingSymmetric(horizontal: 4.0),
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? ColorManager.white
                                : ColorManager.lightGray2,
                          ),
                        );
                      }),
                    );
                  },
                )
            ],
          );
        } else {
          // Initial/unknown state: show a clean localized empty message
          // instead of a bare blank box on the black sheet.
          final hasCategory =
              state.categories.any((c) => c.id == widget.categoryId);
          return Center(
            child: EmptyView(
              title: StringManager.noEmojis,
              subTitle: StringManager.noEmojisMsg,
              // Dark text (was ColorManager.white, invisible on the sheet's
              // white background — same fix as the branch above).
              titleStyle:
                  context.bodyMedium.colorExt(ColorManager.momentPostTextColor),
              subTitleStyle: context.bodySmall.colorExt(
                  ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
              onTap: hasCategory
                  ? () {
                      di<EmojieBloc>().add(
                        FetchEmojisByCategoryEvent(
                          categoryId: widget.categoryId,
                          typeId: widget.categoryId,
                        ),
                      );
                    }
                  : null,
            ),
          );
        }
      },
    );
  }

  String getMessagaRealTime(
    int idEmojie,
    String emojie,
    int lenght,
    String userId,
    String type,
  ) {
    var mapInformation = {
      "messageContent": {
        "message": "showEmojie",
        "id": idEmojie,
        "emoji": emojie,
        "t_length": lenght,
        "id_user": userId,
        "type": type,
      }
    };
    String map = jsonEncode(mapInformation);
    return map;
  }
}
