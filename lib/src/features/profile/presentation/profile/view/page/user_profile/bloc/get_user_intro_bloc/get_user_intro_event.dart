

import 'package:equatable/equatable.dart';

abstract class GetUserIntroEvent extends Equatable {
  const GetUserIntroEvent();

  @override
  List<Object> get props => [];
}
class GetUserIntro extends GetUserIntroEvent{
  final String id ;
  final bool force;
  const GetUserIntro({required this.id, this.force = false });

  @override
  List<Object> get props => [id, force];
}
