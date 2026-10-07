import 'package:general/src/core/index.dart';
import 'package:general/src/features/chats/domain/usecases/fetch_chat_request_uc.dart';
import 'package:general/src/features/messages/messages.dart';


part 'chat_request_event.dart';
part 'chat_request_state.dart';

/// The chat-REQUESTS inbox is REST-refresh-only: it has NO realtime mirror on
/// Centrifugo (the legacy realtime chats channel that fed it was removed, and the
/// requests inbox was never re-homed onto Centrifugo). Per owner decision this
/// is acceptable — the inbox reloads via [FetchChatRequestUC] on init and on any
/// explicit pull-to-refresh ([GetChatRequestUsersEvent]). New requests surface
/// on the next refresh rather than live.
class FetchChatRequestBloc
    extends Bloc<BaseFetchChatRequestEvent, FetchChatRequestState> {
  final FetchChatRequestUC _fetchChatsRequestUc;

  bool isLoadingMore = false;
  int currentChatId = -1;

  FetchChatRequestBloc(
    this._fetchChatsRequestUc,
  ) : super(const FetchChatRequestState()) {
    on<GetChatRequestUsersEvent>(
      (event, emit) async {
        if (event.isLoading == true) {
          emit(state.copyWith(reqState: RequestState.loading));
        }
        final result = await _fetchChatsRequestUc();
        result.fold(
          (left) {
            emit(
              state.copyWith(
                error: left,
                reqState: handleErrorResponse(left),
              ),
            );
          },
          (right) {
            emit(
              state.copyWith(
                totalChatMessages: right.totalChatMessage,
                data: right.userChatEntity,
                reqState: handleLoadedResponse<List<UserChatEntity>>(
                    right.userChatEntity),
              ),
            );
          },
        );
      },
    );

    on<UpdateDataLocally>((event, emit) async {
      final List<UserChatEntity> res = List<UserChatEntity>.from(state.data);
      res.removeWhere((element) => element.chatId == event.chatId);
      res.insert(0, event.userChatEntity);
      emit(state.copyWith(data: res));
    });

    on<RemoveLocalChatRequestUserEvent>((event, emit) async {
      List<UserChatEntity> res = List<UserChatEntity>.from(state.data);
      res.removeWhere((element) => element.chatId == event.chatId);
      if (res.isEmpty) {
        emit(state.copyWith(data: res, reqState: RequestState.empty));
        return;
      }
      emit(state.copyWith(data: res));
    });

    on<ReadMessageEvent>((event, emit) {
      final List<UserChatEntity> user_ = List<UserChatEntity>.from(state.data);
      final int index =
          user_.indexWhere((element) => element.chatId == event.chatId);
      if (index != -1) {
        user_[index] = user_[index].copyWith(unreadMessage: 0);
      }
      emit(state.copyWith(data: user_, reqState: RequestState.loaded));
    });

    on<UpdateTotalMessagesRequest>((event, emit) {
      if (event.isIncreased) {
        if (event.counterMessage != 0) {
          emit(state.copyWith(totalChatMessages: 1 + state.totalChatMessages));
        }
      } else {
        for (var x in state.data) {
          if (x.userId.toString() == event.userId) {
            if (x.unreadMessage == 0) {
              break;
            } else {
              emit(state.copyWith(
                  totalChatMessages:
                      state.totalChatMessages - x.unreadMessage));
              break;
            }
          }
        }
      }
    });

    on<RemoveLocalLastMessageEvent>((event, emit) {
      final List<UserChatEntity> user_ = List<UserChatEntity>.from(state.data);
      final int index =
          user_.indexWhere((element) => element.chatId == event.chatId);
      if (index != -1 &&
          event.messageId != -1 &&
          user_[index].lastMessage.id == event.messageId) {
        user_[index] = user_[index].copyWith(
          lastMessage: user_[index].lastMessage.copyWith(senderDeleted: true),
        );
      }
      emit(state.copyWith(data: user_, reqState: RequestState.loaded));
    });
  }
}
