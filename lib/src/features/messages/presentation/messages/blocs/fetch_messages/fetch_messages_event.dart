part of 'fetch_messages_bloc.dart';

abstract class BaseFetchMessagesEvent extends Equatable {
  const BaseFetchMessagesEvent();

  @override
  List<Object?> get props => [];
}

final class FetchMessagesEvent extends BaseFetchMessagesEvent {
  final FetchMessagesParamsUC params;
  final bool isLoading;
  final bool isFirstPage;

  const FetchMessagesEvent(
      {required this.params, this.isLoading = true, this.isFirstPage = false});
  @override
  List<Object?> get props => [params, isLoading, isFirstPage];
}

final class AddListenerEvent extends BaseFetchMessagesEvent {
  final FetchMessagesParamsUC params;
  const AddListenerEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

final class RemoveListenerEvent extends BaseFetchMessagesEvent {
  final FetchMessagesParamsUC params;
  const RemoveListenerEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Re-sends a previously-failed local message. Carries the original payload so
/// the bloc can re-fire the same send pipeline (text-only for now).
final class RetrySendMessageEvent extends BaseFetchMessagesEvent {
  final MessagesEntity failedMessage;
  final String peerUserId;
  final bool? isNotFriend;
  const RetrySendMessageEvent({
    required this.failedMessage,
    required this.peerUserId,
    this.isNotFriend,
  });

  @override
  List<Object?> get props => [failedMessage, peerUserId, isNotFriend];
}

final class CloseMessagesEvent extends BaseFetchMessagesEvent {
  const CloseMessagesEvent();
}

final class FinishUploadingVideoEvent extends BaseFetchMessagesEvent {
  final String videoId;
  final String userId;

  const FinishUploadingVideoEvent({
    required this.videoId,
    required this.userId,
  });

  @override
  List<Object?> get props => [videoId, userId];
}

final class LocalDeleteMessagesEvent extends BaseFetchMessagesEvent {
  final FetchMessagesParamsUC params;

  /// Whether the user chose "delete for everyone" (vs "delete for me"). Drives
  /// both the local [MessageDeleteState] written to drift and the server delete
  /// endpoint, so the choice is honored instead of always defaulting to for-me.
  final bool forEveryone;

  const LocalDeleteMessagesEvent({required this.params, this.forEveryone = false});
  @override
  List<Object?> get props => [params, forEveryone];
}

final class LocalUpdateReactMessagesEvent extends BaseFetchMessagesEvent {
  final String reactType;

  /// The reacted message's server id. Carried on the event so the handler does
  /// not depend on the app-bar selection (which is cleared right after the tap).
  final int? messageId;

  const LocalUpdateReactMessagesEvent({required this.reactType, this.messageId});
  @override
  List<Object?> get props => [reactType, messageId];
}

/// Internal: a fresh newest-first window pushed by the drift stream when the
/// realtime/offline transport is active. Carries drift rows the bloc maps to
/// [MessagesEntity] for the UI. Never dispatched by the UI directly.
final class RealtimeMessagesUpdatedEvent extends BaseFetchMessagesEvent {
  final List<db.Message> messages;
  const RealtimeMessagesUpdatedEvent(this.messages);
  @override
  List<Object?> get props => [messages];
}

/// Clears the search-jump target after the page has scrolled to it, so a stream
/// re-render (or reopening the chat) doesn't re-trigger or stick the jump.
/// `copyWith` can't null these fields, so the handler rebuilds the state.
final class ClearJumpTargetEvent extends BaseFetchMessagesEvent {
  const ClearJumpTargetEvent();
}
