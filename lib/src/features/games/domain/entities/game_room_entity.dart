import 'package:general/src/core/index.dart';

class GameRoomEntity extends Equatable {
  final int? id;
  final int? ownerId;
  final String? roomId;
  final String? name;
  final int? visitorsCount;
  final String? cover;
  final int? isHot;
  final int? isPopular;
  final String? roomStatus;
  final bool? passwordStatus;
  final String? roomIntro;
  final int? maxAdmin;
  final int? isRecommended;
  final String? lang;
  final bool? isPk;
  final String? lastVisitTime;
  final Null profile;
  final String? country;
  final bool? haveLuckBox;

  const GameRoomEntity({
    this.id,
    this.ownerId,
    this.roomId,
    this.name,
    this.visitorsCount,
    this.cover,
    this.isHot,
    this.isPopular,
    this.roomStatus,
    this.passwordStatus,
    this.roomIntro,
    this.maxAdmin,
    this.isRecommended,
    this.lang,
    this.isPk,
    this.lastVisitTime,
    this.profile,
    this.country,
    this.haveLuckBox,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        roomId,
        name,
        visitorsCount,
        cover,
        isHot,
        isPopular,
        roomStatus,
        passwordStatus,
        roomIntro,
        maxAdmin,
        isRecommended,
        lang,
        isPk,
        lastVisitTime,
        profile,
        country,
        haveLuckBox,
      ];
}
