import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/core/index.dart';



part 'get_coins_history_event.dart';
part 'get_coins_history_state.dart';

class GetGoogleCoinsHistoryBloc
    extends Bloc<BaseGetGoogleCoinsHistoryEvent, GetGoogleCoinsHistoryState> {
  final GetGoogleCoinsHistoryUC getCoinsHistoryUseCase;

  GetGoogleCoinsHistoryBloc({required this.getCoinsHistoryUseCase})
      : super(const GetGoogleCoinsHistoryState()) {
    on<GetGoogleCoinsHistoryEvent>(
      (event, emit) async {
        emit(state.copyWith(state: RequestState.loading));

        final result = await getCoinsHistoryUseCase();
        result.fold(
          (left) => emit(
            state.copyWith(
              state: handleErrorResponse(left),
              error: NetworkExceptions.getErrorMessage(left),
            ),
          ),
          (right) => emit(
            state.copyWith(
                state: handleLoadedResponse<List<UserGoogleCoinsHistoryModel>?>(
                    right.data),
                coinsHistoryList: right.data ?? []),
          ),
        );
      },
    );
  }
}
