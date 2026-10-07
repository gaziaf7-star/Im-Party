
import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class BaseAddRoomBackgroundEvent extends Equatable {
  const BaseAddRoomBackgroundEvent();

  @override
  List<Object> get props => [];
}

class AddRoomBackgroundEvent extends BaseAddRoomBackgroundEvent{
 final File roomBackGround ; 
 const AddRoomBackgroundEvent({required this.roomBackGround});
}