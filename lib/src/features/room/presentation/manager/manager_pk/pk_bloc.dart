import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_events.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_states.dart';
import 'package:general/src/features/room/room.dart';

class PKBloc extends Bloc<PKEvents, PKStates> {
  final ShowPKUC showPKUC;
  final StartPKUC startPKUC;
  final ClosePKUC closePKUC;
  final HidePKUC hidePKUC;

  PKBloc(
      {required this.showPKUC,
      required this.hidePKUC,
      required this.closePKUC,
      required this.startPKUC})
      : super(InitailPKState()) {
    on<ShowPKEvent>(showPK);
    on<StartPKEvent>(startPK);
    on<ClosePKEvent>(closePK);
    on<HidePKEvent>(hidePk);
  }

  FutureOr<void> showPK(ShowPKEvent event, Emitter<PKStates> emit) async {
    emit(ShowStateLoading());
    final result = await showPKUC.call(event.roomId);

    result.fold(
      (l) => emit(
          ShowStateError(errorMessage: NetworkExceptions.getErrorMessage(l))),
      (r) => emit(ShowStateSuccess()),
    );
  }

  FutureOr<void> startPK(StartPKEvent event, Emitter<PKStates> emit) async {
    emit(StartPKStateLoading());
    final result = await startPKUC
        .call(StartPKParameter(roomId: event.roomId, time: event.time));

    result.fold(
      (l) => emit(StartPKStateError(
          errorMessage: NetworkExceptions.getErrorMessage(l))),
      (r) {
        PKWidget.pkId = r.data??"";
        emit(StartPKStateSuccess());
      },
    );
  }

  FutureOr<void> closePK(ClosePKEvent event, Emitter<PKStates> emit) async {
    emit(ClosePKStateLoading());
    final result = await closePKUC
        .call(ClosePKParameter(roomId: event.roomId, pkId: event.pkId));

    result.fold(
      (l) => emit(ClosePKStateError(
          errorMessage: NetworkExceptions.getErrorMessage(l))),
      (r) => emit(ClosePKStateSuccess()),
    );
  }

  FutureOr<void> hidePk(HidePKEvent event, Emitter<PKStates> emit) async {
    emit(HidePKStateLoading());
    final result = await hidePKUC.call(event.roomId);

    result.fold(
      (l) => emit(
          HidePKStateError(errorMessage: NetworkExceptions.getErrorMessage(l))),
      (r) => emit(HidePKStateSuccess()),
    );
  }
}
