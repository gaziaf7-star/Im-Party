

import 'package:general/src/features/cp/cp.dart';

import '../../../../../core/index.dart';
part 'cp_relations_levels_event.dart';
part 'cp_relations_levels_state.dart';

class CpRelationsLevelsBloc
    extends Bloc<CpRelationsLevelsEvent, CpRelationsLevelsState> {
  final GetCpLevelsGiftsUC _getRelationsCpLevelsGiftsUc;
  final GetRelationsCpSpecialFriendUC
      _getRelationsCpSpecialFriendLevelsGiftsUC;
  CpRelationsLevelsBloc(this._getRelationsCpLevelsGiftsUc,
      this._getRelationsCpSpecialFriendLevelsGiftsUC)
      : super(const CpRelationsLevelsState()) {
    on<GetCpRelationsLevelsEvent>((event, emit) async {
      emit(state.copyWith(reqStateLevelsGift: RequestState.loading));
      final result = await _getRelationsCpLevelsGiftsUc.call();
      result.fold(
        (l) => emit(state.copyWith(
            reqStateLevelsGift: handleErrorResponse(l),
            errorLevelsGift: NetworkExceptions.getErrorMessage(l))),
        (r) => emit(state.copyWith(
            reqStateLevelsGift: handleLoadedResponse<List<CpRelationLevelsGiftsModel>>(r.data), levelsGift: r.data)),
      );
    });

    on<GetCpRelationsSpecialFriendLevelsEvent>((event, emit) async {
      emit(state.copyWith(reqStateSpecialFriendsGift: RequestState.loading));
      final result = await _getRelationsCpSpecialFriendLevelsGiftsUC.call();
      result.fold(
        (l) => emit(state.copyWith(
            reqStateSpecialFriendsGift: handleErrorResponse(l),
            errorSpecialFriendsGift: NetworkExceptions.getErrorMessage(l))),
        (r) => emit(state.copyWith(
            reqStateSpecialFriendsGift: handleLoadedResponse<List<CpRelationLevelsGiftsModel>>(r.data),
            specialFriendsGift: r.data)),
      );
    });
  }
}
