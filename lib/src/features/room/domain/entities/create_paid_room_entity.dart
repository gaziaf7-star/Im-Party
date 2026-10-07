import 'package:equatable/equatable.dart';

class CreatePaidRoomEntity extends Equatable {
  final bool isPaidRoom;
  final String paidRoomAmount;

  const CreatePaidRoomEntity(
      {required this.isPaidRoom, required this.paidRoomAmount});

  @override
  List<Object> get props => [isPaidRoom, paidRoomAmount];
}
