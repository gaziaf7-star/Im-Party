part of 'daily_prizes_bloc.dart';

class DailyPrizesState extends Equatable {
  final DailyPrizesEntity? dailyPrizesEntity;
  final String errorMsgGetDailyPrize;
  final RequestState requestStateGetPrize;
  final String openPrizeSuccess;
  final String openPrizeMessage;
  final RequestState requestStateOpenPrize;

  const DailyPrizesState({
    this.dailyPrizesEntity,
    this.errorMsgGetDailyPrize = '',
    this.requestStateGetPrize = RequestState.idle,
    this.openPrizeSuccess = '',
    this.openPrizeMessage = '',
    this.requestStateOpenPrize = RequestState.idle,
  });

  DailyPrizesState copyWith({
    DailyPrizesEntity? dailyPrizesEntity,
    RequestState? requestStateGetPrize,
    String? errorMsgGetDailyPrize,
    String? openPrizeSuccess,
    RequestState? requestStateOpenPrize,
    String? openPrizeMessage,
  }) {
    return DailyPrizesState(
      dailyPrizesEntity: dailyPrizesEntity ?? this.dailyPrizesEntity,
      requestStateGetPrize: requestStateGetPrize ?? this.requestStateGetPrize,
      errorMsgGetDailyPrize:
          errorMsgGetDailyPrize ?? this.errorMsgGetDailyPrize,
      openPrizeSuccess: openPrizeSuccess ?? this.openPrizeSuccess,
      requestStateOpenPrize:
          requestStateOpenPrize ?? this.requestStateOpenPrize,
      openPrizeMessage: openPrizeMessage ?? this.openPrizeMessage,
    );
  }

  @override
  List<Object?> get props => [
        dailyPrizesEntity,
        errorMsgGetDailyPrize,
        requestStateGetPrize,
        openPrizeMessage,
        requestStateOpenPrize,
        openPrizeSuccess,
      ];
}
