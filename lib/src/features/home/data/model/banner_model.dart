import 'package:general/src/core/index.dart';
import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    required super.buttonText,
    required super.imageUrl,
    required super.redirectUrl,
    required super.publishAt,
    required super.isActive,
    required super.userEventWinner,
    required super.eventType,
    required super.cpImage1,
    required super.cpImage2,
    required super.cpName1,
    required super.cpName2,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: parseValue<int>(json['id'], 0),
      title: parseValue<String>(json['title'], ''),
      buttonText: parseValue<String>(json['button_text'], ''),
      imageUrl: parseValue<String>(json['image_url'], ''),
      redirectUrl: parseValue<String>(json['redirect_url'], ''),
      publishAt: parseValue<String>(json['publish_at'], ''),
      isActive: parseValue<bool>(json['is_active'], false),
      userEventWinner: parseValue<String>(json['user_event_winner'], ""),
      cpImage1: parseValue<String>(json['user_event_winner'], ""),
      cpImage2: parseValue<String>(json['user_event_winner_two'], ""),
      cpName1: parseValue<String>(json['cp_winner_name_one'], ""),
      cpName2: parseValue<String>(json['cp_winner_name_two'], ""),
      eventType: parseValue<String>(json['event_type'], ""),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        buttonText,
        imageUrl,
        redirectUrl,
        publishAt,
        isActive,
        userEventWinner,
        eventType,
      ];
}
