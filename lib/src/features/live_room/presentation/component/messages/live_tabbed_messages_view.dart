import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/live_room/presentation/component/messages/live_messages_view.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/room.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// The live room's tabbed in-room chat list — a fork of the audio room's
/// `TabbedMessagesView`. Bound to the LIVE controller's chat channel
/// ([LiveRoomData.instance.chatController]) and the live kit's
/// [live.UTDChatMessage]. Unlike the audio view it does NOT constrain its own
/// width — the live kit already wraps `messagesWidget` in a
/// `FractionallySizedBox(widthFactor: 0.72)` (the audio kit does not).
enum LiveMessageTabType { all, chats, games, gifts }

class LiveTabbedMessagesView extends StatefulWidget {
  const LiveTabbedMessagesView({super.key});

  @override
  State<LiveTabbedMessagesView> createState() => _LiveTabbedMessagesViewState();
}

class _LiveTabbedMessagesViewState extends State<LiveTabbedMessagesView> {
  LiveMessageTabType _selectedTab = LiveMessageTabType.all;

  /// The chevron keeps the existing larger-message treatment for a host
  /// reading from a distance. The panel itself always consumes its complete
  /// grid-to-controls slot; only the message text scale changes.
  bool _enlarged = false;

  final ScrollController _scrollController = ScrollController();

  final _rebuildNotifier = ValueNotifier<int>(0);
  Timer? _throttleTimer;
  VoidCallback? _messageListener;

  // Cached filter result. The filter scans message text (Send-a-gift / lucky-box
  // string matches) for the gifts/games tabs — O(n) over the whole history — so
  // recompute it only when the message set or the selected tab actually changes,
  // not on every 100ms rebuild tick.
  List<live.UTDChatMessage> _cachedFiltered = const [];
  int _cachedLen = -1;
  String? _cachedLastId;
  LiveMessageTabType? _cachedTab;

  @override
  void initState() {
    super.initState();
    _messageListener = () {
      if (_throttleTimer == null || !_throttleTimer!.isActive) {
        _throttleTimer = Timer(const Duration(milliseconds: 100), () {
          _rebuildNotifier.value++;
          _autoScrollToEnd();
        });
      }
    };
    LiveRoomData.instance.chatController?.messages.addListener(
      _messageListener!,
    );
  }

  @override
  void dispose() {
    if (_messageListener != null) {
      LiveRoomData.instance.chatController?.messages.removeListener(
        _messageListener!,
      );
    }
    _throttleTimer?.cancel();
    _scrollController.dispose();
    _rebuildNotifier.dispose();
    super.dispose();
  }

  void _autoScrollToEnd() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      // The newest row often still contains an async-loading image
      // (avatar/bubble/gift/badges) that resizes the row on a LATER
      // frame -- jumpTo above lands on the extent from before that
      // resize, leaving the new message clipped until the user
      // manually scrolls. Re-snap to the bottom a couple more times
      // after short delays so it settles once those images resolve.
      for (final delay in const [
        Duration(milliseconds: 150),
        Duration(milliseconds: 400),
        Duration(milliseconds: 800),
      ]) {
        Future.delayed(delay, () {
          if (!mounted || !_scrollController.hasClients) return;
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    });
  }

  bool _filterMessage(live.UTDChatMessage message) {
    switch (_selectedTab) {
      case LiveMessageTabType.all:
        return true;
      case LiveMessageTabType.chats:
        return _isChatMessage(message);
      case LiveMessageTabType.games:
        return _isGameMessage(message);
      case LiveMessageTabType.gifts:
        return _isGiftMessage(message);
    }
  }

  bool _isChatMessage(live.UTDChatMessage message) {
    return !_isGameMessage(message) && !_isGiftMessage(message);
  }

  bool _isGameMessage(live.UTDChatMessage message) {
    final gameType = message.userData['gameType'];
    if (gameType != null && gameType.toString().isNotEmpty) {
      return true;
    }
    return false;
  }

  bool _isGiftMessage(live.UTDChatMessage message) {
    final msgText = message.text;

    if (msgText.contains('Send a gift') || msgText.contains('ارسل هدية')) {
      return true;
    }

    if (msgText == 'lucky_gift_winner') {
      return true;
    }

    if (msgText == StringManager.winInLuckyBoxMessageKey ||
        msgText == StringManager.sendBoxMessageKey) {
      return true;
    }

    if (message.userData['giftImage'] != null ||
        message.userData['giftName'] != null) {
      return true;
    }

    return false;
  }

  /// The big-chat treatment is HOST-ONLY: the host reads the chat from a meter
  /// away (ring light), so their compact = the old enlarged size and their
  /// enlarged fills up to just below the header with a 1.7 font. The audience
  /// keeps the regular view (the original sizes and 1.35 enlarge).
  bool get _isHost =>
      live.UTDRoomScope.maybeOf(context)?.controller.isLocalHost ?? false;

  @override
  Widget build(BuildContext context) {
    // The kit has already reserved the visible grid height plus the exact
    // 10px gap. Fill every remaining pixel down to the controls: tabs stay at
    // the top and the scrollable message list consumes the rest.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            // The kit used to clamp the chat column to 72% width; that frame
            // moved here when the slot became full-bleed.
            width: constraints.maxWidth * 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: _buildTabBar()),
                    6.wBox,
                    _buildToggleButton(),
                  ],
                ),
                8.hBox,
                Expanded(child: _buildMessagesList()),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Round toggle beside the tabs: up chevron in compact mode (tap to enlarge
  /// the section + font), down chevron when enlarged (tap to shrink back).
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => _enlarged = !_enlarged),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: ColorManager.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _enlarged ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
          color: Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 32.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem(
            title: StringManager.all.tr(),
            type: LiveMessageTabType.all,
          ),
          _buildTabItem(
            title: StringManager.chat.tr(),
            type: LiveMessageTabType.chats,
          ),
          _buildTabItem(
            title: StringManager.games.tr(),
            type: LiveMessageTabType.games,
          ),
          _buildTabItem(
            title: StringManager.gift.tr(),
            type: LiveMessageTabType.gifts,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required LiveMessageTabType type,
  }) {
    final isSelected = _selectedTab == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = type;
        });
        _autoScrollToEnd();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: ColorManager.transparent,
          border:
              isSelected
                  ? Border(bottom: BorderSide(color: Colors.white, width: 2.h))
                  : null,
        ),
        child: Text(
          title,
          style:
              context.bodySmall
                  .colorExt(isSelected ? ColorManager.white : Colors.white70)
                  .w500,
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ValueListenableBuilder<int>(
      valueListenable: _rebuildNotifier,
      builder: (context, _, __) {
        final allMessages =
            LiveRoomData.instance.chatController?.messages.value ?? [];
        final lastId =
            allMessages.isNotEmpty ? allMessages.last.messageID : null;
        if (allMessages.length != _cachedLen ||
            _selectedTab != _cachedTab ||
            lastId != _cachedLastId) {
          _cachedFiltered = allMessages.where(_filterMessage).toList();
          _cachedLen = allMessages.length;
          _cachedTab = _selectedTab;
          _cachedLastId = lastId;
        }
        final filteredMessages = _cachedFiltered;

        // The rules row and the intro row are only worth a slot when they
        // actually say something. Both were unconditional, so a room with no
        // rules and no intro opened with two empty grey banners — one of them
        // just the app logo on a blank strip.
        final room = LiveRoomData.instance.roomOrNull;
        final rule = (room?.roomRule ?? '').trim();
        final intro = (room?.roomIntro ?? '').trim();
        final headerCount = (rule.isEmpty ? 0 : 1) + (intro.isEmpty ? 0 : 1);

        return ListView.builder(
          reverse: false,
          controller: _scrollController,
          padding: EdgeInsets.zero,
          itemCount: filteredMessages.length + headerCount,
          itemBuilder: (context, index) {
            if (index < headerCount) {
              final isRule = rule.isNotEmpty && index == 0;

              return _buildDefaultMessageBody(
                imagePath:
                    isRule
                        ? AssetsManager.logo
                        : AssetsManager.roomIntroMessageIcon,
                text:
                    isRule ? rule : "${StringManager.roomIntro.tr()} \n$intro",
              );
            } else {
              final message = filteredMessages[index - headerCount];
              return InkWell(
                onTap: () {
                  if (message.senderUserId != '-1') {
                    bottomDailog(
                      context: navKey.currentState!.context,
                      widget: UserRoomProfile(
                        userId: message.senderUserId,
                        // Fall back to the pre-entry seed: the non-null getter
                        // throws until the enter-room response lands, which
                        // left this tap silently dead.
                        roomData:
                            LiveRoomData.instance.roomOrNull ??
                            RoomData.instance.room,
                      ),
                    );
                  }
                },
                child: LiveMessagesView(
                  message: message,
                  // Host reads the chat from ~a meter away (ring light) →
                  // 1.7. The audience keeps the regular 1.35 enlarge.
                  fontScale: _enlarged ? (_isHost ? 1.7 : 1.35) : 1.0,
                ),
              );
            }
          },
        );
      },
    );
  }
}

Widget _buildDefaultMessageBody({
  required String imagePath,
  required String text,
}) {
  return Container(
    padding: const EdgeInsets.all(5),
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      borderRadius: 3.radius,
      color: const Color(0xFFD9D9D9).withValues(alpha: 0.25),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 37.w,
          height: 37.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage(imagePath)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: ColorManager.white, fontSize: 12.sp),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    ),
  );
}
