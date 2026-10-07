import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/setting/domain/use_case/get_block_list_usecase.dart';
import 'package:general/src/features/setting/presentation/bloc_list/bloc/block_list_event.dart';
import 'package:general/src/features/setting/presentation/bloc_list/bloc/block_list_state.dart';

class GetBlockListBloc extends Bloc<BaseGetBlockListEvent, GetBlockListState> {
  final GetBlockListUseCase getBlockListUseCase;

  GetBlockListBloc({required this.getBlockListUseCase})
      : super(const GetBlockListState()) {
    on<GetBlockListEvent>(
      (event, emit) async {
        if (event.isLoading == true) {
          emit(state.copyWith(requestStateBlockList: RequestState.loading));
        }

        final result = await getBlockListUseCase.call();

        result.fold(
          (left) {
            emit(
              state.copyWith(
                errorMsg: left,
                requestStateBlockList: handleErrorResponse(left),
              ),
            );
          },
          (right) {
            emit(
              state.copyWith(
                blackListModel: right.data ?? [],
                requestStateBlockList:
                    handleLoadedResponse<List<UserEntity>>(right.data),
              ),
            );
          },
        );
      },
    );
  }
}
