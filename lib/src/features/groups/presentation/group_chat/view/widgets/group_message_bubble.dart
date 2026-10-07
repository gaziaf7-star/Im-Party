import 'dart:convert';

import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
// Hide the UI MessageState: this bubble renders a drift [Message], so
// MessageState here is the drift lifecycle enum from chat_tables.dart.
import 'package:general/src/core/index.dart' hide MessageState;
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/room/presentation/share/open_shared_room.dart';

/// A single group chat bubble for a `kind=='user'` message.
///
/// For other people's messages it shows a sender name + avatar header (the first
/// bubble in a run). For my own messages it shows the delivery state (pending /
/// failed-with-retry) and, on my newest message, a read receipt: a "Read by N"
/// counter for large groups or a names list for small ones (Plan 5.3 / 7.6).
class GroupMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showSenderHeader;
  final bool showReadReceipt;
  final List<GroupMemberEntity> members;
  final GroupEntity group;
  final VoidCallback onRetry;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  const GroupMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showSenderHeader,
    required this.showReadReceipt,
    required this.members,
    required this.group,
    required this.onRetry,
    this.onReply,
    this.onDelete,
  });

  GroupMemberEntity? get _sender {
    final id = message.senderId;
    if (id == null) return null;
    for (final m in members) {
      if (m.userId == id) return m;
    }
    return null;
  }

  bool get _isPending => message.state == MessageState.pending;
  bool get _isFailed => message.state == MessageState.failed;

  /// A shared room/live card (same `share_room:` wire the DM share uses:
  /// `share_room:<key>:<name>\n:<roomId>:Room`). Rendered as a tappable
  /// join card instead of the raw text.
  bool get _isShareRoom => (message.body ?? '').startsWith('share_room:');

  /// A "deleted for everyone" message must show a tombstone to all members; a
  /// "deleted for me" only hides it on the owning side. Mirrors the DM stack
  /// (DriftMessageMapper.senderDeleted/receiverDeleted) so both render the same.
  bool get _isDeleted =>
      message.deleteState == MessageDeleteState.deletedForAll ||
          (message.deleteState == MessageDeleteState.deletedForMe && isMe);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 12, vertical: 3),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _leadingAvatar(),
              if (!isMe) 8.wBox,
              Flexible(child: _bubble(context)),
            ],
          ),
          if (isMe) _MyStatusLine(
            isPending: _isPending,
            isFailed: _isFailed,
            showReadReceipt: showReadReceipt && !_isPending && !_isFailed,
            readByText: _readByText(),
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _leadingAvatar() {
    if (!showSenderHeader) return SizedBox(width: 32.w);
    return ImageViewWidget(
      url: _sender?.avatar ?? '',
      displayName: _sender?.name ?? '',
      height: 32,
      width: 32,
      radius: 16,
    );
  }

  /// Long-press menu: reply and/or delete-for-everyone, depending on which
  /// callbacks the screen supplied (the screen decides delete eligibility — own
  /// message, or owner/admin — so the bubble stays purely presentational). No
  /// menu on a tombstone or a not-yet-confirmed (pending) row.
  void _showActions(BuildContext context) {
    if (_isDeleted || _isPending) return;
    final hasReply = onReply != null;
    final hasDelete = onDelete != null;
    if (!hasReply && !hasDelete) return;

    showModalBottomSheet<void>(
      context: context,
      // Fixed white (was scaffoldBg — panel-driven).
      backgroundColor: ColorManager.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: 16.radiusCircular),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasReply)
              ListTile(
                leading: Icon(Icons.reply,
                    color: ColorManager.momentPostTextColor),
                title: TextWidget(
                  StringManager.replyingTo.tr(),
                  style: context.bodyMedium
                      .colorExt(ColorManager.momentPostTextColor),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onReply!();
                },
              ),
            if (hasDelete)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: ColorManager.redAccount),
                title: TextWidget(
                  StringManager.removeForAll.tr(),
                  style: context.bodyMedium.colorExt(ColorManager.redAccount),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context) {
    return GestureDetector(
      // No reply/delete affordance on a tombstone.
      onLongPress: _isDeleted ? null : () => _showActions(context),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        padding: context.paddingSymmetric(vertical: 7.5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: 10.radius,
          // Brand gradient for my bubble; fixed white for theirs (was
          // primary/surfaceCardColor — flat panel-driven colors).
          color: isMe ? null : ColorManager.white,
          gradient: isMe ? ColorManager.brandGradient : null,
        ),
        child: _isDeleted
            ? _deletedPlaceholder(context)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSenderHeader && !isMe)
              Padding(
                padding: context.paddingOnly(bottom: 2),
                child: GradientName(child: TextWidget(
                  _sender?.name ?? '',
                  isTranslate: false,
                  style:
                  context.bodySmall.w600.colorExt(ColorManager.blue),
                )),
              ),
            if (message.replyToClientUuid != null) _replyQuote(context),
            if (_isShareRoom)
              _shareRoomCard(context)
            else
              ExpandableText(
                message.body ?? '',
                style: context.bodyMedium.size(16).colorExt(isMe
                    ? ColorManager.onBrandGradient
                    : ColorManager.momentPostTextColor),
                toggleColor: isMe
                    ? ColorManager.onBrandGradient
                    : ColorManager.brandGradientColors.last,
              ),
          ],
        ),
      ),
    );
  }

  /// Live/room share card: gradient banner with a LIVE badge, the stream name
  /// and a join CTA. Tapping joins through the same flow as the DM share card.
  Widget _shareRoomCard(BuildContext context) {
    final parts = (message.body ?? '').split(':');
    final name = parts.length > 2 ? parts[2].replaceAll('\n', '').trim() : '';
    final roomId = parts.length > 3 ? parts[3] : '';
    return GestureDetector(
      onTap: roomId.isEmpty ? null : () => openSharedRoomFromChat(roomId),
      child: Container(
        width: 220.w,
        padding: context.paddingAll(12),
        decoration: BoxDecoration(
          borderRadius: 12.radius,
          // Brand gradient (was the flat panel-driven primary).
          gradient: ColorManager.brandGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  context.paddingSymmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorManager.red,
                    borderRadius: 8.radius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.podcasts, color: Colors.white, size: 13.sp),
                      3.wBox,
                      TextWidget(
                        StringManager.live.tr(),
                        style: context.bodySmall.w700
                            .size(11)
                            .colorExt(Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            8.hBox,
            TextWidget(
              name.isNotEmpty ? name : StringManager.live.tr(),
              isTranslate: false,
              maxLines: 2,
              // Fixed white — this sits on the brand-gradient banner now.
              style: context.bodyMedium.w700
                  .colorExt(ColorManager.onBrandGradient),
            ),
            8.hBox,
            Row(
              children: [
                Icon(Icons.play_circle_fill,
                    color: ColorManager.onBrandGradient, size: 18.sp),
                5.wBox,
                TextWidget(
                  StringManager.tapToJoin.tr(),
                  style: context.bodySmall
                      .colorExt(ColorManager.onBrandGradient),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tombstone for a deleted message, reusing the exact DM localized strings
  /// (deletedThisMessage / messageWasDeleted) so both stacks read identically.
  Widget _deletedPlaceholder(BuildContext context) {
    // Fixed white on the gradient "my" bubble, fixed light-black on the
    // white "their" bubble (was buttonTextColor/greyTextColor — both
    // panel-driven and dark by default, which is invisible on the gradient).
    final color = isMe
        ? ColorManager.onBrandGradient
        : ColorManager.momentPostTextColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block, size: 14.h, color: color),
        6.wBox,
        Flexible(
          child: TextWidget(
            isMe
                ? StringManager.deletedThisMessage.tr()
                : StringManager.messageWasDeleted.tr(),
            isTranslate: false,
            style: context.bodyMedium.size(15).colorExt(color),
          ),
        ),
      ],
    );
  }

  Widget _replyQuote(BuildContext context) {
    // Decode the cached reply preview (same canonical shape the realtime mapper
    // writes / DriftMessageMapper reads) and show the original sender + a
    // one-line preview, falling back to the static label when it's absent.
    final preview = _decodeReplyPreview(message.replyPreviewJson);
    final senderName = preview?['_senderName'] as String?;
    final previewLine = preview?['_previewLine'] as String?;

    // Translucent "quote highlight" tint that reads on both sides: a light
    // white wash on the brand-gradient "my" bubble, a light brand-purple wash
    // on the white "their" bubble (was buttonTextColor/grey + a fixed blue
    // accent, which didn't adapt to the new bubble colors).
    final Color scrimColor = isMe
        ? ColorManager.white.withValues(alpha: 0.15)
        : ColorManager.brandGradientColors.last.withValues(alpha: 0.08);
    final Color accentColor =
    isMe ? ColorManager.onBrandGradient : ColorManager.brandGradientColors.last;
    final Color textColor =
    isMe ? ColorManager.onBrandGradient : ColorManager.momentPostTextColor;
    return Container(
      margin: context.paddingOnly(bottom: 4),
      padding: context.paddingSymmetric(vertical: 4, horizontal: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: scrimColor,
        borderRadius: 6.radius,
        border: Border(
          left: BorderSide(color: accentColor, width: 3.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientName(child: TextWidget(
            (senderName != null && senderName.isNotEmpty)
                ? senderName
                : StringManager.replyingTo.tr(),
            isTranslate: senderName == null || senderName.isEmpty,
            maxLines: 1,
            style: context.bodySmall.w600.colorExt(accentColor),
          )),
          if (previewLine != null && previewLine.isNotEmpty) ...[
            2.hBox,
            TextWidget(
              previewLine,
              isTranslate: false,
              maxLines: 1,
              style: context.bodySmall
                  .colorExt(textColor.withValues(alpha: 0.75)),
            ),
          ],
        ],
      ),
    );
  }

  /// Decodes [replyPreviewJson] into a sender name + a one-line preview. Media
  /// replies get a localized placeholder (Photo/Voice/Video) instead of a blank
  /// line, matching the DM reply widget. Returns null when there's nothing to
  /// show so the caller can fall back to the static "Replying to" label.
  Map<String, dynamic>? _decodeReplyPreview(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final senderId = map['messageUserId'];
      final senderName = senderId == null
          ? null
          : (_memberName(senderId is int
          ? senderId
          : int.tryParse('$senderId')) ??
          '');
      final type = map['messageType']?.toString();
      final body = map['message']?.toString();
      final String previewLine;
      switch (type) {
        case 'img':
          previewLine = StringManager.photo.tr();
          break;
        case 'voice':
          previewLine = StringManager.voice.tr();
          break;
        case 'video':
          previewLine = StringManager.video.tr();
          break;
        default:
          previewLine = body ?? '';
      }
      return {'_senderName': senderName, '_previewLine': previewLine};
    } catch (_) {
      return null;
    }
  }

  String? _memberName(int? userId) {
    if (userId == null) return null;
    for (final m in members) {
      if (m.userId == userId) return m.name;
    }
    return null;
  }

  /// Read-receipt text for my newest message. Counts members (excluding me)
  /// whose last_read_seq has reached this message's seq.
  String? _readByText() {
    final seq = message.serverSeq;
    if (seq == null) return null;
    final myId = MyDataModel.getInstance().id;
    final readers = members
        .where((m) => m.userId != myId && m.lastReadSeq >= seq)
        .toList();
    if (readers.isEmpty) return null;

    // In a group we always show the COUNT of people who read the message
    // (e.g. "قُرئت بواسطة 3"), never their names — the owner wants the number.
    return '${StringManager.readBy.tr()} ${readers.length}';
  }
}

class _MyStatusLine extends StatelessWidget {
  final bool isPending;
  final bool isFailed;
  final bool showReadReceipt;
  final String? readByText;
  final VoidCallback onRetry;

  const _MyStatusLine({
    required this.isPending,
    required this.isFailed,
    required this.showReadReceipt,
    required this.readByText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isFailed) {
      return GestureDetector(
        onTap: onRetry,
        child: Padding(
          padding: context.paddingOnly(top: 2, end: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 13.h, color: ColorManager.red),
              4.wBox,
              TextWidget(
                StringManager.resendMessage.tr(),
                style: context.bodySmall.colorExt(ColorManager.red),
              ),
            ],
          ),
        ),
      );
    }

    if (isPending) {
      // This status line only ever renders under "my" bubble (brand
      // gradient), so a flat grey is too low-contrast.
      return Padding(
        padding: context.paddingOnly(top: 2, end: 4),
        child: Icon(Icons.access_time,
            size: 12.h,
            color: ColorManager.onBrandGradient.withValues(alpha: 0.85)),
      );
    }

    if (showReadReceipt && readByText != null) {
      return Padding(
        padding: context.paddingOnly(top: 2, end: 4),
        child: TextWidget(
          readByText!,
          isTranslate: false,
          style: context.bodySmall.size(11).colorExt(
              ColorManager.onBrandGradient.withValues(alpha: 0.85)),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}