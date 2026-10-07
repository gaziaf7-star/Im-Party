part of 'use_un_use_bloc.dart';

sealed class BaseUseUnUseEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const BaseUseUnUseEvent();
}

class UnUseEvent extends BaseUseUnUseEvent {
  final UseUnUseBagItemParam param;
  final MallOrBagType tabType;
  const UnUseEvent({
    required this.param,
    required this.tabType,
  });
}

class UseEvent extends BaseUseUnUseEvent {
  final UseUnUseBagItemParam param;
  final MallOrBagType tabType;
  const UseEvent({
    required this.param,
    required this.tabType,
  });
}

class UseUnUseSpecialIdEvent extends BaseUseUnUseEvent {
  final UseUnUseBagItemParam param;
  final MallOrBagType tabType;
  const UseUnUseSpecialIdEvent({
    required this.param,
    required this.tabType,
  });
}

