import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:general/src/features/room/data/model/enter_room_model.dart';

abstract class ShareRoomEvent extends Equatable {
  const ShareRoomEvent();
  @override
  List<Object?> get props => [];
}

class InitializeShareRoom extends ShareRoomEvent {
  final String secretKey;
  const InitializeShareRoom({required this.secretKey});
}

class ToggleSelectAllRoom extends ShareRoomEvent {}

class ToggleSelectionRoom extends ShareRoomEvent {
  final int userId;
  const ToggleSelectionRoom(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SearchUsersRoom extends ShareRoomEvent {
  final String keyword;
  const SearchUsersRoom(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class LoadMoreUsersRoom extends ShareRoomEvent {}

class ShareRoom extends ShareRoomEvent {
  final BuildContext context;
  final EnterRoomModel roomModel;
  const ShareRoom(this.context, this.roomModel);
  @override
  List<Object?> get props => [context, roomModel];
}
