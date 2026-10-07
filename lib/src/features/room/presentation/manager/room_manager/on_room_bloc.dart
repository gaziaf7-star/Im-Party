import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/lock_comments_uc.dart';
import 'package:general/src/features/room/domain/use_case/send_yallow_banner_uc.dart';
import 'package:general/src/features/room/room.dart';

class OnRoomBloc extends Bloc<OnRoomEvents, OnRoomStates> {
  final BackGroundUC backGroundUseCase;
  final RemovePassRoomUC removePassRoomUC;
  final SendYallowBannerUC sendYallowBannerUC;
  final UnLockCommentsUC unLockCommentsUC;
  final LockCommentsUC lockCommentsUC;

  static OnRoomBloc get(context) => BlocProvider.of(context);

  OnRoomBloc({
    required this.backGroundUseCase,
    required this.removePassRoomUC,
    required this.sendYallowBannerUC,
    required this.lockCommentsUC,
    required this.unLockCommentsUC,
  }) : super(const OnRoomInitialState()) {
    on<InitRoomEvent>((event, emit) async {
      emit(const OnRoomInitialState());
    });

    on<RemovePassRoomEvent>(
      (event, emit) async {
        final result = await removePassRoomUC.call(event.roomId);

        result.fold(
          (left) => emit(RemovePassRoomErrorState(
              message: NetworkExceptions.getErrorMessage(left))),
          (right) => emit(RemovePassRoomSucssesState(
              message: StringManager.youRemoveYourPassword.tr())),
        );
      },
    );

    on<GetBackGroundEvent>(((event, emit) async {
      emit(GetBackGroundloadingState());
      final result = await backGroundUseCase.call();

      result.fold((left) {
        emit(GetBackGroundErrorState(
            message: NetworkExceptions.getErrorMessage(left)));
      }, (right) {
        emit(GetBackGroundSucsseState(data: right));
      });
    }));

    on<SendYallowBannerEvent>(
      ((event, emit) async {
        emit(SendYallowBannerLoadingState());
        final result = await sendYallowBannerUC.call(
          SendPobUpPram(
            roomId: event.roomId,
            message: event.message,
          ),
        );
        result.fold(
          (left) => emit(SendYallowBannerErrorState(
              message: NetworkExceptions.getErrorMessage(left))),
          (right) => emit(SendYallowBannerSuccessState(message: right.message)),
        );
      }),
    );

    on<LockCommentsEvent>(
      ((event, emit) async {
        emit(LockCommentsLoadingState());
        final result = await lockCommentsUC
            .call(LockCommentsParameter(roomId: event.roomId, status: 1));

        result.fold(
          (left) => emit(LockCommentsErrorState(
              message: NetworkExceptions.getErrorMessage(left))),
          (right) => emit(LockCommentsSuccessState(message: right)),
        );
      }),
    );

    on<UnLockCommentsEvent>(
      ((event, emit) async {
        emit(UnLockCommentsLoadingState());
        final result = await unLockCommentsUC.call(
          LockCommentsParameter(
            roomId: event.roomId,
            status: 0,
          ),
        );

        result.fold(
          (left) => emit(UnLockCommentsErrorState(
              message: NetworkExceptions.getErrorMessage(left))),
          (right) => emit(UnLockCommentsSuccessState(message: right)),
        );
      }),
    );
  }
}
