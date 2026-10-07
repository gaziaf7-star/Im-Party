part of 'make_comments_bloc.dart';

sealed class BaseMakeCommentsEvent extends Equatable {
  const BaseMakeCommentsEvent();

  @override
  List<Object?> get props => [];
}

class MakeCommentsEvent extends BaseMakeCommentsEvent {
  final ReelParam param;
  final ReelsType filter;
  final GetReelsBloc getReelsBloc;

  const MakeCommentsEvent(
    this.param,
    this.filter,
    this.getReelsBloc,
  );

  @override
  List<Object?> get props => [param, filter, getReelsBloc];
}
