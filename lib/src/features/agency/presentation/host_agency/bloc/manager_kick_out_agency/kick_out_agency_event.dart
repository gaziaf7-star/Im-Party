part of 'kick_out_agency_bloc.dart';

abstract class KickOutAgencyBaseEvent extends Equatable {
  const KickOutAgencyBaseEvent();
  @override
  List<Object?> get props => [];
}

class KickOutAgencyEvent extends KickOutAgencyBaseEvent {
  final String userId;
  final BuildContext context;
  const KickOutAgencyEvent({
    required this.userId,
    required this.context,
  });

  @override
  List<Object?> get props => [userId];
}
