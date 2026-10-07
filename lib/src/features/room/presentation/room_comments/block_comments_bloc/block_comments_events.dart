part of 'block_comments_bloc.dart';

abstract class BlockCommentsEvents extends Equatable {
  const BlockCommentsEvents();

  @override
  List<Object?> get props => [];
}

class BlockEvent extends BlockCommentsEvents {
  final String ownerId;
  final String roomId;
  final bool value;
  const BlockEvent({
    required this.ownerId,
    required this.roomId,
    required this.value,
  });

  @override
  List<Object?> get props => [ownerId, roomId, value];
}
