import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/data/model/get_vip_prev.dart';

import '../../../../domain/use_case/get_vip_privacy_use_case.dart';

part 'manger_get_vip_prev_event.dart';
part 'manger_get_vip_prev_state.dart';

class MangerGetVipPrevBloc
    extends Bloc<MangerGetVipPrevEvent, MangerGetVipPrevState> {
  final GetVipPrivacyUseCase getVipPrevUseCase;

  MangerGetVipPrevBloc({required this.getVipPrevUseCase})
      : super(const MangerGetVipPrevState()) {
    on<GetVipPrevEvent>((event, emit) async {
      final result = await getVipPrevUseCase();

      result.fold(
        (l) => emit(state.copyWith(
          requestState: RequestState.error,
          error: NetworkExceptions.getErrorMessage(l),
        )),
        (r) => emit(state.copyWith(
          requestState: RequestState.loaded,
          data: r.data ?? [],
        )),
      );
    });

    on<UpdatePrivacyItemEvent>((event, emit) {
      final updatedData = state.data.map((item) {
        if (item.key == event.key) {
          return item.copyWith(isActive: event.isActive);
        }
        return item;
      }).toList();
      emit(state.copyWith(data: updatedData));
    });
  }
}
