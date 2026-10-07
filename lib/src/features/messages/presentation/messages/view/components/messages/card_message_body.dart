part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _CardMessageBody extends StatelessWidget {
  const _CardMessageBody({
    required this.entity,
    required this.params,
    required this.isLastMessage,
  });
  final MessagesEntity entity;
  final MessagesParameter params;
  final bool isLastMessage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // `isLoading` is checked at gesture time (live) instead of read in build
      // without a subscription, which used a stale value and ran no rebuild.
      onTap: () {
        if (di<SendMessagesBloc>().state.reqState.isLoading) return;
        _onTap();
      },
      onLongPress: () {
        if (di<SendMessagesBloc>().state.reqState.isLoading) return;
        _onLongPress();
      },
      onLongPressEnd: (details) {
        if (di<SendMessagesBloc>().state.reqState.isLoading) return;
        _onLongPressEnd(details, context);
      },
      behavior: HitTestBehavior.translucent,

      // Subscribe only to THIS message's selection slice so its highlight is
      // live and a selection flip repaints just this bubble, not the whole list.
      child: BlocSelector<ToggleAppBarBloc, ToggleAppBarState, bool>(
        bloc: di<ToggleAppBarBloc>(),
        selector: (state) =>
            state.messageSelectionMap[entity.id]?.isSelected == true,
        builder: (context, isSelected) => Container(
          clipBehavior: Clip.none,
          color: isSelected
              ? Methods.isMe('${entity.userId}')
                  ? ColorManager.grey.withValues(alpha: (0.3))
                  : ColorManager.secondaryColor.withValues(alpha: (0.3))
              : ColorManager.transparent,
          child: entity.type == "img" || entity.type == "gif"
            ? entity.message != null && entity.message!.isNotEmpty
                ? _MessageImageAndTextWidget(
                    entity: entity,
                    params: params,
                    isLastMessage: isLastMessage,
                  )
                : _MessageImageWidget(
                    entity: entity,
                    params: params,
                    isLastMessage: isLastMessage,
                  )
            : entity.type == "voice"
                ? _MessageVoiceWidget(
                    entity: entity,
                    params: params,
                    isLastMessage: isLastMessage,
                  )
                : entity.type == "video"
                    ? MessageVideoWidget(
                        entity: entity,
                        params: params,
                        isLastMessage: isLastMessage,
                      )
                    : entity.type == "CP"
                        ? CpMessage(
                            isLastMessage: isLastMessage,
                            image: params.image,
                            messageStatus: entity.status ?? "",
                            replay: entity.replay,
                            userId: entity.userId.toString(),
                            message: entity.message.toString(),
                            messageId: entity.id.toString(),
                            createdAt: entity.createdAt ?? "",
                          )
                        : _MessageTextWidget(
                            entity: entity,
                            params: params,
                            isLastMessage: isLastMessage,
                          ),
        ),
      ),
    );
  }

  void _onTap() {
    if (di<ToggleAppBarBloc>().state.counter > 0) {
      di<ToggleAppBarBloc>().add(
        SelectedMessagesEvent(
          messageId: '${entity.id}',
          message: '${entity.message}',
          url: entity.albums?.file == ''
              ? ''
              : EndPoints.getImage(entity.albums?.file ?? ""),
          senderId: '${entity.userId}',
          messageType: '${entity.type}',
        ),
      );
    }
  }

  void _onLongPress() {
    di<ToggleAppBarBloc>().add(const ToggleAppBarEvent(isToggle: true));
    di<ToggleAppBarBloc>().add(
      SelectedMessagesEvent(
        messageId: '${entity.id}',
        message: '${entity.message}',
        url: entity.albums?.file == ''
            ? ''
            : EndPoints.getImage(entity.albums?.file ?? ""),
        senderId: '${entity.userId}',
        messageType: '${entity.type}',
      ),
    );
  }

  void _onLongPressEnd(LongPressEndDetails details, BuildContext context) {
    ReactionAskany.showReactionBox(
      context,
      doubleTapLabel: "",
      offset: details.globalPosition,
      boxParamenters: ReactionBoxParamenters(
        brightness: Brightness.dark,
        iconSize: 30.h,
        iconSpacing: 5.w,
        radiusBox: 50.r,
        quantityPerPage: 6,
      ),
      emotionPicked: ReactController.instance.emotionPicked(entity),
      handlePressed: (Emotions emotion) =>
          ReactController.instance.handlePressed(entity, emotion),
    );
  }
}
