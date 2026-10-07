part of 'get_user_profile_bloc.dart';

abstract class BaseGetUserProfileEvent extends Equatable {
  const BaseGetUserProfileEvent();
}

class GetUserProfileEvent extends BaseGetUserProfileEvent {
  final bool isFirstLoading;
  final String? page;
  const GetUserProfileEvent({
    this.isFirstLoading = false,
    this.page,
  });
  @override
  List<Object?> get props => [isFirstLoading, page];
}

final class AddListenerUsersProfileEvent extends BaseGetUserProfileEvent {
  const AddListenerUsersProfileEvent();

  @override
  List<Object?> get props => [];
}

final class RemoveListenerUsersProfileEvent extends BaseGetUserProfileEvent {
  const RemoveListenerUsersProfileEvent();

  @override
  List<Object?> get props => [];
}
