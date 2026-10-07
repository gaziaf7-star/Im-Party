
import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'get_family_ranking_event.dart';

part 'get_family_ranking_state.dart';

class GetFamilyRankingBloc
    extends Bloc<GetFamilyRankingEvent, GetFamilyRankingState> {
  GetFamilyRankingUC getFamilyRankingUseCase;

  GetFamilyRankingBloc({required this.getFamilyRankingUseCase})
      : super(const GetFamilyRankingState()) {

    on<GetDailyFamilyRankingEvent>((event, emit) async {
      if (event.isFirstLoading) {
        //emit(state.copyWith(dailyRequestState: RequestState.loading));
      }
      final result = await getFamilyRankingUseCase('today');

      result.fold(
            (l) => emit(state.copyWith(
          dailyErrorMessage: NetworkExceptions.getErrorMessage(l),
          dailyRequestState: handleErrorResponse(l),
        )),
            (r) {
          final topFamilies = r.data?.take(3).toList() ?? [];
          final otherFamilies = r.data;
          emit(state.copyWith(
            dailyRequestState: handleLoadedResponse<List<FamilyRankModel>>(r.data),
            dailyTopFamilies: topFamilies,
            dailyOtherFamilies: otherFamilies,
          ));
        },
      );
    });

    on<GetWeeklyFamilyRankingEvent>((event, emit) async {
      //emit(state.copyWith(weeklyRequestState: RequestState.loading));
      final result = await getFamilyRankingUseCase('week');

      result.fold(
            (l) => emit(state.copyWith(
          weeklyErrorMessage: NetworkExceptions.getErrorMessage(l),
          weeklyRequestState: handleErrorResponse(l),
        )),
            (r) {
          final topFamilies = r.data?.take(3).toList() ?? [];
          final otherFamilies = r.data;
          emit(state.copyWith(
            weeklyRequestState: handleLoadedResponse<List<FamilyRankModel>>(r.data),
            weeklyTopFamilies: topFamilies,
            weeklyOtherFamilies: otherFamilies,
          ));
        },
      );
    });

    on<GetMonthlyFamilyRankingEvent>((event, emit) async {
      //emit(state.copyWith(monthlyRequestState: RequestState.loading));
      final result = await getFamilyRankingUseCase('month');

      result.fold(
            (l) => emit(state.copyWith(
          monthlyErrorMessage: NetworkExceptions.getErrorMessage(l),
          monthlyRequestState: handleErrorResponse(l),
        )),
            (r) {
          final topFamilies = r.data?.take(3).toList() ?? [];
          final otherFamilies = r.data;
          emit(state.copyWith(
            monthlyRequestState: handleLoadedResponse<List<FamilyRankModel>>(r.data),
            monthlyTopFamilies: topFamilies,
            monthlyOtherFamilies: otherFamilies,
          ));
        },
      );
    });


    on<TopUsersViewEvent>(

      (event, emit) {

        emit (state.copyWith(tabBarIndex: event.tabBarIndex));
      },
    );
  }
}
