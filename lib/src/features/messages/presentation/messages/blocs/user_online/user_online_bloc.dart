import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

part 'user_online_event.dart';
part 'user_online_state.dart';

class UserOnlineBloc extends Bloc<BaseUserOnlineEvent, UserOnlineState> {
  final OnlineUserUC _onlineUserUC;

  /// The peer currently being watched (set by [UserOnlineEvent]); the poll uses
  /// it so it always refreshes the chat that is open.
  String? _watchedUserId;

  /// ~10s poll keeps presence live while the conversation is open. Used as the
  /// fallback for environments without a presence-chat.user.{id} channel; pushed
  /// [UserPresenceChangedEvent]s update the same state with no extra cost.
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 10);

  UserOnlineBloc(this._onlineUserUC) : super(const UserOnlineState()) {
    on<UserOnlineEvent>(_userOnlineEvent);
    on<UserPresenceChangedEvent>(_userPresenceChangedEvent);
    on<_UserPresencePollEvent>(_userPresencePollEvent);
    on<StopUserPresenceEvent>(_stopUserPresenceEvent);
  }

  Future<void> _userOnlineEvent(
    UserOnlineEvent event,
    Emitter<UserOnlineState> emit,
  ) async {
    _watchedUserId = event.userId;
    emit(state.copyWith(reqState: RequestState.loading, online: 0));
    await _fetch(emit);
    _startPolling();
  }

  /// Realtime push (presence channel) — apply directly, no network round-trip.
  void _userPresenceChangedEvent(
    UserPresenceChangedEvent event,
    Emitter<UserOnlineState> emit,
  ) {
    emit(
      state.copyWith(
        online: event.online,
        lastSeen: event.lastSeen,
        reqState: RequestState.loaded,
      ),
    );
  }

  /// Poll tick: silently refresh (no loading flicker) so the header label flips
  /// between online / last-seen as the peer comes and goes.
  Future<void> _userPresencePollEvent(
    _UserPresencePollEvent event,
    Emitter<UserOnlineState> emit,
  ) async {
    await _fetch(emit);
  }

  void _stopUserPresenceEvent(
    StopUserPresenceEvent event,
    Emitter<UserOnlineState> emit,
  ) {
    _stopPolling();
    _watchedUserId = null;
  }

  Future<void> _fetch(Emitter<UserOnlineState> emit) async {
    final userId = _watchedUserId;
    if (userId == null) return;
    final result = await _onlineUserUC.call(userId);
    if (emit.isDone) return;
    result.fold(
      (left) {
        // Keep the last known presence on a transient poll failure; only mark
        // error on the very first load (when nothing is shown yet).
        if (state.reqState == RequestState.loading) {
          emit(state.copyWith(reqState: RequestState.error));
        }
      },
      (right) => emit(
        state.copyWith(
          online: right.online,
          lastSeen: right.lastSeen,
          reqState: RequestState.loaded,
        ),
      ),
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) {
        if (isClosed) return;
        add(const _UserPresencePollEvent());
      },
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
