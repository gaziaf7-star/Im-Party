
import 'package:equatable/equatable.dart';

abstract class BaseGetUserSupporterEvent extends Equatable{
  const BaseGetUserSupporterEvent();

  @override
  List<Object> get props => [];}

class GetUserSupporterEvent extends BaseGetUserSupporterEvent {
  final String userId;
  const GetUserSupporterEvent({required this.userId});
}


