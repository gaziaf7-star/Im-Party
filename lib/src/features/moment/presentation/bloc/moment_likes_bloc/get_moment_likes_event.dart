import 'package:equatable/equatable.dart';

abstract class BaseGetMomentLikesEvent extends Equatable {
  const BaseGetMomentLikesEvent();

  @override
  List<Object?> get props => const [];
}


class GetMomentLikesEvent extends BaseGetMomentLikesEvent{
  final String page;
  final bool? isLoading;
  final String momentId;
  const GetMomentLikesEvent({required this.page, required this.momentId, this.isLoading});
}

class AddListenerLikeEvent extends BaseGetMomentLikesEvent {
  final String momentId;

  const AddListenerLikeEvent({required this.momentId,});
}

class RemoveListenerLikeEvent extends BaseGetMomentLikesEvent {
    final String momentId;
  const RemoveListenerLikeEvent({required this.momentId,});
}

/*
class GetMomentLikesEvent extends BaseGetMomentLikesEvent {
  final String momentId;
  const GetMomentLikesEvent({required this.momentId});

  @override
  List<Object?> get props => [momentId];
}

class GetMoreMomentLikesEvent extends BaseGetMomentLikesEvent {
  final String momentId;
  const GetMoreMomentLikesEvent({required this.momentId});

  @override
  List<Object?> get props => [momentId];
}
*/
