import 'dart:convert';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/services/bad_words_manager.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/live_room/presentation/component/messages/messages_button/live_input_board.dart';
import 'package:general/src/features/room/presentation/component/games/free_games/dice_game_body.dart';
import 'package:general/src/features/room/presentation/component/games/free_games/lucky_number_game_body.dart';
import 'package:general/src/features/room/presentation/component/games/free_games/rps_game_body.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_box_view.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_box_winner_view.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_gift_winner_view.dart';
import 'package:general/src/features/room/presentation/component/messages/gift_comment_body.dart';
import 'package:general/src/features/room/room.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// The live room's single-message renderer — a fork of the audio room's
/// `MessagesView`, typed against the LIVE kit's [live.UTDChatMessage] (the two
/// kits expose structurally identical but distinct chat types). Rendering is
/// identical; only the message type and the long-press mention input board
/// (which sends through the live chat channel) differ. The lucky-box / lucky-gift
/// views and inline game bodies are reused as-is — they take maps/strings, not
/// the kit type.
class LiveMessagesView extends StatefulWidget {
  final live.UTDChatMessage? message;

  /// Multiplies the message font size — the tabbed list's enlarge mode uses it
  /// so a host far from the phone can still read the chat.
  final double fontScale;

  const LiveMessagesView({
    super.key,
    required this.message,
    this.fontScale = 1.0,
  });

  @override
  State<LiveMessagesView> createState() => _LiveMessagesViewState();
}

class _LiveMessagesViewState extends State<LiveMessagesView> {
  static final Map<int, BubblePadding?> _bubbleCache = {};
  static bool _bubbleFullyParsed = false;

  /// The bad-words–filtered / translated message text, computed once per message
  /// (a chat line's text never changes after arrival) instead of on every
  /// rebuild. [formatMessage] loops every compiled bad-word regex via replaceAll,
  /// the dominant per-row build cost when a new message rebuilds the visible list.
  String _formattedText = '';

  @override
  void initState() {
    super.initState();
    _formattedText = formatMessage(widget.message);
  }

  @override
  void didUpdateWidget(covariant LiveMessagesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message?.messageID != widget.message?.messageID ||
        oldWidget.message?.text != widget.message?.text) {
      _formattedText = formatMessage(widget.message);
    }
  }

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
      fontSize:
          (ConstantsManager.isVariantBuildA ? 16 : 15) * widget.fontScale,
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

  String formatMessage(live.UTDChatMessage? message) {
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

    // First tap-heart of a viewer's session (owner spec 2026-06-12): one
    // chat line "«فلان» أحب هذا البث ❤️" — sent ONCE by LiveTapsController;
    // every later tap is hearts only.
    if (rawMessage.contains('likedLive')) {
      final lang = Methods.getLang();
      if (lang == 'en') {
        return rawMessage.replaceAll('likedLive', 'liked this live ❤️');
      } else if (lang == 'ar') {
        return rawMessage.replaceAll('likedLive', ' أحب هذا البث ❤️');
      } else if (lang == 'tr') {
        return rawMessage.replaceAll('likedLive', 'bu yayını beğendi ❤️');
      } else if (lang == 'ur') {
        return rawMessage.replaceAll('likedLive', 'نے اس لائیو کو پسند کیا ❤️');
      } else {
        return rawMessage.replaceAll('likedLive', 'ने इस लाइव को पसंद किया ❤️');
      }
    }
    // A viewer shared the broadcast (owner spec 2026-06-12): distinctive
    // line with the share emoji so it reads as a share, not a plain comment.
    if (rawMessage.contains('sharedLive')) {
      final lang = Methods.getLang();
      if (lang == 'en') {
        return rawMessage.replaceAll('sharedLive', 'shared this live 📤✨');
      } else if (lang == 'ar') {
        return rawMessage.replaceAll('sharedLive', ' شارك البث المباشر 📤✨');
      } else if (lang == 'tr') {
        return rawMessage.replaceAll('sharedLive', 'bu yayını paylaştı 📤✨');
      } else if (lang == 'ur') {
        return rawMessage.replaceAll('sharedLive', 'نے یہ لائیو شیئر کیا 📤✨');
      } else {
        return rawMessage.replaceAll('sharedLive', 'ने यह लाइव साझा किया 📤✨');
      }
    }
    // A viewer followed the host from inside the live (owner spec 2026-06-12):
    // ONE line per session, sent by LiveRoomData.noteHostFollowed from every
    // in-live follow entry point (card pill / details sheet / room profile).
    if (rawMessage.contains('followedLive')) {
      final lang = Methods.getLang();
      if (lang == 'en') {
        return rawMessage.replaceAll('followedLive', 'followed the live ⭐');
      } else if (lang == 'ar') {
        return rawMessage.replaceAll('followedLive', ' قام بمتابعة البث ⭐');
      } else if (lang == 'tr') {
        return rawMessage.replaceAll('followedLive', 'yayını takip etti ⭐');
      } else if (lang == 'ur') {
        return rawMessage.replaceAll('followedLive', 'نے لائیو کو فالو کیا ⭐');
      } else {
        return rawMessage.replaceAll('followedLive', 'ने लाइव को फॉलो किया ⭐');
      }
    }
    // Host away/back system lines (sentinels broadcast by the host's
    // lifecycle observer — see LiveRoomScreen): viewers must know the host
    // stepped out briefly and came back.
    if (rawMessage.contains('hostAwayLive')) {
      final lang = Methods.getLang();
      if (lang == 'en') {
        return rawMessage.replaceAll('hostAwayLive', 'left the live briefly');
      } else if (lang == 'ar') {
        return rawMessage.replaceAll('hostAwayLive', ' غادر البث المباشر مؤقتاً ');
      } else if (lang == 'tr') {
        return rawMessage.replaceAll('hostAwayLive', 'yayından kısa süre ayrıldı');
      } else if (lang == 'ur') {
        return rawMessage.replaceAll('hostAwayLive', 'تھوڑی دیر کے لیے لائیو چھوڑ دیا');
      } else {
        return rawMessage.replaceAll('hostAwayLive', 'थोड़ी देर के लिए लाइव छोड़ा');
      }
    }
    if (rawMessage.contains('hostBackLive')) {
      final lang = Methods.getLang();
      if (lang == 'en') {
        return rawMessage.replaceAll('hostBackLive', 'returned to the live');
      } else if (lang == 'ar') {
        return rawMessage.replaceAll('hostBackLive', ' عاد إلى البث المباشر ');
      } else if (lang == 'tr') {
        return rawMessage.replaceAll('hostBackLive', 'yayına geri döndü');
      } else if (lang == 'ur') {
        return rawMessage.replaceAll('hostBackLive', 'لائیو پر واپس آگئے');
      } else {
        return rawMessage.replaceAll('hostBackLive', 'लाइव पर वापस आए');
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
    return Padding(
      padding: context.paddingAll(5),
      child: widget.message?.text.contains("joinRoom") ?? false
          ? Container(
              padding: context.paddingAll(5),
              decoration: BoxDecoration(
                borderRadius: 4.radius,
                color: Colors.black.withValues(alpha: 0.25),
              ),
              child: Text.rich(
                _textStyle(
                  "${widget.message?.senderName ?? ""} ${StringManager.enterTheRoom.tr()}",
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
                                    .sanitizedForDisplay
                                    .replaceAll(" ", "_");
                                Navigator.of(context).push(
                                  LiveInRoomMessageInputBoard(
                                    mention: "@$name",
                                  ),
                                );
                              },
                              child: CacheImageWidget(
                                url: value['img']?.toString() ?? "",
                                height: 30.h,
                                width: 30.w,
                                shape: BoxShape.circle,
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
                                        text: widget.message?.senderName ?? "",
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
                                                value["sI"]
                                                    .toString()
                                                    .isNotEmpty) ...[
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
                                      // Row 2: SVIP + all other (admin)
                                      // badges, in the same order as profile.
                                      if (value["v"] != "" ||
                                          ((value["bT"] as List?) ?? []).any(
                                              (b) =>
                                                  (b?.toString() ?? "")
                                                      .isNotEmpty)) ...[
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
                                                  in (value["bT"] as List?) ??
                                                      [])
                                                if (badge != null &&
                                                    badge
                                                        .toString()
                                                        .isNotEmpty)
                                                  Padding(
                                                    padding: context
                                                        .paddingOnly(start: 5),
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
                                      // Row 3: achievement medals, separate
                                      // row above the chat bubble, matching
                                      // the profile page.
                                      if (((value["aI"] as List?) ?? [])
                                          .any((m) =>
                                              (m?.toString() ?? "")
                                                  .isNotEmpty)) ...[
                                        3.hBox,
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for (final medal
                                                  in (value["aI"] as List?) ??
                                                      [])
                                                if (medal != null &&
                                                    medal
                                                        .toString()
                                                        .isNotEmpty)
                                                  Padding(
                                                    padding: context
                                                        .paddingOnly(end: 4),
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
                                          constraints: BoxConstraints(
                                            minHeight: 42.h,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: 6.radius,
                                            color: Colors.black
                                                .withValues(alpha: 0.25),
                                          ),
                                          child: Padding(
                                            padding: context.paddingOnly(
                                              start: 10,
                                              end: 8,
                                              top: 8,
                                              bottom: 8,
                                            ),
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
                                          width: ScreenUtil().screenWidth,
                                          boxFit: BoxFit.fill,
                                          isBubble: true,
                                          isFromRoom: true,
                                          child: Padding(
                                            padding: padding != null
                                                // Directional: bubble padding must flip with text direction
                                                // (Arabic/RTL) — absolute left/right misaligned the text.
                                                ? EdgeInsetsDirectional.only(
                                                    top: padding.top + 4,
                                                    bottom: padding.bottom + 4,
                                                    start: padding.left + 10,
                                                    end: padding.right,
                                                  )
                                                : context.paddingOnly(
                                                    end: 15,
                                                    start: 24,
                                                    bottom: 18,
                                                    top: 24,
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
            "${widget.message?.senderName ?? ""} ${StringManager.enterTheRoom.tr()}",
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
        padding: context.paddingSymmetric(horizontal: 8.0),
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
    } else {
      final text = Text.rich(
        _textStyle(
          _formattedText,
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
        padding: const EdgeInsets.only(left: 16, right: 30, top: 15, bottom: 10),
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

  static final RegExp _mentionRegex = RegExp(r'@\w+');

  TextSpan _textStyle(
    String text, {
    required TextStyle mentionStyle,
    required TextStyle defaultStyle,
  }) {
    final spans = <TextSpan>[];

    // Live comments/names are user-generated: lone UTF-16 surrogates here
    // abort the whole TextSpan build ("string is not well-formed UTF-16",
    // error widget instead of the chat line). Same guard the audio
    // MessagesView already applies via sanitizedForDisplay.
    final safeText = text.sanitizedForDisplay;

    safeText.splitMapJoin(
      _mentionRegex,
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
