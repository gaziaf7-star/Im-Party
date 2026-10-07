part of 'cp_relations_levels_bloc.dart';


class CpRelationsLevelsState extends Equatable {
  final List<CpRelationLevelsGiftsModel>? specialFriendsGift;
  final List<CpRelationLevelsGiftsModel>? levelsGift;
  final RequestState reqStateSpecialFriendsGift;
  final RequestState reqStateLevelsGift;
  final String? errorSpecialFriendsGift;
  final String? errorLevelsGift;

  const CpRelationsLevelsState({
    this.errorSpecialFriendsGift = '',
    this.errorLevelsGift = '',
    this.specialFriendsGift,
    this.levelsGift,
    this.reqStateSpecialFriendsGift=RequestState.idle,
    this.reqStateLevelsGift=RequestState.idle,
  });

  CpRelationsLevelsState copyWith({
    String? errorSpecialFriendsGift,
    String? errorLevelsGift,
    List<CpRelationLevelsGiftsModel>? specialFriendsGift,
    List<CpRelationLevelsGiftsModel>? levelsGift,
    RequestState? reqStateSpecialFriendsGift,
    RequestState? reqStateLevelsGift,
  }) {
    return CpRelationsLevelsState(
      errorSpecialFriendsGift:
          errorSpecialFriendsGift ?? this.errorSpecialFriendsGift,
      errorLevelsGift: errorLevelsGift ?? this.errorLevelsGift,
      specialFriendsGift: specialFriendsGift ?? this.specialFriendsGift,
      levelsGift: levelsGift ?? this.levelsGift,
      reqStateSpecialFriendsGift: reqStateSpecialFriendsGift ?? this.reqStateSpecialFriendsGift,
      reqStateLevelsGift: reqStateLevelsGift ?? this.reqStateLevelsGift,
    );
  }

  @override
  List<Object?> get props =>
      [errorSpecialFriendsGift, errorLevelsGift, specialFriendsGift,reqStateLevelsGift, reqStateSpecialFriendsGift];
}
