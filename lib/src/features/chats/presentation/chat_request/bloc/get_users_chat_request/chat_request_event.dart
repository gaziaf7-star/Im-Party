part of 'chat_request_bloc.dart';



abstract class BaseFetchChatRequestEvent extends Equatable {
  const BaseFetchChatRequestEvent();
}

class GetChatRequestUsersEvent extends BaseFetchChatRequestEvent {
  final bool isLoading;
   const GetChatRequestUsersEvent({this.isLoading = true,});
  @override
  List<Object?> get props => [isLoading];
}

class UpdateDataLocally extends BaseFetchChatRequestEvent {
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

class ReadMessageEvent extends BaseFetchChatRequestEvent {
  final int chatId;

   const ReadMessageEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class RemoveLocalLastMessageEvent extends BaseFetchChatRequestEvent {
  final int chatId;
  final int messageId;

   const RemoveLocalLastMessageEvent({required this.chatId, required this.messageId,});
  @override
  List<Object?> get props => [chatId, messageId];
}

class RemoveLocalChatRequestUserEvent extends BaseFetchChatRequestEvent {
  final int? chatId;
   const RemoveLocalChatRequestUserEvent({this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class UpdateTotalMessagesRequest extends BaseFetchChatRequestEvent {
  final String? userId;
  final int? counterMessage;
  final bool isIncreased;
   const UpdateTotalMessagesRequest({this.userId,required this.isIncreased,this.counterMessage});
  @override
  List<Object?> get props => [userId,isIncreased,counterMessage];
}
