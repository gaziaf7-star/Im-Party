import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/data/model/country_model.dart';
import 'package:general/src/features/profile/data/model/badges_model.dart';

import '../../../../core/utils/methods.dart';

class Top extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final int? gender;
  final List<ImageData>? badges;
  final int? senderLevel;
  final int? receiverLevel;
  final String? total;
  final String? frame;
  final int? frameId;
  final int? vipLevel;
  final String? uuid;
  final double? totalDiff;
  final CountryModel? countryModel;
  const Top(
      {this.id,
      this.name,
      this.image,
      this.gender,
      this.senderLevel,
      this.receiverLevel,
      this.total,
      this.frame,
      this.frameId,
      this.totalDiff,
      this.uuid,
      this.vipLevel,
      this.badges,
      this.countryModel});
  factory Top.fromJson(Map<String, dynamic> json) {
    return Top(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      frame: parseValue<String>(json['frame'], ''),
      frameId: parseValue<int>(json['frame_id'], 0),
      image: parseValue<String>(json['image'], ''),
      gender: parseValue<int>(json['gender'], 0),
      senderLevel: parseValue<int>(json['sender_level'], 0),
      receiverLevel: parseValue<int>(json['receiver_level'], 0),
      vipLevel: parseValue<int>(json['vip'], 0),
      total: parseValue<String>(json['total'], ''),
      uuid: parseValue<String>(json['uuid'], ''),
      countryModel: json['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(json['country'])
          : null,
      totalDiff: parseValue<double>(json['total_diff'], 0.0),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        gender,
        senderLevel,
        receiverLevel,
        total,
        frame,
        frameId,
        totalDiff,
        badges,
      ];
}
