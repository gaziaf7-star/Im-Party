import 'package:general/src/features/room/data/model/background_model.dart';
import 'package:equatable/equatable.dart';

abstract class OnRoomStates extends Equatable {
  const OnRoomStates();

  @override
  List<Object?> get props => [];
}

class OnRoomInitialState extends OnRoomStates {
  const OnRoomInitialState();
}

class OnRoomLoadingState extends OnRoomStates {
  const OnRoomLoadingState();
}

class GetBackGroundloadingState extends OnRoomStates {}

class GetBackGroundErrorState extends OnRoomStates {
  final String message;
  const GetBackGroundErrorState({required this.message});
}

class GetBackGroundSucsseState extends OnRoomStates {
  final List<BackgroundModel> data;
  const GetBackGroundSucsseState({required this.data});
}

class RemovePassRoomLoadingState extends OnRoomStates {}

class RemovePassRoomErrorState extends OnRoomStates {
  final String message;
  const RemovePassRoomErrorState({required this.message});
}

class RemovePassRoomSucssesState extends OnRoomStates {
  final String message;
  const RemovePassRoomSucssesState({required this.message});
}

class RemoveChatRoomLoadingState extends OnRoomStates {}

class RemoveChatRoomErrorState extends OnRoomStates {
  final String message;
  const RemoveChatRoomErrorState({required this.message});
}

class RemoveChatRoomSuccessState extends OnRoomStates {}

class BanUserFromWritingLoadingState extends OnRoomStates {}

class BanUserFromWritingErrorState extends OnRoomStates {
  final String message;
  const BanUserFromWritingErrorState({required this.message});
}

class BanUserFromWritingSuccessState extends OnRoomStates {
  final String message;
  const BanUserFromWritingSuccessState({required this.message});
}

class SendPobUpLoadingState extends OnRoomStates {}

class SendPobUpErrorState extends OnRoomStates {
  final String message;
  const SendPobUpErrorState({required this.message});
}

class SendPobUpSuccessState extends OnRoomStates {
  final String message;
  const SendPobUpSuccessState({required this.message});
}

class HideRoomLoadingState extends OnRoomStates {}

class HideRoomErrorState extends OnRoomStates {
  final String message;
  const HideRoomErrorState({required this.message});
}

class HideRoomSuccessState extends OnRoomStates {
  final String message;
  const HideRoomSuccessState({required this.message});
}

class DisposeHideRoomLoadingState extends OnRoomStates {}

class DisposeHideRoomErrorState extends OnRoomStates {
  final String message;
  const DisposeHideRoomErrorState({required this.message});
}

class DisposeHideRoomSuccessState extends OnRoomStates {
  final String message;
  const DisposeHideRoomSuccessState({required this.message});
}

class SendYallowBannerLoadingState extends OnRoomStates {}

class SendYallowBannerErrorState extends OnRoomStates {
  final String message;
  const SendYallowBannerErrorState({required this.message});
}

class SendYallowBannerSuccessState extends OnRoomStates {
  final String message;
  const SendYallowBannerSuccessState({required this.message});
}

class ChangeGameModeRoomLoadingState extends OnRoomStates {}

class ChangeGameModeRoomSuccessState extends OnRoomStates {
  final String message;
  const ChangeGameModeRoomSuccessState({required this.message});
}

class ChangeGameModeRoomErrorState extends OnRoomStates {
  final String message;
  const ChangeGameModeRoomErrorState({required this.message});
}

class LockCommentsLoadingState extends OnRoomStates {}

class LockCommentsErrorState extends OnRoomStates {
  final String message;
  const LockCommentsErrorState({required this.message});
}

class LockCommentsSuccessState extends OnRoomStates {
  final String message;
  const LockCommentsSuccessState({required this.message});
}

class UnLockCommentsLoadingState extends OnRoomStates {}

class UnLockCommentsErrorState extends OnRoomStates {
  final String message;
  const UnLockCommentsErrorState({required this.message});
}

class UnLockCommentsSuccessState extends OnRoomStates {
  final String message;
  const UnLockCommentsSuccessState({required this.message});
}
