import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final int id;
  final String? title;
  final String? buttonText;
  final String imageUrl;
  final String? redirectUrl;
  final String? cpImage1, cpImage2, cpName1, cpName2;
  final String publishAt;
  final String userEventWinner;
  final String eventType;
  final bool isActive;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.buttonText,
    required this.imageUrl,
    required this.redirectUrl,
    required this.publishAt,
    required this.userEventWinner,
    required this.eventType,
    required this.isActive,
    required this.cpImage1,
    required this.cpImage2,
    required this.cpName1,
    required this.cpName2,
  });

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
        cpImage1,
        cpImage2,
        cpName1,
        cpName2
      ];
}
