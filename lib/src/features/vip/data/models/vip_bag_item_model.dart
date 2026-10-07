import 'package:general/src/features/vip/domain/entity/vip_bag_item_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class VipBagItemModel extends VipBagItemEntity {
  const VipBagItemModel(
      {super.targetId,
      super.isBuyed,
      super.isUsed,
      super.using,
      super.expire,
      super.remainingTime,
      super.vip});

  factory VipBagItemModel.fromJson(Map<String, dynamic> json) {
    return VipBagItemModel(
      targetId: parseValue<int>(json['target_id'],0),
      isBuyed: parseValue<bool>(json['is_buyed'], false),
      isUsed: parseValue<bool>(json['is_used'], false),
      using:parseValue<bool>(json['using'], false) ,
      expire: parseValue<String>(json['expire'],''),
      remainingTime: parseValue<String>(json['remaining_time'],''),
      vip: json['vip'] is Map<String, dynamic> ? Vip.fromJson(json['vip']) : null,
    );
  }
}

class Vip extends VipEntity {
  Vip(
      {super.id,
      super.level,
      super.sort,
      super.name,
      super.img,
      super.price,
      super.expire,
      super.exp,
      super.privilegs});

  factory Vip.fromJson(Map<String, dynamic> json) {
    return Vip(
      id: parseValue<int>(json['id'],0),
      level: parseValue<int>(json['level'],0),
      sort:parseValue<int>(json['sort'],0) ,
      name:  parseValue<String>(json['name'],''),
      img:  parseValue<String>(json['img'],''),
      price:parseValue<int>( json['price'],0),
      expire: parseValue<int>(json['expire'],0),
      exp:parseValue<int>( json['exp'],0),
      privilegs: json['privilegs'] is List
          ? (json['privilegs'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => Privilegs.fromJson(i))
              .toList()
          : null,
    );
  }
}

class Privilegs extends PrivilegsEntity {
  Privilegs(
      {super.id,
      super.name,
      super.active,
      super.type,
      super.title,
      super.img1,
      super.img2,
      super.item});

  factory Privilegs.fromJson(Map<String, dynamic> json) {
    return Privilegs(
      id: parseValue<int>(json['id'],0),
      name: parseValue<String>(json['name'],''),
      active:parseValue<bool>(json['active'], false) ,
      type: parseValue<int>(json['type'],0),
      title:parseValue<String>(json['title'],'') ,
      img1: parseValue<String>(json['img1'],''),
      img2:parseValue<String>(json['img2'],'') ,
      item: json['item'] is Map<String, dynamic> ? Item.fromJson(json['item']) : null,
    );
  }
}

class Item extends ItemEntity {
  Item({
    super.id,
    super.name,
    super.title,
    super.price,
    super.color,
    super.expire,
    super.image,
    super.img,
    super.svg,
    super.video,
    super.imageType,
    super.type,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: parseValue<int>(json['id'],0),
      name:parseValue<String>(json['name'],'') ,
      title: parseValue<String>(json['title'],''),
      price: parseValue<int>(json['price'],0),
      color:parseValue<String>(json['color'],'') ,
      expire:parseValue<int>(json['expire'],0) ,
      image: parseValue<String>(json['image'],''),
      img: parseValue<String>(json['img'],''),
      svg: parseValue<String>(json['svg'],''),
      video:parseValue<String>(json['video'],'') ,
      imageType: parseValue<String>(json['image_type'],''),
      type:parseValue<int>(json['type'],0) ,
    );
  }
}
