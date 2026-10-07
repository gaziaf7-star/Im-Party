import 'package:equatable/equatable.dart';

abstract class GetUserBadgesEvent extends Equatable {
  const GetUserBadgesEvent();

  @override
  List<Object?> get props => [];
}

class GetUserBadgesData extends GetUserBadgesEvent {
  final int id;
  const GetUserBadgesData({required this.id});

  @override
  List<Object?> get props => [id];
}