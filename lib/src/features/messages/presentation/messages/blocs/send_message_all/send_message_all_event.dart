
part of 'send_message_all_bloc.dart';

abstract class BaseSendMessageAllEvent extends Equatable {
  const BaseSendMessageAllEvent();
  
  @override
  List<Object?> get props => [];
}

class SendMessageAllEvent extends BaseSendMessageAllEvent {
  final String? users;
  final String? message;
  final String? url;
  final String? exceptUsers;
  final String? type;

  const SendMessageAllEvent({
    this.users,
    this.message,
    this.url,
    this.exceptUsers,
    this.type,
  });

  @override
  List<Object?> get props => [users, message, url, exceptUsers, type];
}