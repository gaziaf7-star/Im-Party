part of 'invite_bloc.dart';

abstract class BaseInviteEvent {}

class SendCodeEvent extends BaseInviteEvent {
  final String code;
  SendCodeEvent({required this.code});

}

class GetMyEarnInviteEvent extends BaseInviteEvent {

  GetMyEarnInviteEvent();
}

class GetInviteUserEvent extends BaseInviteEvent {

  GetInviteUserEvent();
}

class GetEarnInviteUserEvent extends BaseInviteEvent {

  GetEarnInviteUserEvent();
}

class ExplainInviteEvent extends BaseInviteEvent {

  ExplainInviteEvent();
}

class AddInviteEvent extends BaseInviteEvent {
  final String code;
  AddInviteEvent({required this.code});
}

class ExtractInviteCoinsEvent extends BaseInviteEvent {
  ExtractInviteCoinsEvent();
}

class ClaimInviteBonusEvent extends BaseInviteEvent {
  ClaimInviteBonusEvent();
}