import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_bloc/moment_bloc.dart';

abstract class MomentCommentEvent extends Equatable {
  const MomentCommentEvent();

  @override
  List<Object?> get props => const [];
}

class FetchMomentComment extends MomentCommentEvent {
  final String page;
  final String momentId;
  final bool? isLoading;
  const FetchMomentComment(
      {required this.page, this.isLoading = true, required this.momentId});
}

class AddMomentComment extends MomentCommentEvent {
  final String momentId;
  final String comment;
  final MomentType type;
  final MomentBloc momentBloc;

  const AddMomentComment(
      {required this.momentId,
      required this.comment,
      required this.type,
      required this.momentBloc});
}

class DeleteMomentComment extends MomentCommentEvent {
  final String momentId;
  final String commentId;
  const DeleteMomentComment({required this.momentId, required this.commentId});
}

class AddListenerCommentEvent extends MomentCommentEvent {
  final String momentId;

  const AddListenerCommentEvent({
    required this.momentId,
  });
}

class RemoveListenerCommentEvent extends MomentCommentEvent {
  final String momentId;
  const RemoveListenerCommentEvent({
    required this.momentId,
  });
}
