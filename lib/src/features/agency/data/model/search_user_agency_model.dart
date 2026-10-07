import 'package:general/src/features/agency/data/model/charge_agency_info_model.dart';
import 'package:general/src/features/agency/data/model/shipping_agents_full_data.dart';
import 'package:general/src/features/auth/auth.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class MainResponseModel extends Equatable {
  final List<Agency> agency;
  final List<User> user;

  const MainResponseModel({required this.agency, required this.user});

  factory MainResponseModel.fromJson(Map<String, dynamic> json) {
    return MainResponseModel(
      agency: (json['agency'] is List ? json['agency'] as List : const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Agency.fromJson(e))
          .toList(),
      user: (json['user'] is List ? json['user'] as List : const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => User.fromJson(e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [agency, user];
}

class Agency extends Equatable {
  final int id;
  final String name;
  final String image;
  final Owner owner;

  const Agency({
    required this.id,
    required this.name,
    required this.image,
    required this.owner,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      owner: json['owner'] is Map<String, dynamic>
          ? Owner.fromJson(json['owner'])
          : Owner.fromJson(const {}),
    );
  }

  ShippingAgentsFullDataModel toShippingAgent() {
    return ShippingAgentsFullDataModel(
      id: id,
      ownerId: owner.id,
      ownerImage: owner.owmnerImage,
      ownerName: owner.name,
      name: name,
      phone: owner.phone,
      image: image,
      uuid: owner.uuid,
      paymentGetaway: owner.paymentGetaway
          .map((e) => PaymentsGetwaysModel.fromJson(e))
          .toList(),
      countries: owner.countries.map((e) => CountryModel.fromJson(e)).toList(),
      frame: owner.frame,
      frameId: owner.frameId,
      level: owner.level,
      vip: owner.vip,
      chargeCount: owner.chargeCount,
      idImage: '',
      specialId: '', // If needed
    );
  }

  @override
  List<Object?> get props => [id, name, image, owner];
}

class Owner extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String image;
  final String owmnerImage;
  final String uuid;
  final List<dynamic> paymentGetaway;
  final List<dynamic> countries;
  final String frame;
  final int frameId;
  final int level;
  final dynamic vip;
  final int chargeCount;

  const Owner({
    required this.id,
    required this.name,
    required this.phone,
    required this.image,
    required this.owmnerImage,
    required this.uuid,
    required this.paymentGetaway,
    required this.countries,
    required this.frame,
    required this.frameId,
    required this.level,
    required this.vip,
    required this.chargeCount,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      phone: parseValue<String>(json['phone'], ''),
      image: parseValue<String>(json['image'], ''),
      owmnerImage: parseValue<String>(json['owner_image'], ''),
      uuid: parseValue<String>(json['uuid'], ''),
      paymentGetaway: parseValue<List<dynamic>>(json['payment_getaway'], []),
      countries: parseValue<List<dynamic>>(json['countries'], []),
      frame: parseValue<String>(json['frame'], ''),
      frameId: parseValue<int>(json['frame_id'], 0),
      level: parseValue<int>(json['level'], 0),
      vip: json['vip'] ?? 0,
      chargeCount: parseValue<int>(json['charge_count'], 0),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        image,
        uuid,
        paymentGetaway,
        countries,
        frame,
        frameId,
        level,
        vip,
        chargeCount
      ];
}

class User extends Equatable {
  final int id;
  final String uuid;
  final String name;
  final String image;
  final String coloredName;
  final LevelModel level;
  final String? idImage;
  final ImageColorEntity? imageColorEntity;

  const User({
    required this.id,
    required this.uuid,
    required this.name,
    required this.image,
    required this.coloredName,
    required this.level,
    required this.idImage,
    required this.imageColorEntity,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      coloredName: parseValue<String>(json['colored_name'], ''),
      level: json['level'] is Map<String, dynamic>
          ? LevelModel.fromJson(json['level'])
          : LevelModel.fromJson(const {}),
      idImage: parseValue<String>(json['id_image'], ''),
      imageColorEntity: json['image_color'] is Map<String, dynamic>
          ? ImageColorModel.fromJson(json['image_color'])
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [id, uuid, name, image, level, idImage, imageColorEntity,coloredName];
}
