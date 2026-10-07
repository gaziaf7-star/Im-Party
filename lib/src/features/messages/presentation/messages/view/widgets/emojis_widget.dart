part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _EmojisWidget extends StatelessWidget {
  const _EmojisWidget({required this.isMe, required this.entity});

  final bool isMe;
  final MessagesEntity entity;

  @override
  Widget build(BuildContext context) {
    // Reactions are derived purely from this message's entity, so an isolated
    // rebuild can never paint another bubble's reactions here.
    final emojis = ReactController.emojisFor(entity);
    return PositionedDirectional(
      start: isMe ? 5.w : null,
      end: !isMe ? 5.w : null,
      bottom: -17.5.h,
      child: Container(
        width: emojis.length > 1
            ? 25.w * (emojis.length + 0.25)
            : 25.w * emojis.length,
        height: 25.h,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 15.radius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < emojis.length; i++)
              Image.asset(
                emojis[i].assetImage,
                scale: 30,
              ),
            emojis.length > 1 ? 3.wBox : const SizedBox.shrink(),
            emojis.length > 1
                ? TextWidget(
              "${emojis.length}",
              // Fixed light-black — this pill is a fixed white background.
              style: context.bodyMedium
                  .colorExt(ColorManager.momentPostTextColor),
            )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}