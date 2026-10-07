import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/entities/daily_prize_entity.dart';
import 'package:general/src/features/home/domain/home_use_case/open_daily_prizes_use_case.dart';

import '../../../domain/home_use_case/daily_prizes_use_case.dart';
import '../view/daily_prize_dialog.dart';

part 'daily_prizes_events.dart';

part 'daily_prizes_states.dart';

class DailyPrizesBloc extends Bloc<GetDailyPrizesEvents, DailyPrizesState> {
  final DailyPrizesUseCase dailyPrizesUseCase;
  final OpenDailyPrizeUC openDailyPrizeUC;

  DailyPrizesBloc(
      {required this.dailyPrizesUseCase, required this.openDailyPrizeUC})
      : super(const DailyPrizesState()) {
    on<GetDailyPrizesEvent>(_getDailyPrizes);
    on<OpenDailyPrizesEvent>(_openDailyPrizes);
  }

  Future<void> _getDailyPrizes(
    GetDailyPrizesEvent event,
    Emitter<DailyPrizesState> emit,
  ) async {
    emit(state.copyWith(requestStateGetPrize: RequestState.loading));
    final result = await dailyPrizesUseCase.call();
    result.fold(
      (left) => emit(state.copyWith(
          errorMsgGetDailyPrize: NetworkExceptions.getErrorMessage(left),
          requestStateGetPrize: RequestState.error)),
      (right) {
        emit(
          state.copyWith(
            dailyPrizesEntity: right.data,
            requestStateGetPrize: RequestState.loaded,
          ),
        );
        final dialogContext = SafeNavigator.context;
        if (state.dailyPrizesEntity?.isReceived != true &&
            ConstantsManager.isOptionalUpdate == true &&
            dialogContext != null) {
          showDialog(
            context: dialogContext,
            builder: (_) => Dialog(
              backgroundColor: ColorManager.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const DailyPrizeDialog(
                isNeedCompleteInfoDialog: true,
              ),
            ),
          );
        }
        // "Please complete information" nudge removed per request -- no
        // longer shown after the daily-prize flow.
      },
    );
  }

  Future<void> _openDailyPrizes(
    GetDailyPrizesEvents event,
    Emitter<DailyPrizesState> emit,
  ) async {
    emit(state.copyWith(requestStateOpenPrize: RequestState.loading));
    final result = await openDailyPrizeUC();
    result.fold(
      (left) => emit(
        state.copyWith(
          openPrizeMessage: NetworkExceptions.getErrorMessage(left),
          requestStateOpenPrize: RequestState.error,
          dailyPrizesEntity:
              state.dailyPrizesEntity?.copyWith(isReceived: false),
        ),
      ),
      (right) {
        emit(
          state.copyWith(
            openPrizeSuccess: right,
            dailyPrizesEntity:
                state.dailyPrizesEntity?.copyWith(isReceived: true),
            requestStateOpenPrize: RequestState.loaded,
          ),
        );
      },
    );
  }
}
