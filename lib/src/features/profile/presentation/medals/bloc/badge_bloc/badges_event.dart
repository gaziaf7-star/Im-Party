part of 'badges_bloc.dart';

abstract class BadgesEvent extends Equatable {
  const BadgesEvent();

  @override
  List<Object?> get props => const [];
}

class RechargeEvent extends BadgesEvent {
  final bool? isLoading;
  const RechargeEvent({this.isLoading});
  @override
  List<Object?> get props => [];
}

class ActivityEvent extends BadgesEvent {
  final bool? isLoading;
  const ActivityEvent({this.isLoading});
  @override
  List<Object?> get props => [];
}

class RoomEvent extends BadgesEvent {
  final bool? isLoading;
  const RoomEvent({this.isLoading});

  @override
  List<Object?> get props => [];
}

class GiftEvent extends BadgesEvent {
  final bool? isLoading;
  const GiftEvent({this.isLoading});

  @override
  List<Object?> get props => [];
}

class GetMyAllBadges extends BadgesEvent {
  final String? id;
  final bool force;
  const GetMyAllBadges({this.id, this.force = false});
}

class ChangeAppBarUIMedalsEvent extends BadgesEvent {
  final int index;
  const ChangeAppBarUIMedalsEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class ChangeMyMedalsAppBarUIEvent extends BadgesEvent {
  final int index;
  const ChangeMyMedalsAppBarUIEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class SelectedAcheivementEvent extends BadgesEvent {
  final int index;
  final String type;
  const SelectedAcheivementEvent({required this.index, required this.type});

  @override
  List<Object?> get props => [index];
}
