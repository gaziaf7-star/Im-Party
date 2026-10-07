part of'privacy_policy_bloc.dart';

abstract class BasePrivacyPolicyEvent extends Equatable {
  const BasePrivacyPolicyEvent();

  @override
  List<Object> get props => [];
}

class PrivacyPolicyEvent extends BasePrivacyPolicyEvent {}
