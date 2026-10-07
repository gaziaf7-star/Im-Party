part of 'delete_message_bloc.dart';

abstract class BaseDeleteMessageEvent extends Equatable {
  const BaseDeleteMessageEvent();

  @override
  List<Object?> get props => [];
}

class DeleteMessageEvent extends BaseDeleteMessageEvent {
  final String deleteType;
  final List<int> messageIds;

  const DeleteMessageEvent({
    required this.messageIds,
    required this.deleteType,
  });

  @override
  List<Object?> get props => [deleteType, messageIds];
}
