import 'package:general/src/features/profile/data/model/top.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_supporter_user_case.dart';
import '../../../../../../../../../core/index.dart';
import 'get_user_support_event.dart';
import 'get_user_support_state.dart';

class GetSupporterBloc
    extends Bloc<BaseGetUserSupporterEvent, GetUserSupporterState> {
  final GetUserSupporterUserCase getSupporterDataUseCase;
  GetSupporterBloc({required this.getSupporterDataUseCase})
      : super(const GetUserSupporterState()) {
    on<GetUserSupporterEvent>((event, emit) async {
      if ((state.requestState == RequestState.loaded ||
              state.requestState == RequestState.empty) &&
          state.loadedUserId == event.userId) {
        return;
      }
      emit(state.copyWith(requestState: RequestState.loading));
      final result = await getSupporterDataUseCase.call(event.userId);

      result.fold(
        (left) {
          emit(
            state.copyWith(
                requestState: handleErrorResponse(left),
                massage: NetworkExceptions.getErrorMessage(left)),
          );
        },
        (right) {
          emit(state.copyWith(
            topSupport: right.data,
            loadedUserId: event.userId,
            requestState: handleLoadedResponse<List<Top>>(right.data!.topUser),
            requestOtherUsersState: handleLoadedResponse<List<Top>>(
              right.data?.otherUsers,
            )
          ));
        },
      );
    });
  }
}
