part of 'online_users_bloc.dart';

abstract class BaseOnlineUsersEvent extends Equatable{

  const BaseOnlineUsersEvent();
}

class GetUsersOnlineEvent extends BaseOnlineUsersEvent{
final bool isFirstLoading;
const GetUsersOnlineEvent({


  this.isFirstLoading=false,

});
  @override
  List<Object?> get props => [isFirstLoading];
}

class ChangeUserOnlineLocally extends BaseOnlineUsersEvent{
final int index;
const ChangeUserOnlineLocally({required this.index});
@override
List<Object?> get props => [index];
}

final class AddListenerOnlineUsersEvent extends BaseOnlineUsersEvent {

  const AddListenerOnlineUsersEvent();

  @override
  List<Object?> get props => [];
}

final class RemoveListenerOnlineUsersEvent extends BaseOnlineUsersEvent {

  const RemoveListenerOnlineUsersEvent();

  @override
  List<Object?> get props => [];
}