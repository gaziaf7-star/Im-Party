
import 'package:general/src/features/chats/chats.dart';

part 'delete_chat_event.dart';
part 'delete_chat_state.dart';


class DeleteChatBloc extends Bloc<BaseDeleteChatEvent, DeleteChatState> {
  DeleteChatUC deleteChatUseCase;
  bool isLoadingMore = false;

  DeleteChatBloc({required this.deleteChatUseCase})
      : super(const DeleteChatState()) {
    on<DeleteChatEvent>((event, emit) async {
      final result = await deleteChatUseCase.call(event.userId);
      result.fold((l) {
        emit(state.copyWith(errorMsg: l,reqState: RequestState.error));
      },
          (r) => emit(state.copyWith(data: r,reqState: RequestState.loaded)));
    });


  }
}
