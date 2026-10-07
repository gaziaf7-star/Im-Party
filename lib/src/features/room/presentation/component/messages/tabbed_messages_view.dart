import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/room.dart';

enum MessageTabType { all, chats, games, gifts }

class TabbedMessagesView extends StatefulWidget {
  const TabbedMessagesView({super.key});

  @override
  State<TabbedMessagesView> createState() => _TabbedMessagesViewState();
}

class _TabbedMessagesViewState extends State<TabbedMessagesView> {
  MessageTabType _selectedTab = MessageTabType.all;
  final ScrollController _scrollController = ScrollController();

  final _rebuildNotifier = ValueNotifier<int>(0);
  Timer? _throttleTimer;
  VoidCallback? _messageListener;

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
    RoomData.instance.chatController?.messages.addListener(_messageListener!);
  }

  @override
  void dispose() {
    if (_messageListener != null) {
      RoomData.instance.chatController?.messages
          .removeListener(_messageListener!);
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

  bool _filterMessage(UTDChatMessage message) {
    switch (_selectedTab) {
      case MessageTabType.all:
        return true;
      case MessageTabType.chats:
        return _isChatMessage(message);
      case MessageTabType.games:
        return _isGameMessage(message);
      case MessageTabType.gifts:
        return _isGiftMessage(message);
    }
  }

  bool _isChatMessage(UTDChatMessage message) {
    return !_isGameMessage(message) && !_isGiftMessage(message);
  }

  bool _isGameMessage(UTDChatMessage message) {
    final gameType = message.userData['gameType'];
    if (gameType != null && gameType.toString().isNotEmpty) {
      return true;
    }
    return false;
  }

  bool _isGiftMessage(UTDChatMessage message) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        15.hBox,
        // Tab bar
        _buildTabBar(),
        8.hBox,
        // Messages list
        Expanded(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: _buildMessagesList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 32.h,
      margin: EdgeInsets.symmetric(horizontal: 17.w),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem(
            title: StringManager.all.tr(),
            type: MessageTabType.all,
          ),
          _buildTabItem(
            title: StringManager.chat.tr(),
            type: MessageTabType.chats,
          ),
          _buildTabItem(
            title: StringManager.games.tr(),
            type: MessageTabType.games,
          ),
          _buildTabItem(
            title: StringManager.gift.tr(),
            type: MessageTabType.gifts,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required MessageTabType type,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: ColorManager.transparent,
          border: isSelected
              ? Border(
            bottom: BorderSide(
              color: Colors.white,
              width: 2.h,
            ),
          )
              : null,
        ),
        child: Text(
          title,
          style: context.bodySmall
              .colorExt(
            isSelected ? ColorManager.white : Colors.white70,
          )
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
            RoomData.instance.chatController?.messages.value ?? [];
        final filteredMessages = allMessages.where(_filterMessage).toList();

        // The rules row and the intro row are only worth a slot when they
        // actually say something. Both were unconditional, so a room with no
        // rules and no intro opened with two empty grey banners — one of them
        // just the app logo on a blank strip.
        final room = RoomData.instance.roomOrNull;
        final rule = (room?.roomRule ?? '').trim();
        final intro = (room?.roomIntro ?? '').trim();
        final headerCount = (rule.isEmpty ? 0 : 1) + (intro.isEmpty ? 0 : 1);

        return ListView.builder(
          reverse: false,
          controller: _scrollController,
          // Left inset matches the tab bar's own `margin: EdgeInsets
          // .symmetric(horizontal: 12.w)` above (_buildTabBar) -- the list
          // was flush against the screen edge (padding zero) while the tab
          // bar sat 12.w in, so the chat/announcement rows started further
          // left than "All / Chat / Games / Gift" above them. On request,
          // both now share the same left starting edge.
          padding: EdgeInsets.only(left: 12.w),
          itemCount: filteredMessages.length + headerCount,
          itemBuilder: (context, index) {
            if (index < headerCount) {
              final isRule = rule.isNotEmpty && index == 0;

              return _buildDefaultMessageBody(
                imagePath: isRule
                    ? AssetsManager.logo
                    : AssetsManager.roomIntroMessageIcon,
                text: isRule
                    ? rule
                    : "${StringManager.roomIntro.tr()} \n$intro",
              );
            } else {
              final message = filteredMessages[index - headerCount];
              return InkWell(
                onTap: () {
                  final navContext = SafeNavigator.context;
                  if (message.senderUserId != '-1' && navContext != null) {
                    bottomDailog(
                      context: navContext,
                      widget: UserRoomProfile(
                        userId: message.senderUserId,
                        roomData: RoomData.instance.room,
                      ),
                    );
                  }
                },
                child: MessagesView(
                  message: message,
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
    // Light-black card (was a light-white D9D9D9 tint) for the room
    // rule/intro banner row, on request.
    decoration: BoxDecoration(
      borderRadius: 3.radius,
      color: Colors.black.withValues(alpha: 0.25),
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
            style: TextStyle(
              color: ColorManager.white,
              fontSize: 12.sp,
            ),
            overflow: TextOverflow.visible,
          ),
        )
      ],
    ),
  );
}