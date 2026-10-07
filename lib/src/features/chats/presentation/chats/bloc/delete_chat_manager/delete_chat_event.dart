part of'delete_chat_bloc.dart';

abstract class BaseDeleteChatEvent extends Equatable{
  const BaseDeleteChatEvent();
}

class DeleteChatEvent extends BaseDeleteChatEvent {
  final int userId;

  const DeleteChatEvent({required this.userId});

  @override
  List<Object?> get props => [
    userId
  ];
}


