part of 'leave_agency_bloc.dart';

abstract class BaseLeaveAgencyEvent extends Equatable {
  const BaseLeaveAgencyEvent();
  @override
  List<Object?> get props => const [];
}

class LeaveAgencyEvent extends BaseLeaveAgencyEvent {
  final BuildContext context;
  const LeaveAgencyEvent({

    required this.context,

});
}
