import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/get_gift_images_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_user_gifts_uc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/get_user_gifts_bloc/get_user_gifts_event.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/get_user_gifts_bloc/get_user_gifts_state.dart';

class FetchUserGiftBloc extends Bloc<FetchUserGiftEvent, FetchUserGiftsStates> {
  final GetUserGiftUC _getUserGiftUC;
  final GetGiftImagesUC _getGiftImagesUC;

  FetchUserGiftBloc(this._getUserGiftUC, this._getGiftImagesUC)
      : super(const FetchUserGiftsStates()) {
    on<FetchAppGiftEvent>(_fetchAppGiftEvent);
    on<FetchAppGiftImagesEvent>(_fetchAppGiftImagesEvent);
  }

  Future<void> _fetchAppGiftEvent(
    FetchAppGiftEvent event,
    Emitter<FetchUserGiftsStates> emit,
  ) async {
    final result = await _getUserGiftUC();

    result.fold(
      (failure) => emit(
        state.copyWith(
          appMessage: NetworkExceptions.getErrorMessage(failure),
          appReqState: RequestState.error,
        ),
      ),
      (success) => emit(
        state.copyWith(
          appGifts: success.data,
          appReqState: RequestState.loaded,
        ),
      ),
    );
  }

  Future<void> _fetchAppGiftImagesEvent(
    FetchAppGiftImagesEvent event,
    Emitter<FetchUserGiftsStates> emit,
  ) async {
    final result = await _getGiftImagesUC();

    result.fold(
      (failure) => emit(
        state.copyWith(
          appGiftImagesMessage: NetworkExceptions.getErrorMessage(failure),
          appGiftImagesReqState: RequestState.error,
        ),
      ),
      (success) => emit(
        state.copyWith(
          appGiftImages: success.data,
          appGiftImagesReqState: RequestState.loaded,
        ),
      ),
    );
  }
}
