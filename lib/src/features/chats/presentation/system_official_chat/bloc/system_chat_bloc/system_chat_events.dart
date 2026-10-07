part of 'system_chat_bloc.dart';
abstract class SystemChatEvents extends Equatable {
  const SystemChatEvents();

  @override
  List<Object?> get props => [];
}



class GetSystemChatEvent extends SystemChatEvents {
  final bool isLoading;
  const GetSystemChatEvent({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

class GetOfficialChatEvent extends SystemChatEvents {
  final bool isLoading;
  const GetOfficialChatEvent({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

class LoadMoreSystemChatEvent extends SystemChatEvents {}

class LoadMoreOfficialChatEvent extends SystemChatEvents {}


