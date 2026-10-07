import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../models/chat_message.dart';
import '../theme/utd_room_scope.dart';

class UTDDefaultMessageList extends StatefulWidget {
  final UTDChatController chatController;

  const UTDDefaultMessageList({
    super.key,
    required this.chatController,
  });

  @override
  State<UTDDefaultMessageList> createState() => _UTDDefaultMessageListState();
}

class _UTDDefaultMessageListState extends State<UTDDefaultMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.chatController.messages.addListener(_onMessagesChanged);
  }

  void _onMessagesChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    widget.chatController.messages.removeListener(_onMessagesChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UTDChatMessage>>(
      valueListenable: widget.chatController.messages,
      builder: (context, messages, __) {
        if (messages.isEmpty) {
          final scope = UTDRoomScope.maybeOf(context);
          if (scope == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                scope.strings.emptyChatHint,
                style: TextStyle(
                  color: scope.theme.onSurface.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (_, index) {
            final msg = messages[index];
            return _MessageBubble(message: msg);
          },
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final UTDChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // System lines (e.g. admin promote/demote announcements) render centered,
    // dimmed and without a sender prefix to read as room events, not chat.
    if (message.userData['system'] == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${message.senderName}  ',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
