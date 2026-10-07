import 'dart:async';
import 'package:general/src/features/chats/chats.dart';

part 'system_chat_events.dart';

part 'system_chat_states.dart';

class GetSystemChatBloc extends Bloc<SystemChatEvents, GetSystemChatsStates> {
  final GetSystemChatUC _getSystemChatUC;

  GetSystemChatBloc({required GetSystemChatUC getSystemChatUC})
      : _getSystemChatUC = getSystemChatUC,
        super(const GetSystemChatsStates()) {
    on<GetSystemChatEvent>(_fetchSystemMessageEvent);
    on<GetOfficialChatEvent>(_fetchOfficialMessageEvent);
    on<LoadMoreSystemChatEvent>(_loadMoreSystemMessages);
    on<LoadMoreOfficialChatEvent>(_loadMoreOfficialMessages);
  }

  FutureOr<void> _fetchSystemMessageEvent(
    GetSystemChatEvent event,
    Emitter<GetSystemChatsStates> emit,
  ) async {
    emit(state.copyWith(systemReqState: RequestState.loading, systemPage: 1));

    final result =
        await _getSystemChatUC(const SystemOfficialParam(type: 1, page: 1));
    result.fold(
      (left) => emit(state.copyWith(systemReqState: handleErrorResponse(left))),
      (right) {
        emit(state.copyWith(
          systemEntity: right.data ?? [],
          systemReqState: handleLoadedResponse(right.data),
          hasReachedMaxSystem: (right.data?.isEmpty ?? true),
        ));
      },
    );
  }

  FutureOr<void> _loadMoreSystemMessages(
    LoadMoreSystemChatEvent event,
    Emitter<GetSystemChatsStates> emit,
  ) async {
    if (state.hasReachedMaxSystem) return;

    final nextPage = state.systemPage + 1;
    final result =
        await _getSystemChatUC(SystemOfficialParam(type: 1, page: nextPage));

    result.fold(
      (left) => null, // ممكن تحط Error handling هنا
      (right) {
        final newData = right.data ?? [];
        emit(state.copyWith(
          systemEntity: [...state.systemEntity, ...newData],
          systemPage: nextPage,
          hasReachedMaxSystem: newData.isEmpty,
        ));
      },
    );
  }

  FutureOr<void> _fetchOfficialMessageEvent(
    GetOfficialChatEvent event,
    Emitter<GetSystemChatsStates> emit,
  ) async {
    emit(state.copyWith(
        officialReqState: RequestState.loading, officialPage: 1));

    final result =
        await _getSystemChatUC(const SystemOfficialParam(type: 2, page: 1));
    result.fold(
      (left) =>
          emit(state.copyWith(officialReqState: handleErrorResponse(left))),
      (right) {
        emit(state.copyWith(
          officialEntity: right.data ?? [],
          officialReqState: handleLoadedResponse(right.data),
          hasReachedMaxOfficial: (right.data?.isEmpty ?? true),
        ));
      },
    );
  }

  FutureOr<void> _loadMoreOfficialMessages(
    LoadMoreOfficialChatEvent event,
    Emitter<GetSystemChatsStates> emit,
  ) async {
    if (state.hasReachedMaxOfficial) return;

    final nextPage = state.officialPage + 1;
    final result =
        await _getSystemChatUC(SystemOfficialParam(type: 2, page: nextPage));

    result.fold(
      (left) => null,
      (right) {
        final newData = right.data ?? [];
        emit(state.copyWith(
          officialEntity: [...state.officialEntity, ...newData],
          officialPage: nextPage,
          hasReachedMaxOfficial: newData.isEmpty,
        ));
      },
    );
  }
}
