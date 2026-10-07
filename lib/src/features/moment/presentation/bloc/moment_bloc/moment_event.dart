import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/domain/entities/moment_entity.dart';

abstract class MomentEvent extends Equatable {
  final File? image;

  const MomentEvent({
    this.image,
  });

  @override
  List<Object?> get props => [image];
}

class FetchMomentData extends MomentEvent {
  final String? type;
  final String? userId;
  final bool? isRefresh;
  const FetchMomentData({this.type, this.isRefresh, this.userId});
}

class FetchFollowMomentData extends MomentEvent {
  final String? type;
  final String? userId;
  final bool? isRefresh;
  const FetchFollowMomentData({this.isRefresh, this.type, this.userId});
}

class FetchLatestMomentData extends MomentEvent {
  final String? type;
  final String? userId;
  final bool? isRefresh;
  const FetchLatestMomentData({this.type, this.isRefresh, this.userId});
}

class FetchMyMomentData extends MomentEvent {
  final String? type;
  final String? userId;
  const FetchMyMomentData({this.type, this.userId});
}

class FetchMoreMoments extends MomentEvent {
  final String page;
  final String type;
  const FetchMoreMoments({required this.page, required this.type});
}

class AddMomentData extends MomentEvent {
  final BuildContext context;
  final FormData data;
  final String moment;
  const AddMomentData(
      {required this.data, required this.moment, required this.context});
}

class DeleteMomentData extends MomentEvent {
  final String momentId;
  final MomentType type;
  final BuildContext context;
  const DeleteMomentData(
      {required this.momentId, required this.context, required this.type});
}

class LikeMomentData extends MomentEvent {
  final String momentId;
  const LikeMomentData({required this.momentId});
}

final class PickImageMomentEvent extends MomentEvent {
  const PickImageMomentEvent({required super.image});
}

final class RemovePickedImageEvent extends MomentEvent {
  const RemovePickedImageEvent();
}

final class InitializeFormEvent extends MomentEvent {
  const InitializeFormEvent();
}

final class RemoveMultiPickedImageEvent extends MomentEvent {
  final int element;
  final String moment;
  const RemoveMultiPickedImageEvent(
      {required this.element, required this.moment});
  @override
  List<Object?> get props => [element];
}

class UpdateIsLikeEvent extends MomentEvent {
  final int momentId;
  final bool isLike;
  final int likeNum;
  final MomentType type;

  const UpdateIsLikeEvent(
      {required this.momentId,
        required this.isLike,
        required this.likeNum,
        required this.type});

  @override
  List<Object?> get props => [momentId, isLike, likeNum, type];
}

class UpdateCommentEvent extends MomentEvent {
  final int momentId;
  final int commentsNum;
  final MomentType type;

  const UpdateCommentEvent(
      {required this.momentId, required this.commentsNum, required this.type});

  @override
  List<Object?> get props => [momentId, commentsNum, type];
}

final class PickMultiPicEvent extends MomentEvent {
  const PickMultiPicEvent();
}

class AddListenerMomentEvent extends MomentEvent {
  const AddListenerMomentEvent();
}

class AddListenerFollowMomentEvent extends MomentEvent {
  const AddListenerFollowMomentEvent();
}

class AddListenerMyMomentEvent extends MomentEvent {
  final String userID;

  const AddListenerMyMomentEvent({required this.userID});
  @override
  List<Object?> get props => [userID];
}

class AddListenerMyMomentWithoutControllerEvent extends MomentEvent {
  final String userID;

  const AddListenerMyMomentWithoutControllerEvent({required this.userID});
  @override
  List<Object?> get props => [userID];
}

class AddListenerLatestMomentEvent extends MomentEvent {
  const AddListenerLatestMomentEvent();
}

class RemoveListenerMomentEvent extends MomentEvent {
  const RemoveListenerMomentEvent();
}

class RemoveListenerMyMomentEvent extends MomentEvent {
  final String userID;

  const RemoveListenerMyMomentEvent({required this.userID});
  @override
  List<Object?> get props => [userID];
}

class RemoveListenerFollowMomentEvent extends MomentEvent {
  const RemoveListenerFollowMomentEvent();
}

class RemoveListenerLatestMomentEvent extends MomentEvent {
  const RemoveListenerLatestMomentEvent();
}

class MomentFollowEvent extends MomentEvent {
  final int momentId;
  final int userID;
  final MomentEntity currentMoment;

  const MomentFollowEvent(
      {required this.momentId,
        required this.currentMoment,
        required this.userID});

  @override
  List<Object?> get props => [momentId, userID];
}

class ChangeRankIconEvent extends MomentEvent {
  final bool isAddMoment;
  const ChangeRankIconEvent({required this.isAddMoment});
}

class UpdateValidationEvent extends MomentEvent {
  final String moment;
  const UpdateValidationEvent({required this.moment});
}

class ShowEmojiPickerEvent extends MomentEvent {
  final bool showEmoji;
  const ShowEmojiPickerEvent({required this.showEmoji});
}

class ReportMomentEvent extends MomentEvent {
  final ReportMomentParam reportMomentParam;
  final BuildContext context;
  const ReportMomentEvent(
      {required this.reportMomentParam, required this.context});
}

class MomentShareEvent extends MomentEvent {
  final MomentEntity currentMoment;

  const MomentShareEvent({required this.currentMoment});

  @override
  List<Object?> get props => [currentMoment];
}
class RemoveMomentLocally extends MomentEvent{
  final int momentId;
  final MomentType type;
  const RemoveMomentLocally({required this.momentId,required this.type});

  @override
  List<Object?> get props => [momentId,type];
}

class ResetMyMomentsEvent extends MomentEvent {
  const ResetMyMomentsEvent();
}
