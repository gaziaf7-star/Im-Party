import 'dart:async';
import 'dart:math';

import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/chats/domain/usecases/fetch_chat_uc.dart';
import 'package:general/src/features/chats/presentation/chats/view/widgets/room_to_conversation_mapper.dart';
import 'package:general/src/features/messages/messages.dart';

part 'get_users_chat_event.dart';

part 'get_users_chat_state.dart';

class FetchUsersChatBloc
    extends Bloc<BaseGetChatUsersEvent, GetUsersChatState> {
  final FetchChatUC _fetchChatsUC;
  final RoomsDao _roomsDao;

  bool isLoadingMore = false;
  int currentChatId = -1;
  StreamSubscription<List<RoomWithLast>>? _roomsSubscription;
  VoidCallback? _scrollCallback;

  FetchUsersChatBloc(
    this._fetchChatsUC,
    this._roomsDao,
  ) : super(GetUsersChatState(
          scrollController: ScrollController(),
        )) {
    // Realtime is Centrifugo-only: incoming DMs land in drift and the chats
    // list folds them in live via [_listenToRooms]. There is no legacy realtime path.
    _listenToRooms();
    // on<SearchChatUsersEvent>(
    //   (event, emit) async {
    //     if (event.isLoading == true) {
    //       emit(state.copyWith(reqState: RequestState.loading));
    //     }
    //     final result = await _fetchChatsUC(event.userId);
    //     result.fold(
    //       (left) {
    //         emit(
    //           state.copyWith(
    //             error: left,
    //             reqState: handleErrorResponse(left),
    //           ),
    //         );
    //       },
    //       (right) {
    //         emit(
    //           state.copyWith(
    //             data: right.userChatEntity,
    //             totalChatMessages: right.totalChatMessage,
    //             reqState: handleLoadedResponse<List<UserChatEntity>>(
    //                 right.userChatEntity),
    //           ),
    //         );
    //         _listenToChat();
    //       },
    //     );
    //   },
    // );
    on<GetChatUsersEvent>(
      (event, emit) async {
        if (event.isLoading == true) {
          emit(state.copyWith(reqState: RequestState.loading));
        }
        if (event.isRefresh == true) {
          emit(state.copyWith(currentPage: 1));
        }
        final result = await _fetchChatsUC(state.currentPage);
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
                totalChatMessages: right.data!.totalChatMessage,
                reqState: handleLoadedResponse<List<UserChatEntity>>(
                    right.data!.userChatEntity),
                lastPage: right.paginates?.lastPage,
                data: handlePaginationResponse<UserChatEntity>(
                  result: right.data!.userChatEntity,
                  currentList: state.data,
                  currentPage: state.currentPage,
                ),
              ),
            );
          },
        );
      },
    );
    on<AddChatUsersListenerEvent>((event, emit) async {
      final userId = event.userId ?? '';
      if (_scrollCallback != null) {
        state.scrollController.removeListener(_scrollCallback!);
      }
      _scrollCallback = () => _listener(userId);
      state.scrollController.addListener(_scrollCallback!);
    });

    on<RemoveChatUsersListenerEvent>((event, emit) async {
      if (_scrollCallback != null) {
        state.scrollController.removeListener(_scrollCallback!);
        _scrollCallback = null;
      }
    });

    on<UpdateDataLocally>((event, emit) async {
      final List<UserChatEntity> res = List<UserChatEntity>.from(state.data);
      res.removeWhere((element) => element.chatId == event.chatId);
      res.insert(0, event.userChatEntity);
      emit(state.copyWith(data: res));
    });

    // on<GetMoreChatUsersEvent>(
    //   (event, emit) async {
    //     isLoadingMore = true;
    //     final result = await _fetchChatsUC('');
    //     result.fold(
    //       (left) {
    //         isLoadingMore = false;
    //         emit(state.copyWith(error: left, reqState: RequestState.error));
    //       },
    //       (right) {
    //         isLoadingMore = false;
    //         if (right.userChatEntity!.isNotEmpty) {
    //           emit(
    //             state.copyWith(
    //               data: [...state.data, ...right.userChatEntity!],
    //               reqState: RequestState.loaded,
    //             ),
    //           );
    //         }
    //       },
    //     );
    //   },
    // );

    on<RemoveLocalChatUserEvent>((event, emit) async {
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
      // Match by chatId first; if the chat row hasn't been keyed yet (chatId
      // missing when opening from the chats list), fall back to the peer
      // userId so the badge still clears on the row the user just opened.
      var index =
          user_.indexWhere((element) => element.chatId == event.chatId);
      if (index == -1 && event.userId != null && event.userId!.isNotEmpty) {
        index = user_.indexWhere(
          (element) => '${element.userId}' == event.userId,
        );
      }
      if (index != -1) {
        user_[index] = user_[index].copyWith(unreadMessage: 0);
      }
      emit(state.copyWith(data: user_, reqState: RequestState.loaded));
    });

    on<UpdateTotalMessages>((event, emit) {
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
                totalChatMessages: max(
                  0,
                  state.totalChatMessages - x.unreadMessage,
                ),
              ));
              break;
            }
          }
        }
      }
    });

    on<MergeRoomsFromDrift>((event, emit) {
      final merged = _mergeRooms(state.data, event.rooms);
      if (merged == null) return;
      emit(state.copyWith(data: merged, reqState: RequestState.loaded));
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

  void _listener(String params) {
    handleScrollListener(
      controller: state.scrollController,
      currentPage: state.currentPage,
      lastPage: state.lastPage,
      fun: () {
        final int currentPage = state.currentPage + 1;
        emit(state.copyWith(currentPage: currentPage));
        add(
          GetChatUsersEvent(
            userId: params,
            isLoading: false,
          ),
        );
      },
    );
  }

  /// Reactive drift source for the chats list (Centrifugo-only realtime).
  /// Centrifugo writes incoming messages into drift; this watches the same
  /// source the WhatsApp-style list uses and folds DM rooms into [state.data]
  /// live, so the list updates the instant a Centrifugo message lands — without
  /// waiting for a REST refetch.
  void _listenToRooms() {
    _roomsSubscription?.cancel();
    _roomsSubscription = _roomsDao.watchRoomsWithLast().listen((rows) {
      if (isClosed) return;
      final dmRooms = rows
          .where((row) => row.room.type == RoomType.dm)
          .map(RoomToConversationMapper.toUserChat)
          .toList();
      if (dmRooms.isEmpty) return;
      add(MergeRoomsFromDrift(dmRooms));
    });
  }

  /// Folds the reactive drift DM list into the current [current] list, keyed by
  /// [UserChatEntity.chatId] (== server room id). Rows already present are
  /// updated in place (preserving REST-only chats not yet in drift); rows whose
  /// last message changed bubble to the top; genuinely new rooms are inserted at
  /// the top. Returns null when nothing changed so we don't emit (avoids the
  /// list flickering on identical drift ticks).
  List<UserChatEntity>? _mergeRooms(
    List<UserChatEntity> current,
    List<UserChatEntity> dmRooms,
  ) {
    final result = List<UserChatEntity>.from(current);
    var changed = false;
    for (final room in dmRooms) {
      if (room.chatId <= 0) continue;
      var incoming = room;
      // The drift row carries the room's unread count; zero it for rows we're
      // the sender of or are currently viewing.
      final myId = MyDataModel.getInstance().id;
      final lastSenderId = incoming.lastMessage.senderId;
      final iAmTheSender =
          myId != null && lastSenderId != null && myId == lastSenderId;
      final isViewingThisChat =
          currentChatId > 0 && currentChatId == incoming.chatId;
      if (iAmTheSender || isViewingThisChat) {
        incoming = incoming.copyWith(unreadMessage: 0);
      }

      final index =
          result.indexWhere((element) => element.chatId == incoming.chatId);
      if (index == -1) {
        result.insert(0, incoming);
        changed = true;
        continue;
      }
      final existing = result[index];
      if (existing == incoming) continue;
      final movedToTop = index != 0 &&
          existing.lastMessage.id != incoming.lastMessage.id;
      if (movedToTop) {
        result.removeAt(index);
        result.insert(0, incoming);
      } else {
        result[index] = incoming;
      }
      changed = true;
    }
    return changed ? result : null;
  }

  @override
  Future<void> close() async {
    await _roomsSubscription?.cancel();
    if (_scrollCallback != null) {
      state.scrollController.removeListener(_scrollCallback!);
      _scrollCallback = null;
    }
    return super.close();
  }
}
