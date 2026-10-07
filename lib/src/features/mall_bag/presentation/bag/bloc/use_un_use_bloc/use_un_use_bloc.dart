import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';

part 'use_un_use_event.dart';

part 'use_un_use_state.dart';

class UseUnUseBloc extends Bloc<BaseUseUnUseEvent, UseUnUseState> {
  final UnUseBagItemUseCase unUseBagItemUseCase;
  final UseBagItemUseCase useBagItemUseCase;
  final UseUnUseBagItemSpecialIdUC unUseBagItemSpecialIdUC;

  UseUnUseBloc(
      {required this.unUseBagItemUseCase,
      required this.useBagItemUseCase,
      required this.unUseBagItemSpecialIdUC})
      : super(const UseUnUseState()) {
    on<UnUseEvent>(_unUseEvent);
    on<UseEvent>(_useEvent);
    on<UseUnUseSpecialIdEvent>(_useUnUseSpecialIdEvent);
  }

  FutureOr<void> _useUnUseSpecialIdEvent(
      UseUnUseSpecialIdEvent event, Emitter<UseUnUseState> emit) async {
    final result = await unUseBagItemSpecialIdUC(event.param);
    result.fold((failure) {
      emit(state.copyWith(
          unUseState: RequestState.error,
          unUseError: NetworkExceptions.getErrorMessage(failure)));
      Methods.safeShowToast(message: state.unUseError ?? "", isError: true);
      SafeNavigator.pop();
    }, (success) {
      emit(state.copyWith(
          useSuccess: success.message,
          unUseSuccess: success.data,
          unUseState: RequestState.loaded));
      di<FetchUserDataBloc>().add(const FetchMyDataEvent());
      di<MyBagBloc>().add(LocalChangeDataEvent(
        itemId: event.param.itemId!,
        tabType: event.tabType,
        useType: event.param.isUsed!,
      ));
      Methods.safeShowToast(message: state.useSuccess ?? "");
      SafeNavigator.pop();
    });
  }

  FutureOr<void> _useEvent(UseEvent event, Emitter<UseUnUseState> emit) async {
    final result = await useBagItemUseCase(event.param);
    result.fold((failure) {
      emit(state.copyWith(
          useState: RequestState.error,
          useError: NetworkExceptions.getErrorMessage(failure)));
      Methods.safeShowToast(message: state.useError ?? "", isError: true);
    }, (success) {
      emit(
        state.copyWith(
          useSuccess: success.message,
          useState: RequestState.loaded,
        ),
      );
      di<FetchUserDataBloc>().add(const FetchMyDataEvent());
      di<MyBagBloc>().add(
        LocalChangeDataEvent(
          itemId: event.param.itemId!,
          tabType: event.tabType,
          useType: true,
        ),
      );
      UsersCache().removeUser(MyDataModel.getInstance().id ?? -1);
      Methods.safeShowToast(
        message: state.useSuccess ?? "",
      );
    });
  }

  FutureOr<void> _unUseEvent(
      UnUseEvent event, Emitter<UseUnUseState> emit) async {
    final result = await unUseBagItemUseCase(event.param);
    result.fold((failure) {
      emit(state.copyWith(
          unUseState: RequestState.error,
          unUseError: NetworkExceptions.getErrorMessage(failure)));
      Methods.safeShowToast(
        message: state.unUseError ?? "",
        isError: true,
      );
    }, (success) {
      di<FetchUserDataBloc>().add(const FetchMyDataEvent());
      di<MyBagBloc>().add(
        LocalChangeDataEvent(
          itemId: event.param.itemId!,
          tabType: event.tabType,
          useType: false,
        ),
      );
      UsersCache().removeUser(MyDataModel.getInstance().id ?? -1);
      Methods.safeShowToast(message: state.unUseSuccess ?? "");
      emit(
        state.copyWith(
          unUseSuccess: success.message,
          unUseState: RequestState.loaded,
        ),
      );
    });
  }
}
