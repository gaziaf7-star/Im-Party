import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/entities/carousel_entity.dart';

class CarouselModel extends CarouselEntity {
  const CarouselModel({
    required super.id,
    required super.img,
    required super.type,
    super.url,
    super.ownerId,
    super.hasPassword,
    super.myRoomData,
    super.avatar,
    super.cpAvatar2,
    super.cpName,
    super.cpName2,
    super.eventType,
  });

  factory CarouselModel.fromJson(Map<String, dynamic> jsonData) {
    return CarouselModel(
      id: parseValue<int>(jsonData['id'], 0),
      img: parseValue<String>(jsonData['img'], ''),
      type: parseValue<String>(jsonData['type'], ''),
      url: parseValue<String>(jsonData['url'], ''),
      avatar: parseValue<String>(jsonData['avatar'], ''),
      cpAvatar2: parseValue<String>(jsonData['cp_avatar_two'], ''),
      cpName: parseValue<String>(jsonData['cp_winner_name_one'], ''),
      cpName2: parseValue<String>(jsonData['cp_winner_name_two'], ''),
      eventType: parseValue<String>(jsonData['event_type'], ''),
      ownerId: parseValue<int>(jsonData['owner_id'], 0),
      hasPassword: parseValue<bool>(jsonData['isLocked'], false),
      myRoomData: jsonData['room'] != null
          ? MyRoomModel.fromJson(jsonData['room'])
          : null,
    );
  }
}
