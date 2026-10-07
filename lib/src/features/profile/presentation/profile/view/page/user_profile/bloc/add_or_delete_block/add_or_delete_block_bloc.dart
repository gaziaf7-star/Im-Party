
import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_use_case/add_block_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/remove_block_use_case.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_state.dart';

import '../../../../../../f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import '../../../../../../f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';



class AddOrRemoveBlock extends Bloc<BaseAddOrDeleteBlockListEvent, AddBlocOrRemoveState> {
  final AddBlockUseCase addBlockUseCase;
  final RemoveBlockUseCase removeBlockUseCase;

  AddOrRemoveBlock({
    required this.addBlockUseCase,
    required this.removeBlockUseCase,
  }) : super(const AddBlocOrRemoveState()) {
    on<AddBlockListEvent>(
      (event, emit) async {
        emit( state.copyWith(requestStateAddBloc: RequestState.loading));
        Methods.showToast(
          event.context,
          isLoading: true
        );
        final result = await addBlockUseCase.call(event.userId);
        result.fold(
                (l) {
                  emit(state.copyWith(errorMsgAddBloc: l,requestStateAddBloc:RequestState.error));
                  Methods.showToast(
                    event.context,
                    isError: true,
                    message:  NetworkExceptions.getErrorMessage(state.errorMsgAddBloc!),
                  );
                },
                (r) {
                  emit(state.copyWith(
                successAddBloc: r,requestStateAddBloc: RequestState.loaded));
                  Methods.showToast(
                    event.context,
                    message: state.successAddBloc!,
                  );

                  di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));

                  di<GetFollowerOrFollowingBloc>().add(
                    RemoveUserEvent(
                      userId: event.userId,
                      relationType:di<GetFollowerOrFollowingBloc>().state.currentRelationType,
                    ),
                  );

                  Navigator.pop(event.context);
                });
      },
    );
    on<DeleteBlockListEvent>(
      (event, emit) async {
        Methods.showToast(
            event.context,
            isLoading: true
        );
        emit(state.copyWith(requestStateRemoveBloc: RequestState.loading));
        Methods.showToast(
            event.context,
            isLoading: true
        );
        final result = await removeBlockUseCase.call(event.userId);

        result.fold(
                (l) {
                  emit(state.copyWith(errorMsgRemoveBloc: l,requestStateRemoveBloc:RequestState.error));
                  Methods.showToast(
                    event.context,
                    isError: true,
                    message:  NetworkExceptions.getErrorMessage(state.errorMsgAddBloc!),
                  );
                },
                (r) {
                  emit(state.copyWith(successRemoveBloc: r,requestStateRemoveBloc: RequestState.loaded));
                  Methods.showToast(
                    event.context,
                    message: state.successAddBloc!,
                  );
                }
        );

      },
    );
  }
}
