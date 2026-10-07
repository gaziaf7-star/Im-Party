part of 'get_users_chat_bloc.dart';

abstract class BaseGetChatUsersEvent extends Equatable {
  const BaseGetChatUsersEvent();
}
final class AddChatUsersListenerEvent extends BaseGetChatUsersEvent {
  final bool isLoading;
  final String? userId;
  const AddChatUsersListenerEvent({this.isLoading = true,required this.userId});
  @override
  List<Object?> get props => [isLoading,userId];

}

final class RemoveChatUsersListenerEvent extends BaseGetChatUsersEvent {
  final bool isLoading;
  final String? userId;
  const RemoveChatUsersListenerEvent({this.isLoading = true,required this.userId});
  @override
  List<Object?> get props => [isLoading,userId];
}
class GetChatUsersEvent extends BaseGetChatUsersEvent {
  final bool isLoading;
  final bool? isRefresh;
  final String? userId;
  const GetChatUsersEvent({this.isRefresh,this.isLoading = true,required this.userId});
  @override
  List<Object?> get props => [isLoading,userId,isRefresh];
}

class SearchChatUsersEvent extends BaseGetChatUsersEvent {
  final bool isLoading;
  final String? userId;
  const SearchChatUsersEvent({this.isLoading = true,required this.userId});
  @override
  List<Object?> get props => [isLoading,userId];
}

class GetMoreChatUsersEvent extends BaseGetChatUsersEvent {
  final String page;
  const GetMoreChatUsersEvent({required this.page});
  @override
  List<Object?> get props => [page];
}

class UpdateDataLocally extends BaseGetChatUsersEvent {
  final int chatId;
  final UserChatEntity userChatEntity;

  const UpdateDataLocally({
    required this.chatId,
    required this.userChatEntity,
  });
  @override
  List<Object?> get props => [
        chatId,
        userChatEntity,
      ];
}

class ReadMessageEvent extends BaseGetChatUsersEvent {
  final int chatId;
  // Optional peer userId — used as a fallback match when the chat row isn't
  // keyed by chatId yet (e.g. opening from the chats list, which only carries
  // the peer userId in MessagesParameter).
  final String? userId;

  const ReadMessageEvent({required this.chatId, this.userId});
  @override
  List<Object?> get props => [chatId, userId];
}

class RemoveLocalLastMessageEvent extends BaseGetChatUsersEvent {
  final int chatId;
  final int messageId;

  const RemoveLocalLastMessageEvent({required this.chatId, required this.messageId,});
  @override
  List<Object?> get props => [chatId, messageId];
}

class RemoveLocalChatUserEvent extends BaseGetChatUsersEvent {
  final int? chatId;
  const RemoveLocalChatUserEvent({this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class UpdateTotalMessages extends BaseGetChatUsersEvent {
  final String? userId;
  final int? counterMessage;
  final bool isIncreased;
  const UpdateTotalMessages({this.userId,required this.isIncreased,this.counterMessage});
  @override
  List<Object?> get props => [userId,isIncreased,counterMessage];
}

/// Internal event fired from the drift rooms stream (Centrifugo writes land in
/// drift). Carries the reactive DM list so the chats list updates live — the
/// sole realtime path now that legacy realtime is removed.
class MergeRoomsFromDrift extends BaseGetChatUsersEvent {
  final List<UserChatEntity> rooms;
  const MergeRoomsFromDrift(this.rooms);
  @override
  List<Object?> get props => [rooms];
}
