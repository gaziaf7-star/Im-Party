part of 'group_chat_bloc.dart';

abstract class GroupChatEvent extends Equatable {
  const GroupChatEvent();

  @override
  List<Object?> get props => [];
}

/// Open the group conversation: resolve the local drift room, pull the REST
/// delta, bind the message stream and start the realtime subscription.
class OpenGroupChatEvent extends GroupChatEvent {
  final GroupEntity group;

  const OpenGroupChatEvent(this.group);

  @override
  List<Object?> get props => [group];
}

/// Leave the conversation (close realtime subscription, cancel stream).
class CloseGroupChatEvent extends GroupChatEvent {
  const CloseGroupChatEvent();
}

/// Internal: a new window of messages arrived from the drift stream.
class GroupMessagesUpdatedEvent extends GroupChatEvent {
  final List<Message> messages;

  const GroupMessagesUpdatedEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Send an optimistic text message (and any reply target currently set).
class SendGroupMessageEvent extends GroupChatEvent {
  final String body;

  const SendGroupMessageEvent(this.body);

  @override
  List<Object?> get props => [body];
}

/// Re-queue a failed message for another delivery attempt.
class RetryGroupMessageEvent extends GroupChatEvent {
  final String clientUuid;

  const RetryGroupMessageEvent(this.clientUuid);

  @override
  List<Object?> get props => [clientUuid];
}

/// Load the next older keyset page (pull-to-top / scroll-to-end pagination).
class LoadOlderGroupMessagesEvent extends GroupChatEvent {
  const LoadOlderGroupMessagesEvent();
}

/// Mark the conversation read up to the newest seen seq (clears unread + posts
/// the read receipt to the backend).
class MarkGroupReadEvent extends GroupChatEvent {
  const MarkGroupReadEvent();
}

/// Delete a group message for everyone (own message, or anyone's for
/// owner/admin — the server is the guard). Marks the local row deletedForAll
/// optimistically and enqueues the server delete on the outbox.
class DeleteGroupMessageEvent extends GroupChatEvent {
  final int serverMessageId;

  const DeleteGroupMessageEvent(this.serverMessageId);

  @override
  List<Object?> get props => [serverMessageId];
}

/// Set / clear the reply target.
class SetGroupReplyEvent extends GroupChatEvent {
  final Message? replyTo;

  const SetGroupReplyEvent(this.replyTo);

  @override
  List<Object?> get props => [replyTo];
}

/// Internal: a `group_updated` realtime signal arrived for the open room. Merges
/// the non-sensitive metadata onto state.group in-place (header + post gate).
class GroupMetaUpdatedEvent extends GroupChatEvent {
  final Map<String, dynamic> payload;

  const GroupMetaUpdatedEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}
