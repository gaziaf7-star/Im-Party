import 'package:general/src/features/auth/data/model/manager_type_model.dart';
import 'package:general/src/features/games/domain/entities/user_top_entity.dart';

import '../../../../core/utils/methods.dart';
import '../../../auth/data/model/my_data_model.dart';

class UserTopModel extends UserTopEntity {
  const UserTopModel(
      {super.exp,
      super.userId,
      super.colorName,
      super.flag,
      super.avatar,
      super.levelVip,
      super.dataAchievement,
      super.senderLevel,
      super.receiverLevel,
      super.name,
      super.frame,
      super.frameId,
      super.userType,
      super.managerTypeEntity,
      super.vipLevel,
      super.senderImage,
      super.gender,
      super.receiverImage,
      super.vipLevelImage,
      super.roomEntity});

  factory UserTopModel.fromJson(Map<String, dynamic> jsonData) {
    return UserTopModel(
      exp: parseValue<String>(jsonData['exp'], '0'),
      userId: parseValue<int>(jsonData['user_id'], 0),
      avatar: (jsonData['avatar'] == null || jsonData['avatar'] == "")
          ? "tic_logo.jpg"
          : parseValue<String>(jsonData['avatar'], "tic_logo.jpg"),
      name: parseValue<String>(jsonData['name'], ""),
      frame: parseValue<String>(jsonData['frame'], ""),
      frameId: parseValue<int>(jsonData['frame_id'], 1),
      vipLevel: parseValue<int>(jsonData['vip_level'], 0),
      senderImage: parseValue<String>(jsonData['sender_level_img'], ""),
      vipLevelImage: parseValue<String>(jsonData['vip_level_img'], ""),
      flag: jsonData['country'] != null
          ? parseValue<String>(jsonData['country']['flag'], '')
          : '',
      gender: parseValue<String>(jsonData['gender'], ''),
      receiverImage: parseValue<String>(jsonData['reciver_level_img'], ''),
      receiverLevel: parseValue<int>(jsonData['reciver_level'], 0),
      senderLevel: parseValue<int>(jsonData['sender_level'], 0),
      userType: parseValue<int>(jsonData['type_user'], 0),
      levelVip: jsonData['vip'] != null
          ? parseValue<int>(jsonData['vip']['level'], 0)
          : 0,
      colorName: parseValue<String>(jsonData['color_name'], ''),
      dataAchievement: jsonData['achievement_images'] != null
          ? List<DataAchievement>.from(jsonData['achievement_images']
              .map((x) => DataAchievement.fromJason(x)))
          : null,
      managerTypeEntity: jsonData["manger_type"] != null
          ? ManagerTypeModel.fromJson(jsonData["manger_type"])
          : null,
      roomEntity: jsonData["room"] != null
          ? MyRoomModel.fromJson(jsonData["room"])
          : null,
    );
  }
}

class DataAchievement extends AchievementDataEntity {
  const DataAchievement({super.image});

  factory DataAchievement.fromJason(Map<String, dynamic> jason) {
    return DataAchievement(image: parseValue<String>(jason['image'], ''));
  }
}
