import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:general/src/features/reels/domain/entities/reel_entity.dart';

abstract class ShareReelEvent extends Equatable {
  const ShareReelEvent();
  @override
  List<Object?> get props => [];
}

class InitializeShareReel extends ShareReelEvent {
 final String seckretKey;
  const InitializeShareReel({required this.seckretKey});
}

class ToggleSelectAll extends ShareReelEvent {}

class ToggleSelection extends ShareReelEvent {
  final int userId;
  const ToggleSelection(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SearchUsers extends ShareReelEvent {
  final String keyword;
  const SearchUsers(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class LoadMoreUsers extends ShareReelEvent {}

class ShareReel extends ShareReelEvent {
  final BuildContext context;
  final ReelsEntity reelModel;
  const ShareReel(this.context, this.reelModel);
  @override
  List<Object?> get props => [context, reelModel];
}
