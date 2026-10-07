part of 'show_agency_bloc.dart';

abstract class BaseShowAgencyEvent extends Equatable {
  const BaseShowAgencyEvent();

  @override
  List<Object?> get props => const [];
}

class ShowAgencyEvent extends BaseShowAgencyEvent {
  final bool isFirstLoading;
  final int? agencyId;

  const ShowAgencyEvent(

      {
        this.isFirstLoading=false,
        this.agencyId=0,
      }

      );
}



class ChangeTabBarIndexEvent extends BaseShowAgencyEvent {
  final int index;
  const ChangeTabBarIndexEvent({required this.index});
}
class JoinShowAgencyLocalEvent extends BaseShowAgencyEvent {
  const JoinShowAgencyLocalEvent();

  @override
  List<Object?> get props => [];
}