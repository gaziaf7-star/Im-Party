import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/clear_mode_uc.dart';
import 'package:general/src/features/room/presentation/manager/clear_mode_manager/clear_mode_event.dart';
import 'package:general/src/features/room/presentation/manager/clear_mode_manager/clear_mode_state.dart';

class ClearModeBloc extends Bloc<BaseClearModeEvent, ClearModeState> {
  final ClearModeUC clearModeUC;
  ClearModeBloc({required this.clearModeUC}) : super(const ClearModeInitial()) {
    on<ClearModeEvent>((event, emit) async {
      emit(const ClearModeLoadingState());
      final result = await clearModeUC.call(event.key);

      result.fold(
        (left) => emit(
          ClearModeErrorState(
            message: NetworkExceptions.getErrorMessage(left),
          ),
        ),
        (right) {emit(ClearModeSuccessState(data: right.data!));},
      );
    });
  }
}
