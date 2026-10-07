import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/messages/messages.dart' as messages;

/// The kind of a conversation row rendered in the "All" list.
enum ConversationKind { chat, support }

/// A unified, sortable adapter over the heterogeneous chat sources that share
/// the "All" list (real 1:1 chats and technical-support). It exposes a single
/// comparable [sortTime] so the list can be ordered newest-first regardless of
/// the underlying source.
class ConversationRow {
  final ConversationKind kind;

  /// Real 1:1 chat payload. Only set when [kind] == [ConversationKind.chat].
  final messages.UserChatEntity? chat;

  /// Display fields for the synthetic (support) row.
  final String title;
  final String subtitle;

  /// Localized display string for the last-message time (e.g. "10:30:00 AM").
  final String timeLabel;

  /// Unread counter (0 for the synthetic rows, real value for chats).
  final int unread;

  final VoidCallback onTap;

  const ConversationRow({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.unread,
    required this.onTap,
    this.chat,
  });

  factory ConversationRow.fromChat({
    required messages.UserChatEntity chat,
    required VoidCallback onTap,
  }) {
    return ConversationRow(
      kind: ConversationKind.chat,
      chat: chat,
      title: chat.name,
      subtitle: chat.lastMessage.message ?? '',
      timeLabel: chat.lastMessage.time ?? '',
      unread: chat.unreadMessage,
      onTap: onTap,
    );
  }

  factory ConversationRow.support({
    required String subtitle,
    required String timeLabel,
    required VoidCallback onTap,
  }) {
    return ConversationRow(
      kind: ConversationKind.support,
      title: StringManager.team.tr(),
      subtitle: subtitle,
      timeLabel: timeLabel,
      unread: 0,
      onTap: onTap,
    );
  }

  /// Parses the localized `hh:mm:ss a` display label back into a comparable
  /// instant for sorting. The label has no calendar date (all sources format
  /// last-message time as time-of-day via Methods.utcToLocal), so we anchor it
  /// to today; rows with an unparsable/empty label sort to the bottom.
  DateTime get sortTime => _parseLabel(timeLabel);

  static DateTime _parseLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      // The label was produced by Methods.utcToLocal with the user's locale, so
      // for Arabic the AM/PM marker is "ص"/"م", not "AM"/"PM". Parsing it back
      // with a locale-less DateFormat throws a FormatException on those markers
      // (every Arabic row then fell into the catch and sorted to epoch 0). Parse
      // with the SAME locale that formatted it so the marker round-trips.
      final parsed =
          DateFormat('hh:mm:ss a', Methods.getLang()).parse(trimmed);
      final now = DateTime.now();
      return DateTime(
          now.year, now.month, now.day, parsed.hour, parsed.minute, parsed.second);
    } catch (_) {
      final fallback = DateTime.tryParse(trimmed);
      if (fallback != null) return fallback;
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
