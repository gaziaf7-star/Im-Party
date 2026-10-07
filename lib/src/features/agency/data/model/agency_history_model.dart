import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class AgencyHistoryModel extends AgencyHistoryEntity {
  const AgencyHistoryModel({
    required super.id,
    required super.uuid,
    required super.image,
    required super.name,
    required super.totalUsed,
    required super.diamonds,
  });

  // Factory method to create the model from JSON
  factory AgencyHistoryModel.fromJson(Map<String, dynamic> json) {
    return AgencyHistoryModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      image: parseValue<String>(json['image'], ''),
      name: parseValue<String>(json['name'], ''),
      totalUsed: parseValue<int>(json['total_used'].toInt(), 0),
      diamonds: parseValue<int>(json['diamonds'], 0),
    );
  }

  // Method to convert the model to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'image': image,
      'name': name,
      'total_used': totalUsed,
      'diamonds': diamonds,
    };
  }
}

class AgencyMemberChargesHistoryModel extends Equatable {
  final int id;
  final String uuid;
  final String image;
  final String name;
  final int totalUsed;
  final String coins;
  final String date;
  final String coloredName;
  final bool isSender;

  const AgencyMemberChargesHistoryModel({
    required this.id,
    required this.uuid,
    required this.image,
    required this.name,
    required this.totalUsed,
    required this.coins,
    required this.date,
    required this.isSender,
    required this.coloredName,
  });

  factory AgencyMemberChargesHistoryModel.fromJson(Map<String, dynamic> json) {
    return AgencyMemberChargesHistoryModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      image: parseValue<String>(json['image'], ''),
      name: parseValue<String>(json['name'], ''),
      date: parseValue<String>(json['date'], ''),
      totalUsed: parseValue<int>(json['totalUsed'].toInt(), 0),
      coins: parseValue<String>(json['coins'], ''),
      coloredName: parseValue<String>(json['colored_name'], ''),
      isSender: parseValue<bool>(json['is_sender'], false),
    );
  }

  @override
  List<Object?> get props =>
      [id, uuid, image, name, totalUsed, coins, date, isSender, coloredName];
}
