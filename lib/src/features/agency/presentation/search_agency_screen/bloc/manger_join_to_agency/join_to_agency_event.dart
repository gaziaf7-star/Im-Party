
part of 'join_to_agency_bloc.dart';

abstract class BaseJoinToAgencyEvent extends Equatable {
  const BaseJoinToAgencyEvent();

  @override
  List<Object> get props => [];
}

class JoinToAgencyEvent extends BaseJoinToAgencyEvent{
    final String agencyId;
  final BuildContext context;
  const JoinToAgencyEvent({
    required this.agencyId,
    required this.context,
   });
}