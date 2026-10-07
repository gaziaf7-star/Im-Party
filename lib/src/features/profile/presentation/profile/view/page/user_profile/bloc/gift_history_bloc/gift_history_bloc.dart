

import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_use_case/gift_history_use_case.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_state.dart';

import '../../../../../../../data/model/gift_history_model.dart';






class GiftHistoryBloc extends Bloc<GiftHistoryEvent, GiftHistoryState> {
  GiftHistoryUseCase giftHistoryUseCase;
  GiftHistoryBloc({required this.giftHistoryUseCase}) : super(const GiftHistoryState()) {
    on<GetGiftHistory>((event, emit)async {
      final bool alreadyLoadedForUser = !event.force &&
          state.lastLoadedId == event.id &&
          (state.requestState == RequestState.loaded ||
              state.requestState == RequestState.empty);
      if (alreadyLoadedForUser) {
        return;
      }
       emit(state.copyWith(requestState: RequestState.loading));
      final result = await giftHistoryUseCase.call(event.id);

      result.fold(
          (l) => emit(state.copyWith(
            requestState: RequestState.error,
            errorMessage: l,
              )),
          (r) =>
              emit(state.copyWith(giftModel:r.data??[],requestState:handleLoadedResponse<List<GiftHistoryModel>>(r.data),lastLoadedId: event.id)));

    });
  }
}
