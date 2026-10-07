part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _SeenWidget extends StatelessWidget {
  const _SeenWidget({required this.entity});
  final MessagesEntity entity;

  @override
  Widget build(BuildContext context) {
    final bool isMe = Methods.isMe('${entity.userId}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextWidget(
          Methods.utcToLocal(entity.createdAt ?? ""),
          // Fixed white on the brand-gradient "my" bubble, light-black on the
          // white "their" bubble (was buttonTextColor/secondaryText — both
          // panel-driven and dark by default, invisible on the gradient).
          style: context.bodySmall.w500.colorExt(isMe
              ? ColorManager.onBrandGradient.withValues(alpha: (0.85))
              : ColorManager.momentPostTextColor.withValues(alpha: (0.6))),
        ),
        if (isMe) ...[
          5.wBox,
          _statusIcon(entity),
        ],
        5.wBox,
      ],
    );
  }

  // Local-first state takes precedence over the server `status` string so an
  // in-flight bubble shows a clock and a failed send shows the red mark, while
  // delivered/confirmed messages fall back to the receipt derived from
  // `status` (the drift lifecycle collapses sent/delivered/read into `sent`,
  // so the receipt detail lives only in `status`).
  Widget _statusIcon(MessagesEntity e) {
    switch (e.messageState) {
      case MessageState.sending:
      // These status icons only ever render on the "my message" side
      // (brand-gradient bubble), so a flat grey is too low-contrast.
        return Icon(
          Icons.access_time,
          size: 14.h,
          color: ColorManager.onBrandGradient.withValues(alpha: 0.85),
        );
      case MessageState.loading:
        return _fromStatus(e.status);
      case MessageState.error:
        return Icon(
          Icons.error_outline,
          size: 16.h,
          color: ColorManager.redAccount,
        );
      case MessageState.sent:
      case MessageState.none:
        return _fromStatus(e.status);
    }
  }

  Widget _fromStatus(String? status) {
    switch (status) {
      case 'seen':
        return Icon(
          Icons.done_all,
          size: 16.h,
          color: ColorManager.blue,
        );
      case 'delivered':
      case 'received':
        return Icon(
          Icons.done_all,
          size: 16.h,
          color: ColorManager.onBrandGradient.withValues(alpha: 0.85),
        );
      case 'sent':
      case 'sended':
        return Icon(
          Icons.done,
          size: 16.h,
          color: ColorManager.onBrandGradient.withValues(alpha: 0.85),
        );
      default:
        return Icon(
          Icons.done,
          size: 16.h,
          color: ColorManager.onBrandGradient.withValues(alpha: 0.85),
        );
    }
  }
}