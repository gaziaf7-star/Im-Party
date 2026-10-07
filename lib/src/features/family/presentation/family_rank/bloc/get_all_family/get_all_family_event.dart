part of 'get_all_family_bloc.dart';

@immutable
abstract class GetAllFamilyEvent {
  const GetAllFamilyEvent();

  List<Object?> get props => [];
}

class GetFamilyEvent extends GetAllFamilyEvent {
  const GetFamilyEvent();
}

class UsersViewEvent extends GetAllFamilyEvent {
  final int tabBarIndex;
  const UsersViewEvent({this.tabBarIndex = 0});
}
