import 'package:general/src/features/moment/domain/entities/moment_gift.dart';
import 'package:general/src/features/moment/domain/usecases/fetch_moment_gift_use_case.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_gift_bloc/moment_gift_state.dart';

import '../../../../../core/index.dart';
part 'moment_gift_event.dart';

class MomentGiftBloc extends Bloc<MomentGiftEvent, MomentGiftState> {
  final FetchMomentGiftUseCase fetchMomentUseCase;

  MomentGiftBloc({required this.fetchMomentUseCase}) : super(const MomentGiftState()) {
    on<GetMomentGifts>(_onGetMomentGifts);

  }
  Future<void> _onGetMomentGifts(
      GetMomentGifts event, Emitter<MomentGiftState> emit) async {
    final result = await fetchMomentUseCase.call(event.userId);
    result.fold(
          (l) => emit(
        state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(l)),
      ),
          (r) {
        emit(state.copyWith(
          reqState: handleLoadedResponse<List<MomentGiftEntity>>(r.data),
          momentGiftList: r.data
        ));
      },
    );
  }
}