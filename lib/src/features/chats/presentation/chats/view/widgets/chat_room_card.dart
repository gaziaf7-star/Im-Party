import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/messages/messages.dart' as messages;

class ChatRoomCard extends StatelessWidget {
  final bool isMe;
  final messages.UserChatEntity userChatEntity;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final bool isLoading;

  const ChatRoomCard({
    super.key,
    required this.isMe,
    required this.userChatEntity,
    required this.onTap,
    required this.onLongPress,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 5, vertical: 2),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: 6.radius,
        child: SizedBox(
          height: 70.h,
          child: Row(
            children: [
              InkWell(
                onTap: () => showContactQuickView(
                  context,
                  name: userChatEntity.name,
                  image: userChatEntity.image,
                  userId: '${userChatEntity.userId}',
                  hasColorName: userChatEntity.hasColorName,
                  onMessage: onTap ?? () {},
                ),
                child: SizedBox(
                  height: 60.h,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: UserImage(
                          image: userChatEntity.image,
                          displayName: userChatEntity.name,
                          imageSize: 60.h,
                        ),
                      ),
                      if (userChatEntity.inRoom)
                        Container(
                          padding: context.paddingSymmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                              gradient: ColorManager.brandGradient,
                              borderRadius: 20.radius,
                              border: Border.all(
                                  color: ColorManager.onBrandGradient,
                                  width: 0.5)),
                          child: Image.asset(
                            AssetsManager.newSoundWave,
                            color: ColorManager.onBrandGradient,
                            height: 14.h,
                            width: 20.w,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              10.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientTextVip(
                      text: userChatEntity.name,
                      // Fixed light-black (was the panel-driven textPrimary).
                      textStyle: context.bodyLarge
                          .colorExt(
                        ColorManager.momentPostTextColor,
                      )
                          .w500,
                      isVip: userChatEntity.hasColorName,
                      width: ScreenUtil().screenWidth * 0.5,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    5.hBox,
                    if (userChatEntity.lastMessage.receiverDeleted == true ||
                        userChatEntity.lastMessage.senderDeleted == true) ...{
                      Row(
                        mainAxisAlignment:
                        Methods.isMe('${userChatEntity.userId}')
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!Methods.isMe('${userChatEntity.userId}'))
                            Icon(
                              Icons.do_disturb,
                              color: ColorManager.grey,
                              size: 20.h,
                            ),
                          if (!Methods.isMe('${userChatEntity.userId}'))
                            10.wBox,
                          FittedBox(
                            child: !Methods.isMe('${userChatEntity.userId}')
                                ? TextWidget(
                              StringManager.deletedThisMessage.tr(),
                              style: context.bodyMedium.colorExt(
                                  ColorManager.momentPostTextColor),
                            )
                                : TextWidget(
                              StringManager.messageWasDeleted.tr(),
                              style: context.bodyMedium.colorExt(
                                  ColorManager.momentPostTextColor),
                            ),
                          ),
                          if (Methods.isMe('${userChatEntity.userId}')) 10.wBox,
                          if (Methods.isMe('${userChatEntity.userId}'))
                            Icon(
                              Icons.do_disturb,
                              color: ColorManager.iconColor,
                              size: 20.h,
                            ),
                        ],
                      ),
                    } else ...{
                      Row(
                        children: [
                          if (isMe)
                            Row(
                              children: [
                                SeenWidget(
                                  seen: userChatEntity.lastMessage.status ?? "",
                                ),
                                // WhatsApp-style "You:" prefix always shows on
                                // the sender's own last message.
                                5.wBox,
                                TextWidget(
                                  '${StringManager.you.tr()}: ',
                                  style: context.bodyMedium.colorExt(
                                      ColorManager.momentPostTextColor),
                                ),
                              ],
                            ),
                          Expanded(
                            child: MessageIconType(
                              type: userChatEntity.lastMessage.type ?? "",
                              message: userChatEntity.lastMessage.message ?? "",
                            ),
                          ),
                        ],
                      ),
                    }
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Last-activity label is already WhatsApp-relative from the
                  // mapper (no seconds / منذ / أمس / date) — show it as-is.
                  TextWidget(
                    userChatEntity.lastMessage.time ?? '',
                    isTranslate: false,
                    // Fixed light-black (was the medium-grey lightBlackChat).
                    style: context.bodyMedium
                        .colorExt(ColorManager.momentPostTextColor),
                  ),
                  // Unread count BELOW the time (WhatsApp-style), not on the
                  // avatar. Solid red (not the purple brand gradient) so it
                  // reads as a clear "needs attention" signal, matching the
                  // reference design.
                  if (userChatEntity.unreadMessage != 0) ...[
                    6.hBox,
                    Container(
                      constraints: BoxConstraints(minWidth: 20.w),
                      padding: context.paddingSymmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B5C),
                        borderRadius: 20.radius,
                      ),
                      child: TextWidget(
                        '${userChatEntity.unreadMessage}',
                        isTranslate: false,
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .size(11)
                            .w600
                            .colorExt(ColorManager.white),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}