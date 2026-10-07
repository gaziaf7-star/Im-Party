import 'package:equatable/equatable.dart';

abstract class SearchEvents extends Equatable{
  final int currentIndex;
const SearchEvents(  {this.currentIndex = 0});
  @override
  List<Object?> get props => [
    currentIndex,
  ];
}

class SearchEvent extends SearchEvents {
  final String keyWord;
  final bool? isFriend;
  final String? page;
  final bool? loading;
  // When true the request is a pagination fetch (append next page) instead of a
  // fresh first-page search (replace).
  final bool isLoadMore;


  const SearchEvent({
    required this.keyWord,
    this.isFriend,
    this.page,
    this.loading,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [keyWord, isFriend, page, loading, isLoadMore];
}

class SearchFriendsEvent extends SearchEvents {
  final String keyWord;
  final String? page;
  final bool isLoadMore;

  const SearchFriendsEvent({
    required this.keyWord,
    this.page,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [keyWord, page, isLoadMore];
}

class SearchAddListenerEvent extends SearchEvents {
  const SearchAddListenerEvent();
}

class SearchRemoveListenerEvent extends SearchEvents {
  const SearchRemoveListenerEvent();
}

class FriendsSearchAddListenerEvent extends SearchEvents {
  const FriendsSearchAddListenerEvent();
}

class FriendsSearchRemoveListenerEvent extends SearchEvents {
  const FriendsSearchRemoveListenerEvent();
}

class ToggleSearchContainerVisibility extends SearchEvents {
  final bool isVisible;

  const ToggleSearchContainerVisibility(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}

class UserSelectedEvent extends SearchEvents {
  final String userId;

  const UserSelectedEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}


final class ChangeCurrentIndexEvent extends SearchEvents {
  const ChangeCurrentIndexEvent({super.currentIndex});
}


