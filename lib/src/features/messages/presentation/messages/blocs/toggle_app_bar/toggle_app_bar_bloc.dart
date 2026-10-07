import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/text_field_bloc/text_field__bloc.dart';

part 'toggle_app_bar_event.dart';
part 'toggle_app_bar_state.dart';

class ToggleAppBarBloc extends Bloc<BaseToggleAppBarEvent, ToggleAppBarState> {
  ToggleAppBarBloc() : super(const ToggleAppBarState()) {
    on<InitAppBarEvent>(_initAppBarEvent);
    on<ToggleAppBarEvent>(_toggleEvent);
    on<ShowReplayBoxEvent>(_showReplayBoxEvent);
    on<ShowAttachBoxEvent>(_showAttachBoxEvent);
    on<ShowEmojeBoxEvent>(_showEmojeBoxEvent);
    on<SelectedMessagesEvent>(_selectedMessagesEvent);
    on<ShowRoomCardEvent>(_showRoomCardEvent);
    on<CopyEvent>(_copyEvent);
  }

  void _toggleEvent(
    ToggleAppBarEvent event,
    Emitter<ToggleAppBarState> emit,
  ) {
    if (state.counter > 0) {
      emit(
        state.copyWith(
          isToggle: event.isToggle,
          isReplying: false,
          isShowMore: false,
          messageSelectionMap: state.messageSelectionMap..clear(),
          counter: 0,
          isReplayNull: true,
          isShowEmoje: false,
        ),
      );
    }
    emit(state.copyWith(isToggle: event.isToggle));
  }

  void _showRoomCardEvent(
      ShowRoomCardEvent event,
    Emitter<ToggleAppBarState> emit,
  ) {
    emit(state.copyWith(isShowRoomCard: event.isShowRoomCard));
  }

  void _showReplayBoxEvent(
    ShowReplayBoxEvent event,
    Emitter<ToggleAppBarState> emit,
  ) {
    di<TextFieldBloc>().stopRecord();
    emit(
      state.copyWith(
        isReplying: event.isReplying,
        isShowMore: false,
        isShowEmoje: false,
      ),
    );
  }  void _copyEvent(
      CopyEvent event,
    Emitter<ToggleAppBarState> emit,
  ) {
    emit(
      state.copyWith(
        isShowMore: false,
        isShowEmoje: false,
      ),
    );
  }

  void _selectedMessagesEvent(
    SelectedMessagesEvent event,
    Emitter<ToggleAppBarState> emit,
  ) {
    final Map<int, MessageData> messages = Map.from(state.messageSelectionMap);
    final int? messageId = int.tryParse(event.messageId);
    if (messageId == null) return;

    if (messages.containsKey(messageId)) {
      messages.remove(messageId);
      int counter = state.counter - 1;

      final replayData = messages.length == 1 ? messages.values.first : null;

      emit(
        state.copyWith(
          messageSelectionMap: messages,
          counter: counter,
          userId: '-1',
          replay: replayData,
          isShowMore: false,
          isShowEmoje: false,
        ),
      );
    } else {
      final newMessageData = MessageData(
        senderId: event.senderId,
        isSelected: true,
        url: event.url ?? "",
        message: event.message,
        messageType: event.messageType,
        messageId: event.messageId,
      );
      messages[messageId] = newMessageData;
      int counter = state.counter + 1;

      final replayData = messages.length == 1 ? messages.values.first : null;

      emit(
        state.copyWith(
          messageSelectionMap: messages,
          counter: counter,
          userId: messages.length == 1 ? event.senderId : "-1",
          replay: replayData,
          isShowMore: false,
          isShowEmoje: false,
        ),
      );
    }

    if (state.counter == 0) {
      messages.clear();
      emit(
        state.copyWith(
          messageSelectionMap: messages,
          userId: "-1",
          isReplayNull: true,
          counter: 0,
          isReplying: false,
          isToggle: false,
          isShowMore: false,
          isShowEmoje: false,
        ),
      );
    }
  }

  void _initAppBarEvent(
    InitAppBarEvent event,
    Emitter<ToggleAppBarState> emit,
  ) {
    Map<int, MessageData>? messages;
    if (state.messageSelectionMap.isNotEmpty) {
      messages = Map.from(state.messageSelectionMap);
      messages.clear();
    }
    emit(
      state.copyWith(
        messageSelectionMap: messages,
        userId: "-1",
        isReplayNull: true,
        counter: 0,
        isReplying: false,
        isToggle: false,
        isShowMore: false,
        isShowEmoje: false,
      ),
    );
  }

  List<int> messagesId() => state.messageSelectionMap.keys.toList();

  void _showAttachBoxEvent(
    ShowAttachBoxEvent event,
    Emitter<ToggleAppBarState> emit,
  ) =>
      emit(
        state.copyWith(
          isShowMore:event.isShowMore,// !state.isShowMore,
          isReplying: false,
          isShowEmoje: false,
        ),
      );

  void _showEmojeBoxEvent(
    ShowEmojeBoxEvent event,
    Emitter<ToggleAppBarState> emit,
  ) {
    di<TextFieldBloc>().stopRecord();
    emit(
      state.copyWith(
        isShowEmoje: !state.isShowEmoje,
        isShowMore: false,
        isReplying: false,
      ),
    );
  }
}
