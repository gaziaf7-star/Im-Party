import 'dart:async';

import 'package:general/src/core/index.dart';
import '../../../../domain/use_case/make_action_vip_privacy_use_case.dart';
import '../get_vip_privacy/manger_get_vip_prev_bloc.dart';

part 'privacy_event.dart';
part 'privacy_state.dart';

class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  ActivePrivacyUseCase activePrivacyUseCase;
  DisActivePrivacyUseCase disActivePrivacyUseCase;

  PrivacyBloc(
      {required this.disActivePrivacyUseCase,
      required this.activePrivacyUseCase})
      : super(PrivacyInitial()) {
    on<ActivePrivacy>(activePrevliage);
    on<DisposePrivacy>(disposePrevliage);
  }

  Future<void> activePrevliage(
      ActivePrivacy event, Emitter<PrivacyState> emit,) async {
    emit(LoadingState());

    final result = await activePrivacyUseCase(event.type);
    result.fold(
      (left) => emit(
        ErrorState(massege: NetworkExceptions.getErrorMessage(left)),
      ),
      (right) {
        di<MangerGetVipPrevBloc>()
            .add(UpdatePrivacyItemEvent(key: event.type, isActive: true));
        emit(SuccessState(massege: right.message));
        di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));
      },
    );
  }

  Future<void> disposePrevliage(
      DisposePrivacy event, Emitter<PrivacyState> emit,) async {
    emit(LoadingState());
    final result = await disActivePrivacyUseCase(event.type);
    result.fold(
      (left) => emit(
        ErrorState(massege: NetworkExceptions.getErrorMessage(left)),
      ),
      (right) {
        di<MangerGetVipPrevBloc>()
            .add(UpdatePrivacyItemEvent(key: event.type, isActive: false));
        emit(SuccessState(massege: right.message));
        di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));
      },
    );
  }
}
