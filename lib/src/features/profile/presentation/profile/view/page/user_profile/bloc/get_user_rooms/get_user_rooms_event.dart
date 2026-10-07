import 'package:equatable/equatable.dart';

abstract class GetUserRoomsEvent extends Equatable {
  const GetUserRoomsEvent();

  @override
  List<Object> get props => [];
}

class GetUserRooms extends GetUserRoomsEvent {
  final int id;
  const GetUserRooms({required this.id});
}
