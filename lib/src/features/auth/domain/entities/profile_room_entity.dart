import 'package:equatable/equatable.dart';

class ProfileRoomEntity extends Equatable {
  final String? image;
  final int? gender;
  final String? imageId;
  final String? birthday;
  final int? age;

  const ProfileRoomEntity({
    this.image,
    this.gender,
    this.imageId,
    this.birthday,
    this.age,
  });

  @override
  List<Object?> get props => [image, gender, imageId, birthday, age];
}
