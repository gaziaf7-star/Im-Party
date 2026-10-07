import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/get_mybackground_uc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background/get_my_background_event.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background/get_my_background_state.dart';

class GetMyBackgroundBloc
    extends Bloc<BaseGetMyBackgroundEvent, GetMyBackgroundState> {
  final GetMyBackgroundUseCase _fetchMyBackgroundUseCase;
  GetMyBackgroundBloc(this._fetchMyBackgroundUseCase)
      : super(const GetMyBackgroundInitial()) {
    on<GetMyBackgroundEvent>((event, emit) async {
      if (event.isLoading) {
        emit(const GetMyBackgroundLoadingState());
      }

      final result = await _fetchMyBackgroundUseCase();
      result.fold(
        (left) => emit(
          GetMyBackgroundErrorState(
            error: NetworkExceptions.getErrorMessage(left),
          ),
        ),
        (right) => emit(
          GetMyBackgroundSuccessState(data: right),
        ),
      );
    });


  }
}
