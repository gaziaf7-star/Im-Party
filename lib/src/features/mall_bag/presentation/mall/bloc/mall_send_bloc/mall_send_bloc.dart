import 'dart:async';
import 'package:general/src/core/index.dart';
import '../../../../domain/mall_bag_use_case/send_from_mall_use_case.dart';
part 'mall_send_event.dart';
part 'mall_send_state.dart';

class MallSendBloc extends Bloc<MallSendEvent, MallSendState> {
  final SendFromMallUseCase sendUseCase;

  MallSendBloc({required this.sendUseCase}) : super(MallSendInitial()) {
    on<SendItemEvent>(send);
  }

  FutureOr<void> send(SendItemEvent event, Emitter<MallSendState> emit) async {
    emit(SendLoadingState());
    final result = await sendUseCase(event.param);
    result.fold(
      (l) {
        emit(SendErrorState(message: NetworkExceptions.getErrorMessage(l)));
      },
      (r) {
        emit(SendSuccessState(message: r.message));
        Methods.showToast(event.context, message: r.message);
      },
    );
  }
}
