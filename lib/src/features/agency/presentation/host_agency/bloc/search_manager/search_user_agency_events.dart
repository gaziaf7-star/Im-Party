part of'search_user_agency_bloc.dart';

abstract class SearchUserAgencyEvents extends Equatable{
const SearchUserAgencyEvents();
}

class SearchUserEvent extends SearchUserAgencyEvents {
  final String id;

  const SearchUserEvent({required this.id});

  @override
  List<Object?> get props => [id,];
}
class SearchAgencyEvent extends SearchUserAgencyEvents {
  final String id;

  const SearchAgencyEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ToggleSearchContainerVisibility extends SearchUserAgencyEvents {
  final bool isVisible;

  const ToggleSearchContainerVisibility(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}

class UserSelectedEvent extends SearchUserAgencyEvents {
  final SearchUserAgencyParam? param;
  final String? amount;

  const UserSelectedEvent({this.param,this.amount});

  @override
  List<Object?> get props => [param,amount];
}






