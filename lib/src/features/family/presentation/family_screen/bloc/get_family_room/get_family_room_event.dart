part of 'get_family_room_bloc.dart';
abstract class FamilyRoomEvent extends Equatable {
  const FamilyRoomEvent();

  @override
  List<Object?> get props => const [];
}

class GetFamilyRoomEvent extends FamilyRoomEvent {
  final String familyId;
  final bool? isFirstLoading;
  const GetFamilyRoomEvent({
    required this.familyId,
  this.isFirstLoading=false
  });

  @override
  List<Object?> get props => [familyId,isFirstLoading];
}
