import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';

abstract class BaseGetFollowerOrFollowingEvent {
  const BaseGetFollowerOrFollowingEvent();
}

class GetFriendsEvent extends BaseGetFollowerOrFollowingEvent {
  final bool loading;
  final String keyWord;
  const GetFriendsEvent({this.loading=false,this.keyWord=''});
}

class GetFriendsRequestEvent extends BaseGetFollowerOrFollowingEvent {
  final bool loading;
  final String keyWord;
  const GetFriendsRequestEvent({this.loading=false,this.keyWord=''});
}

class GetFollowersEvent extends BaseGetFollowerOrFollowingEvent {
  final bool loading;
  final String keyWord;

  const GetFollowersEvent({this.loading=false,this.keyWord=''});
}

class GetFollowersThemEvent extends BaseGetFollowerOrFollowingEvent {
  final bool loading;
  final String keyWord;

  const GetFollowersThemEvent({this.loading=false,this.keyWord=''});
}




class GetVisitorsEvent extends BaseGetFollowerOrFollowingEvent {
  final bool loading;
  final String keyWord;
  const GetVisitorsEvent({this.loading=false,this.keyWord=''});
}

class AddListenerVisitorsEvent extends BaseGetFollowerOrFollowingEvent {
  AddListenerVisitorsEvent();
}

class RemoveListenerVisitorsEvent extends BaseGetFollowerOrFollowingEvent {
  RemoveListenerVisitorsEvent();
}

class AddListenerFriendsEvent extends BaseGetFollowerOrFollowingEvent {
  AddListenerFriendsEvent();
}
class AddListenerFriendsRequestEvent extends BaseGetFollowerOrFollowingEvent {
  AddListenerFriendsRequestEvent();
}

class RemoveListenerFriendsEvent extends BaseGetFollowerOrFollowingEvent {
  RemoveListenerFriendsEvent();
}

class RemoveListenerFriendsRequestEvent extends BaseGetFollowerOrFollowingEvent {
  RemoveListenerFriendsRequestEvent();
}

class AddListenerFollowersEvent extends BaseGetFollowerOrFollowingEvent {
  AddListenerFollowersEvent();
}

class RemoveListenerFollowersEvent extends BaseGetFollowerOrFollowingEvent {
  RemoveListenerFollowersEvent();
}

class AddListenerFollowingEvent extends BaseGetFollowerOrFollowingEvent {
  AddListenerFollowingEvent();
}

class RemoveListenerFollowingEvent extends BaseGetFollowerOrFollowingEvent {
  RemoveListenerFollowingEvent();
}

class MakeFollowLocallyEvent extends BaseGetFollowerOrFollowingEvent {
  final RelationType relationType;
  final String userId;
final UserModel? userModel;
  const MakeFollowLocallyEvent({
    required this.userId,
     this.userModel,
    required this.relationType,
  });
}

class MakeUnfollowLocallyEvent extends BaseGetFollowerOrFollowingEvent {
  final RelationType relationType;
  final String userId;

  const MakeUnfollowLocallyEvent({
    required this.userId,
    required this.relationType,
  });
}

class ChangeAppBarTitleEvent extends BaseGetFollowerOrFollowingEvent {
  final String title;

  const ChangeAppBarTitleEvent({
    required this.title,
  });
}
class RemoveUserEvent extends BaseGetFollowerOrFollowingEvent{
  final RelationType relationType;
  final String userId;

  RemoveUserEvent({required this.relationType,required this.userId,
  });

}