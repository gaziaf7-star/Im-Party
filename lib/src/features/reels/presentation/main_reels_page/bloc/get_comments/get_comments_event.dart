part of 'get_comments_bloc.dart';

sealed class BaseGetCommentsEvent extends Equatable {
  const BaseGetCommentsEvent();

  @override
  List<Object?> get props => [];
}

class GetCommentsEvent extends BaseGetCommentsEvent {
  final ReelParam param;
  final bool isLoading;

  const GetCommentsEvent({required this.param,required this.isLoading});

  @override
  List<Object?> get props => [param,isLoading];
}


class LocalAddCommentsEvent extends BaseGetCommentsEvent {
  final ReelParam param;
final String type;
  const LocalAddCommentsEvent(this.param,{required this.type});

  @override
  List<Object?> get props => [param,type];
}


class AddListenerCommentEvent extends BaseGetCommentsEvent {
  final String reelId;

  const AddListenerCommentEvent({required this.reelId,});
}

class RemoveListenerCommentEvent extends BaseGetCommentsEvent {
    final String reelId;
  const RemoveListenerCommentEvent({required this.reelId,});
}
