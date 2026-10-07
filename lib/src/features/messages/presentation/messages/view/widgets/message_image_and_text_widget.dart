part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _MessageImageAndTextWidget extends StatelessWidget {
  const _MessageImageAndTextWidget({
    required this.entity,
    required this.params,
    required this.isLastMessage,
  });

  final MessagesEntity entity;
  final MessagesParameter params;
  final bool isLastMessage;

  bool get _isShareRoom => (entity.message ?? '').split(':')[0] == 'share_room';

  void _onTap(BuildContext context) async {
    final message = entity.message ?? '';
    final parts = message.split(':');
    if (parts.isNotEmpty && parts.length > 3) {
      final shareType = parts[0];
      final id = parts[3];
      if (shareType == 'share_room') {
        // Shared room/live join flow — single source of truth, also used by
        // the group-chat live card.
        await openSharedRoomFromChat(id);
      } else if (shareType == 'share_reel') {
        Navigator.pushNamed(context, Routes.reelsScreen, arguments: id);
      }
    }
  }

  String _getDescription() {
    if (_isShareRoom) {
      return StringManager.roomDescriptionChat.tr();
    }
    return StringManager.reelDescription.tr();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = Methods.isMe('${entity.userId}');
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // No per-message avatar in 1:1 chats (groups-only affordance).
          10.wBox,
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  // Brand gradient for my bubble; fixed white for theirs (was
                  // myColorMessageChat/textPrimary — textPrimary defaults to
                  // black, which made the "their" card a solid black box).
                  color: isMe ? null : ColorManager.white,
                  gradient: isMe ? ColorManager.brandGradient : null,
                  borderRadius: !isMe && isLastMessage
                      ? 10.radius.copyWith(bottomLeft: 0.radiusCircular)
                      : isMe && isLastMessage
                      ? 10.radius.copyWith(bottomRight: 0.radiusCircular)
                      : 10.radius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ImageViewWidget(
                      height: 150.h,
                      width: ScreenUtil().screenWidth / 1.80,
                      url: entity.albums?.file ?? '',
                      boxFit: BoxFit.cover,
                      showLoadingIndicator: true,
                      canRetry: true,
                    ),
                    10.hBox,
                    Padding(
                      padding: context.paddingOnly(end: 5),
                      child: TextWidget(
                        _getDescription(),
                        style: context.bodyMedium.w500.colorExt(isMe
                            ? ColorManager.onBrandGradient
                            .withValues(alpha: (0.85))
                            : ColorManager.momentPostTextColor
                            .withValues(alpha: (0.7))),
                      ),
                    ),
                    10.hBox,
                    _SeenWidget(entity: entity),
                    10.hBox,
                  ],
                ),
              ),
              entity.reacts == null
                  ? const SizedBox.shrink()
                  : _EmojisWidget(isMe: isMe, entity: entity),
            ],
          ),
          // No per-message avatar in 1:1 chats (groups-only affordance).
          10.wBox,
        ],
      ),
    );
  }
}