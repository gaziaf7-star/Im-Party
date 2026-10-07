import '../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../data/model/family_rank_model.dart';
import '../../../../domain/use_case/get_all_family_use_case.dart';

part 'get_all_family_event.dart';
part 'get_all_family_state.dart';

class GetAllFamilyBloc extends Bloc<GetAllFamilyEvent, GetAllFamilyState> {
  GetAllFamilyUseCase getAllFamilyUseCase ;

  GetAllFamilyBloc({required this.getAllFamilyUseCase}) : super(const GetAllFamilyState()) {
    on<GetFamilyEvent>((event, emit) async{
      final result = await getAllFamilyUseCase();

      result.fold(
            (l) => emit(state.copyWith(
          errorMessage: NetworkExceptions.getErrorMessage(l),
          req: handleErrorResponse(l),
        )),
            (r) {
          final allFamilies = r.data;
          emit(state.copyWith(
            req: handleLoadedResponse<List<FamilyRankModel>>(r.data),
            allFamilies: allFamilies,
          ));
        },
      );
    });
    on<UsersViewEvent>((event, emit) {

      emit (state.copyWith(tabBarIndex: event.tabBarIndex));
      },
        );
    }
}
