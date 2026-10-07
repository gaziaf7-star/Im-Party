import 'dart:convert';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/text_sanitizer.dart';
import 'package:general/src/core/services/bad_words_manager.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/room/presentation/component/games/free_games/dice_game_body.dart';
import 'package:general/src/features/room/presentation/component/games/free_games/lucky_number_game_body.dart';
import 'package:general/src/features/room/presentation/component/games/free_games/rps_game_body.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_box_view.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_box_winner_view.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_gift_winner_view.dart';
import 'package:general/src/features/room/presentation/component/messages/gift_comment_body.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/component/messages/messages_button/input_board.dart';

class MessagesView extends StatefulWidget {
  final UTDChatMessage? message;

  const MessagesView({
    super.key,
    required this.message,
  });

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  static final Map<int, BubblePadding?> _bubbleCache = {};
  static bool _bubbleFullyParsed = false;

  BubblePadding? findBubblePaddingById(int bubbleId) {
    if (_bubbleCache.containsKey(bubbleId)) {
      return _bubbleCache[bubbleId];
    }

    if (!_bubbleFullyParsed) {
      final cachedJson = HiveManager().getData<String>(
        KeysManager.BUBBLE_PADDING_BOX,
        KeysManager.BUBBLE_PADDING_KEY,
      );
      final parsedMap = _parseBubbleMapFromJson(cachedJson);
      _bubbleCache.addAll(parsedMap.map((k, v) => MapEntry(k, v)));
      _bubbleFullyParsed = true;
    }

    return _bubbleCache[bubbleId];
  }

  static Map<int, BubblePadding> _parseBubbleMapFromJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return {};
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final list = decoded
          .map((e) => BubblePadding.fromJson(e as Map<String, dynamic>))
          .toList();
      return {for (final element in list) element.id: element};
    } catch (error) {
      Methods.printLog('❌ Failed to decode cache: $error');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final attrs = widget.message?.userData ?? {};
    return _buildCommentBody(
      context,
      attrs,
      Methods.safeHexColor(attrs["c"]?.toString() ?? "") ?? ColorManager.white,
      padding:
      findBubblePaddingById(int.parse(attrs["buId"]?.toString() ?? "-1"))
          ?.edgeInsets,
      // Slightly larger room comment text on request.
      fontSize: ConstantsManager.isVariantBuildA ? 16 : 15,
    );
  }

  static final RegExp _arabicGiftExtractPattern = RegExp(
      r'^(\d+)\s*x\s*ارسل هدية\s*قيمتها\s*(\d+)\s*الى\s*(.+)$',
      caseSensitive: false);
  static final RegExp _englishGiftExtractPattern = RegExp(
      r'^(\d+)\s*x\s*Send a gift\s*its value\s*(\d+)\s*to\s*(.+)$',
      caseSensitive: false);
  final RegExp _arabicGiftCheckPattern = RegExp(r'ارسل هدية\s+قيمتها');
  final RegExp _englishGiftCheckPattern = RegExp(r'Send a gift its value');

  Map<String, dynamic> extractGiftInfo(String text) {
    final normalizedText = text.trim();

    final match = _arabicGiftExtractPattern.firstMatch(normalizedText);
    if (match != null) {
      return {
        'count': int.parse(match.group(1)?.trim() ?? "0"),
        'price': int.parse(match.group(2)?.trim() ?? "0"),
        'name': match.group(3)?.trim(),
        'lang': 'ar',
      };
    }

    final matchEn = _englishGiftExtractPattern.firstMatch(normalizedText);
    if (matchEn != null) {
      return {
        'count': int.parse(matchEn.group(1)?.trim() ?? "0"),
        'price': int.parse(matchEn.group(2)?.trim() ?? "0"),
        'name': matchEn.group(3)?.trim(),
        'lang': 'en',
      };
    }

    return {};
  }

  String formatMessage(UTDChatMessage? message) {
    final rawMessage = message?.text;
    if (rawMessage == null || rawMessage.isEmpty) return '';

    if (rawMessage.contains('BeAdMiN')) {
      final lang = Methods.getLang();
      if (lang == 'en') {
        return rawMessage.replaceAll('BeAdMiN', 'set as administrator');
      } else if (lang == 'ar') {
        return rawMessage.replaceAll('BeAdMiN', ' اصبح مشرفا ');
      } else if (lang == 'tr') {
        return rawMessage.replaceAll('BeAdMiN', 'Bir süpervizör ol');
      } else if (lang == 'ur') {
        return rawMessage.replaceAll('BeAdMiN', 'سپروائزر بنیں۔');
      } else {
        return rawMessage.replaceAll('BeAdMiN', 'पर्यवेक्षक बनें');
      }
    }
    if (rawMessage.contains('removedFromAdmins')) {
      final lang = Methods.getLang();
      if (lang == 'en') {
        return rawMessage.replaceAll(
            'removedFromAdmins', 'removed as administrator');
      } else if (lang == 'ar') {
        return rawMessage.replaceAll(
            'removedFromAdmins', ' محذوف من المشرفين ');
      } else if (lang == 'tr') {
        return rawMessage.replaceAll(
            'removedFromAdmins', 'Yönetici olarak kaldırıldı');
      } else if (lang == 'ur') {
        return rawMessage.replaceAll(
            'removedFromAdmins', 'منتظم کے طور پر ہٹا دیا گیا');
      } else {
        return rawMessage.replaceAll(
            'removedFromAdmins', 'प्रशासक के रूप में हटाया गया');
      }
    }

    if (_arabicGiftCheckPattern.hasMatch(rawMessage) ||
        _englishGiftCheckPattern.hasMatch(rawMessage)) {
      final giftData = extractGiftInfo(rawMessage);
      if (giftData.isEmpty) return rawMessage;

      final lang = Methods.getLang();
      if (lang == 'en') {
        return '${giftData['count']} x Send a gift its value ${giftData['price']} to ${giftData['name']}';
      } else if (lang == 'ar') {
        return '${giftData['count']} x ارسل هدية قيمتها ${giftData['price']} إلى ${giftData['name']}';
      } else if (lang == 'tr') {
        return '${giftData['count']} x ${giftData['name']} kişisine değeri ${giftData['price']} olan bir hediye gönder';
      } else if (lang == 'ur') {
        return '${giftData['count']} x ${giftData['name']} کو ${giftData['price']} مالیت کا تحفہ بھیجیں';
      } else {
        return '${giftData['count']} x ${giftData['name']} को ${giftData['price']} मूल्य का उपहार भेजें';
      }
    }
    return BadWordsManager.instance.filterMessage(rawMessage);
  }

  int estimateLineCountByFixedCharLine(String text) {
    const int charsPerLine = 20;
    final int totalChars = text.length;
    final int lines = (totalChars / charsPerLine).ceil();

    if (totalChars % charsPerLine == 0 && totalChars != 0) {
      return lines + 1;
    }
    if (lines <= 1) return 1;

    return lines;
  }

  Padding _buildCommentBody(
      BuildContext context,
      Map<String, dynamic> value,
      Color getNameColor, {
        EdgeInsets? padding,
        required double fontSize,
      }) {
    // A picture message: the chat channel carries text, so the URL is the
    // message and userData tags it. Checked FIRST -- every branch below tests
    // the text against a keyword, and a URL would fall through all of them to
    // the plain-text tail and render as a raw link.
    if (value['type']?.toString() == 'image') {
      return Padding(
        padding: context.paddingAll(5),
        child: _RoomChatImage(
          url: (value['image'] ?? widget.message?.text ?? '').toString(),
          senderName: widget.message?.senderName ?? '',
          nameColor: getNameColor,
          fontSize: fontSize,
        ),
      );
    }

    return Padding(
      padding: context.paddingAll(5),
      child: widget.message?.text.contains("joinRoom") ?? false
          ? Container(
        padding: context.paddingAll(5),
        // Light-black card (was a light-white D9D9D9 tint) for the
        // "X entered the room" line, on request.
        decoration: BoxDecoration(
          borderRadius: 4.radius,
          color: Colors.black.withValues(alpha: 0.25),
        ),
        child: Text.rich(
          _textStyle(
            "${(widget.message?.senderName ?? "").sanitizedForDisplay} ${StringManager.enterTheRoom.tr()}",
            mentionStyle: context.bodyMedium
                .size(fontSize)
                .colorExt(ColorManager.primary),
            defaultStyle: context.bodyMedium
                .size(fontSize)
                .colorExt(ColorManager.white),
          ),
        ),
      )
          : widget.message?.text == StringManager.winInLuckyBoxMessageKey
          ? LuckyBoxWinnerView(
        name: widget.message?.senderName ?? "",
        coins: widget.message?.userData['coins']?.toString() ?? "0",
        fontSize: fontSize,
      )
          : widget.message?.text == StringManager.sendBoxMessageKey
          ? LuckyBoxView(
        data: widget.message?.attributes ?? {},
        name: widget.message?.senderName ?? "",
        fontSize: fontSize,
      )
          : widget.message?.text == "lucky_gift_winner"
          ? LuckyGiftWinnerView(
        data: widget.message?.attributes ?? {},
        fontSize: fontSize,
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              String name = (widget.message?.senderName ?? "")
                  .replaceAll(" ", "_");
              Navigator.of(context).push(
                AudioRoomInRoomMessageInputBoard(
                  mention: "@$name",
                ),
              );
            },
            child: CacheImageWidget(
              url: value['img']?.toString() ?? "",
              height: 30.h,
              width: 30.w,
              shape: BoxShape.circle,
              // Avatar context: a missing/failed sender image
              // falls back to their initials, never the logo.
              displayName: widget.message?.senderName ?? "",
            ),
          ),
          7.5.wBox,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    GradientTextVip(
                      width: 110.w,
                      isVip: widget.message?.userData["c"] !=
                          null &&
                          (widget.message?.userData["c"]
                              ?.toString() ??
                              '')
                              .startsWith('#'),
                      text: (widget.message?.senderName ?? "")
                          .sanitizedForDisplay,
                      color: getNameColor,
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      textAlign: TextAlign.center,
                      textStyle: context.bodyMedium.w500
                          .size(fontSize + 1)
                          .colorExt(getNameColor),
                    ),
                    3.hBox,
                    // Row 1: level images + special ID badge.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          if (value["rL"] != "")
                            LevelContainer(
                              image: value['rL'] ?? "",
                              isComment: true,
                              width: 42.w,
                              height: 30.h,
                            ),
                          if (value["sL"] != "") 5.wBox,
                          if (value["sL"] != "")
                            LevelContainer(
                              image: value["sL"] ?? "",
                              isComment: true,
                              width: 42.w,
                              height: 30.h,
                            ),
                          if (value["sI"] != null &&
                              value["sI"].toString().isNotEmpty) ...[
                            5.wBox,
                            ImageViewWidget(
                              url: value["sI"].toString(),
                              boxFit: BoxFit.contain,
                              height: 32.h,
                              width: 55.w,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Row 2: SVIP + all other (admin) badges, in the same
                    // order they appear on the profile page.
                    if (value["v"] != "" ||
                        ((value["bT"] as List?) ?? [])
                            .any((b) => (b?.toString() ?? "").isNotEmpty)) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            if (value["v"] != "")
                              VipContainer(
                                vip: value["v"] ?? "",
                                width: 42.w,
                                height: 20.h,
                              ),
                            for (final badge
                            in (value["bT"] as List?) ?? [])
                              if (badge != null &&
                                  badge.toString().isNotEmpty)
                                Padding(
                                  padding:
                                  context.paddingOnly(start: 5),
                                  child: ImageViewWidget(
                                    url: badge.toString(),
                                    boxFit: BoxFit.contain,
                                    height: 32.h,
                                    width: 50.w,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                    // Row 3: achievement medals, separate row above the
                    // chat bubble, matching the profile page.
                    if (((value["aI"] as List?) ?? [])
                        .any((m) => (m?.toString() ?? "").isNotEmpty)) ...[
                      3.hBox,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final medal
                            in (value["aI"] as List?) ?? [])
                              if (medal != null &&
                                  medal.toString().isNotEmpty)
                                Padding(
                                  padding:
                                  context.paddingOnly(end: 4),
                                  child: CacheImageWidget(
                                    url: medal.toString(),
                                    height: 15.h,
                                    width: 15.w,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                value["bu"] == null || value["bu"] == ""
                    ? Container(
                  // Wider + taller default comment bubble, on request
                  // (height increased a second time per follow-up request).
                  constraints: BoxConstraints(
                    minHeight: 56.h,
                  ),
                  // CP-tabbar-style card: solid gradient fill + thicker gold
                  // border, on request (was too faint/transparent before).
                  decoration: BoxDecoration(
                    // borderRadius: 6.radius,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFF8BB5),
                        Color(0xFF3B1E6B)],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFD98A),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    // Matches the "X entered the room" entry card's padding
                    // on request, so every no-bubble comment card (text,
                    // gift, game) reads consistently.
                    padding: context.paddingAll(5),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMessageBody(
                          context,
                          fontSize,
                        ),
                      ],
                    ),
                  ),
                )
                    : ImageViewWidget(
                  url: value["bu"] ?? "",
                  // Widened further, on request.
                  width: ScreenUtil().screenWidth + 10.w,
                  boxFit: BoxFit.fill,
                  isBubble: true,
                  isFromRoom: true,
                  child: Padding(
                    // The container has no explicit height of its own (it
                    // shrink-wraps this padding's content), so a small bump
                    // to top/bottom here is what makes the bubble artwork
                    // read a little taller, on request.
                    padding: padding != null
                    // Keep server-authored bubble padding, but add a gap on
                    // every side around the text (was missing on the right).
                        ? EdgeInsetsDirectional.only(
                      top: padding.top + 16,
                      bottom: padding.bottom + 16,
                      start: padding.left + 3,
                      end: padding.right + 4,
                    )
                        : context.paddingOnly(
                      end: 15,
                      start: 24,
                      bottom: 20,
                      top: 26,
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildMessageBody(
                          context,
                          fontSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBody(
      BuildContext context,
      double fontSize,
      ) {
    if (widget.message?.text.contains("joinRoom") ?? false) {
      return Padding(
        padding: EdgeInsets.only(left: 8.w, right: 8.w),
        child: Text.rich(
          _textStyle(
            "${(widget.message?.senderName ?? "").sanitizedForDisplay} ${StringManager.enterTheRoom.tr()}",
            mentionStyle: context.bodyMedium
                .size(fontSize)
                .colorExt(ColorManager.primary),
            defaultStyle:
            context.bodyMedium.size(fontSize).colorExt(ColorManager.white),
          ),
        ),
      );
    } else if (widget.message?.attributes['gameType'] == "Lucky Number") {
      return Padding(
        padding: context.paddingAll(5),
        child: LuckyNumberGameBody(
          key: ValueKey('lucky_${widget.message?.messageID ?? ''}'),
          randomNum: widget.message?.text ?? "",
        ),
      );
    } else if (widget.message?.attributes['gameType'] == "Dice") {
      return DiceGameBody(
        key: ValueKey('dice_${widget.message?.messageID ?? ''}'),
        randomNum: int.parse(widget.message?.text ?? "0"),
      );
    } else if (widget.message?.attributes['gameType'] == "RPS") {
      return RockPaperScissorsGameBody(
        key: ValueKey('rps_${widget.message?.messageID ?? ''}'),
        randomNum: int.parse(widget.message?.text ?? "0"),
      );
    } else if (widget.message?.attributes['gameType'] == "GameWin") {
      // Third-party game win (Fruit77/Slot777/...), shown in the "Games" tab
      // the same way a normal gift shows a card in the "Gift" tab: message
      // text next to the game's icon, via the shared GiftCommentBody.
      final text = Text.rich(
        _textStyle(
          formatMessage(widget.message).sanitizedForDisplay,
          mentionStyle: context.bodyMedium
              .size(fontSize)
              .colorExt(ColorManager.primary),
          defaultStyle:
          context.bodyMedium.size(fontSize).colorExt(ColorManager.white),
        ),
      );
      final gameImage = widget.message?.userData['gameImage']?.toString() ?? '';
      return Padding(
        padding: context.paddingAll(5),
        child: gameImage.isEmpty
            ? text
            : GiftCommentBody(text: text, giftImage: gameImage),
      );
    } else {
      final text = Text.rich(
        _textStyle(
          formatMessage(widget.message).sanitizedForDisplay,
          mentionStyle: context.bodyMedium
              .size(fontSize)
              .colorExt(ColorManager.primary),
          defaultStyle:
          context.bodyMedium.size(fontSize).colorExt(ColorManager.white),
        ),
      );
      final giftImage = widget.message?.userData['giftImage']?.toString() ?? '';
      final body = giftImage.isEmpty
          ? text
          : GiftCommentBody(text: text, giftImage: giftImage);
      return Padding(
        padding: context.paddingAll(15),
        child: GestureDetector(
          onLongPress: () {
            Clipboard.setData(
              ClipboardData(
                text: formatMessage(widget.message).sanitizedForDisplay,
              ),
            );
            Methods.showToast(
              context,
              message: StringManager.theTextHasBeenCopied.tr(),
            );
          },
          child: body,
        ),
      );
    }
  }

  TextSpan _textStyle(
      String text, {
        required TextStyle mentionStyle,
        required TextStyle defaultStyle,
      }) {
    final mentionRegex = RegExp(r'@\w+');
    final spans = <TextSpan>[];

    text.splitMapJoin(
      mentionRegex,
      onMatch: (match) {
        spans.add(TextSpan(
          text: match[0],
          style: mentionStyle,
        ));
        return '';
      },
      onNonMatch: (nonMatch) {
        spans.add(
          TextSpan(
            text: nonMatch,
            style: defaultStyle,
          ),
        );
        return '';
      },
    );

    return TextSpan(children: spans);
  }
}

/// One picture in the room chat: the sender's name, then the image itself.
///
/// Capped rather than free-sized: the chat column is narrow and a tall photo
/// would push every other message off screen. Tapping opens it full size.
class _RoomChatImage extends StatelessWidget {
  const _RoomChatImage({
    required this.url,
    required this.senderName,
    required this.nameColor,
    required this.fontSize,
  });

  final String url;
  final String senderName;
  final Color nameColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (senderName.isNotEmpty)
          Text(
            senderName.sanitizedForDisplay,
            style: context.bodyMedium.size(fontSize).colorExt(nameColor),
          ),
        4.hBox,
        // Tapping the picture opens it full screen. The GestureDetector sits
        // on the image so the tap never reaches the message row (which opens
        // the sender's profile).
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showFullScreenImage(context, url),
          child: ClipRRect(
            borderRadius: 8.radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 180.w,
                maxHeight: 180.w,
              ),
              child: ImageViewWidget(
                url: url,
                boxFit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-screen viewer: pinch to zoom, tap anywhere or the close button to exit.
void _showFullScreenImage(BuildContext context, String url) {
  if (url.isEmpty) return;
  showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (dialogContext, _, __) {
      return Material(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(dialogContext).pop(),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: ImageViewWidget(url: url, boxFit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
