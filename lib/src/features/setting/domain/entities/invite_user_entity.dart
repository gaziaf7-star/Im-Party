import 'package:equatable/equatable.dart';

class InvitationUsersEntity extends Equatable {
  final String invitedId;
  final num userCharge;
  final int parentPercentage;
  final String date;
  final String image;
  final String name;

  const InvitationUsersEntity({
    required this.invitedId,
    required this.userCharge,
    required this.parentPercentage,
    required this.date,
    required this.image,
    required this.name,
  });

  @override
  List<Object> get props =>
      [invitedId, userCharge, parentPercentage, date, image, name,];
}
