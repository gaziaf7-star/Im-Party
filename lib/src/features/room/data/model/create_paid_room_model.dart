import 'package:general/src/features/room/domain/entities/create_paid_room_entity.dart';
import '../../../../core/utils/methods.dart';



class CreatePaidRoomModel extends CreatePaidRoomEntity {

  const CreatePaidRoomModel({required super.isPaidRoom, required super.paidRoomAmount});

  factory CreatePaidRoomModel.fromJson(Map<String, dynamic> json) {
    return CreatePaidRoomModel(
      isPaidRoom: parseValue<bool>(json['paid_room'], false),
      paidRoomAmount: parseValue<String>(json['paid_room_amount'], ''),
    );
  }
}
