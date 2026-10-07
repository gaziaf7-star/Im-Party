part of 'get_agency_badges_bloc.dart';

abstract class BaseAgencyBadgesEvent extends Equatable {
  const BaseAgencyBadgesEvent();
  @override
  List<Object?> get props => [];
}

final class GetAgencyBadgesEvent extends BaseAgencyBadgesEvent {}
