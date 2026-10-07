import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

part 'mall_event.dart';
part 'mall_state.dart';

class MallBloc extends Bloc<MallEvent, GetDataMallStates> {
  final GetMallDataUseCase getMallDataUseCase;

  MallBloc({required this.getMallDataUseCase})
      : super(const GetDataMallStates()) {
    on<GetCarMallEvent>(getCareMall);
    on<GetFramesMallEvent>(getFrames);
    on<GetSpecialIdMallEvent>(getSpecialId);
    on<GetBubbleMallEvent>(getBubbleMall);
    on<ChangeAppBarUIMallEvent>(changeAppBarUI);
    on<SelectMallItemEvent>(_onSelectMallItem);
    on<GetProfileFramesMallEvent>(_getProfileFrames);
  }

  Future<void> getCareMall(
      GetCarMallEvent event, Emitter<GetDataMallStates> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(carMallRequest: RequestState.loading));
    }
    final result = await getMallDataUseCase.call(6);
    result.fold(
      (left) => emit(
        state.copyWith(
          carMallRequest: RequestState.error,
          carMallMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) {
        emit(
          state.copyWith(
            selectedItem: (right.data ?? []).isEmpty ? null : right.data?.first,
            carsMall: right.data,
            carMallRequest: handleLoadedResponse<List<MallEntity>?>(right.data),
          ),
        );
      },
    );
  }

  Future<void> getFrames(
      GetFramesMallEvent event, Emitter<GetDataMallStates> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(frameMallRequest: RequestState.loading));
    }

    final result = await getMallDataUseCase.call(4);
    result.fold(
      (left) => emit(state.copyWith(
          frameMallRequest: RequestState.error,
          frameMallMessage: NetworkExceptions.getErrorMessage(left))),
      (right) {
        emit(state.copyWith(
            framesMall: right.data,
            selectedItem: (right.data ?? []).isEmpty ? null : right.data?.first,
            frameMallRequest: handleLoadedResponse<List<MallEntity>?>(right.data)));
      },
    );
  }

  Future<void> getBubbleMall(
      GetBubbleMallEvent event, Emitter<GetDataMallStates> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(bubbleMallRequest: RequestState.loading));
    }

    final result = await getMallDataUseCase.call(5);
    result.fold(
      (left) => emit(state.copyWith(
          bubbleMallRequest: RequestState.error,
          bubbleMallMessage: NetworkExceptions.getErrorMessage(left))),
      (right) {
        emit(state.copyWith(
            selectedItem: (right.data ?? []).isEmpty ? null : right.data?.first,
            bubblesMall: right.data,
            bubbleMallRequest:
                handleLoadedResponse<List<MallEntity>?>(right.data)));
      },
    );
  }

  Future<void> getSpecialId(
      GetSpecialIdMallEvent event, Emitter<GetDataMallStates> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(emojisMallRequest: RequestState.loading));
    }
    final result = await getMallDataUseCase.call(25);
    result.fold(
      (left) => emit(state.copyWith(
          emojisMallRequest: RequestState.error,
          emojisMallMessage: NetworkExceptions.getErrorMessage(left))),
      (right) {
        emit(state.copyWith(
            selectedItem: (right.data ?? []).isEmpty ? null : right.data?.first,
            emojisMall: right.data,
            emojisMallRequest:
                handleLoadedResponse<List<MallEntity>?>(right.data)));
      },
    );
  }

  Future<void> changeAppBarUI(
      ChangeAppBarUIMallEvent event, Emitter<GetDataMallStates> emit) async {
    emit(state.copyWith(tabBarIndex: event.index));
  }

  Future<void> _onSelectMallItem(
      SelectMallItemEvent event, Emitter<GetDataMallStates> emit) async {
    emit(state.copyWith(selectedItem: event.selectedItem));
  }

  Future<void> _getProfileFrames(
      GetProfileFramesMallEvent event, Emitter<GetDataMallStates> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(profileFramesMallRequest: RequestState.loading));
    }

    final result = await getMallDataUseCase.call(28);

    result.fold(
      (left) => emit(
        state.copyWith(
          profileFramesMallRequest: RequestState.error,
          profileFramesMallMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) {
        emit(
          state.copyWith(
            selectedItem: (right.data ?? []).isEmpty ? null : right.data?.first,
            profileFramesMall: right.data,
            profileFramesMallRequest:
                handleLoadedResponse<List<MallEntity>?>(right.data),
          ),
        );
      },
    );
  }
}
