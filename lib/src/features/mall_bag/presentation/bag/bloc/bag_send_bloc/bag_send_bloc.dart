import 'dart:async';
import '../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../domain/mall_bag_use_case/send_from_bag_use_case.dart';

part 'bag_send_event.dart';
part 'bag_send_state.dart';

class BagSendBloc extends Bloc<BagSendEvent, BagSendState> {
  final SendFromBagUseCase sendUseCase;

  BagSendBloc({required this.sendUseCase}) : super(BagSendInitial()) {
    on<SendBagItemEvent>(send);
  }
  FutureOr<void> send(SendBagItemEvent event,Emitter<BagSendState> emit)async{
    emit(SendLoadingState());
    Methods.showToast(event.context,message: StringManager.loading,isLoading: true);

    final result = await sendUseCase(event.param);
    result.fold((l){
      emit(SendErrorState(message: NetworkExceptions.getErrorMessage(l)));
      Methods.showToast(event.context,message: NetworkExceptions.getErrorMessage(l),isError: true);

    }, (r){
      emit(SendSuccessState(message: r.message));
      Methods.showToast(event.context,message: r.message);
    });

  }
}
