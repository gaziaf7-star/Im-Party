import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:general/src/features/room/domain/use_case/get_charisma_extra_data_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_charisma_levels_uc.dart';
import 'package:general/src/features/room/domain/use_case/start_charisma_uc.dart';
import 'package:general/src/features/room/domain/use_case/reset_charisma_uc.dart';
import 'package:general/src/features/room/presentation/manager/room_mode/room_mode_cubit.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../../core/index.dart';

part 'charisma_event.dart';
part 'charisma_state.dart';

/// Charisma is SERVER-AUTHORITATIVE: the backend owns the per-room, per-receiver
/// cumulative total (RoomCharismaStore) and ships the resulting TOTAL inside the
/// gift `showGifts` frame (receiver_charisma_totals) and the enter-room payload
/// (per-seat charisma_total + owner_charisma_total). This bloc is PURE RENDER:
/// it writes [CharismaState.data] from those server totals and looks up the
/// badge tier image. No client accumulation, no rebroadcast, no resync, no
/// dedup — the server is the only source of truth.
class CharismaBloc extends Bloc<CharismaEvent, CharismaState> {
  final StartCharismaUC startCharismaUC;
  final ResetCharismaUC resetCharismaUC;
  final GetCharismaExtraDataUC getCharismaExtraDataUC;
  final GetCharismaLevelsUC getCharismaLevelsUC;

  /// Static cache for charisma levels — persists across Bloc resets/room switches.
  /// Loaded once from API at app startup and reused for the entire app lifecycle.
  static List<CharismaLevelModel> _cachedLevels = [];

  /// Returns the charisma level image for a given points total.
  /// Uses the static cached levels — independent of Bloc state lifecycle.
  static String? getLevelImage(int points) {
    if (_cachedLevels.isEmpty) return null;
    final sorted = List<CharismaLevelModel>.from(_cachedLevels)
      ..sort((a, b) => b.points.compareTo(a.points));
    for (final level in sorted) {
      if (points >= level.points) {
        return level.image;
      }
    }
    return null;
  }

  CharismaBloc({
    required this.startCharismaUC,
    required this.resetCharismaUC,
    required this.getCharismaExtraDataUC,
    required this.getCharismaLevelsUC,
  }) : super(const CharismaState()) {
    on<StartCharismaEvent>(startCharisma);
    on<GetCharismaExtraDataEvent>(getCharismaExtraData);
    on<ResetCharismaEvent>(resetCharisma);
    on<InitCharismaEvent>(initialCharisma);
    on<UpdateCharismaEvent>(updateCharisma);
    on<FetchCharismaLevelsEvent>(_fetchCharismaLevels);
    on<AccumulateCharismaFromGiftEvent>(_accumulateCharismaFromGift);
  }

  Future<void> startCharisma(
      StartCharismaEvent event, Emitter<CharismaState> emit) async {
    emit(state.copyWith(reqStateStart: RequestState.loading));
    final result = await startCharismaUC.call(event.roomId);

    // The bloc is resetLazySingleton'd on room exit; if the user left while
    // the request was in flight, adding below would throw add-after-close.
    if (isClosed) return;

    result.fold(
      (l) {
        emit(state.copyWith(
            errorMsgStart: NetworkExceptions.getErrorMessage(l),
            reqStateStart: RequestState.error));
      },
      (r) {
        final bool isEnabled = r.data!['charisma_status'] == true;
        // Remember an owner's OFF per room, so the automatic turn-on on
        // entry (see onEnterRoomSuccess) respects it; ON clears it.
        CharismaPrefs.setTurnedOff(event.roomId, !isEnabled);

        // Reflect the toggle in the in-room UI immediately for the acting user,
        // mirroring what the RTM startCharisma/closeCharisma handlers do for
        // remote members. Without this the badge only appears/disappears once
        // the delayed RTM echo arrives or the user re-enters the room.
        RoomData.instance.isCharismaVisible.value = isEnabled;
        di<RoomOverlayCubit>().setCharismaVisible(isEnabled);

        emit(
          state.copyWith(
            stateCharisma: isEnabled,
            reqStateStart: RequestState.loaded,
          ),
        );

        // A toggle (on OR off) resets the per-room store on the backend, so the
        // local seat totals must clear too — they will be re-seeded by the next
        // gift frame / enter-room payload.
        add(const InitCharismaEvent());
      },
    );
  }

  /// Loads room extra-data (active lucky boxes + super-boom state) on entry and
  /// after a lucky-box pickup. Charisma is sourced from server frames/enter-room,
  /// NOT here; its charisma payload is intentionally ignored.
  Future<void> getCharismaExtraData(
      GetCharismaExtraDataEvent event, Emitter<CharismaState> emit) async {
    await getCharismaExtraDataUC.call(event.roomId);
  }

  /// Resets charisma for the whole room. Calls the server reset endpoint, which
  /// clears the per-room store (RoomCharismaStore) and broadcasts a zeroed
  /// showGifts frame to every client. The local InitCharismaEvent clears this
  /// client's render immediately as instant feedback; the authoritative zeroing
  /// for all clients (including this one) arrives via the broadcast.
  Future<void> resetCharisma(
    ResetCharismaEvent event,
    Emitter<CharismaState> emit,
  ) async {
    emit(state.copyWith(reqStateReset: RequestState.loading));

    final result = await resetCharismaUC.call(
      ResetCharismaParam(roomId: event.roomId, ownerId: event.ownerId),
    );

    if (isClosed) return;

    result.fold(
      (l) {
        emit(state.copyWith(
          errorMsgReset: NetworkExceptions.getErrorMessage(l),
          reqStateReset: RequestState.error,
        ));
      },
      (r) {
        add(const InitCharismaEvent());
        RoomData.instance.isCharismaVisible.value = true;
        di<RoomOverlayCubit>().setCharismaVisible(true);
        emit(state.copyWith(reqStateReset: RequestState.loaded));
      },
    );
  }

  Future<void> initialCharisma(
      InitCharismaEvent event, Emitter<CharismaState> emit) async {
    emit(state.copyWith(data: null));
    // A toggle / reset / charisma-off clears the server store, so the saved
    // copy is stale too.
    CharismaCache.clear();
  }

  /// Writes the authoritative server totals into the render state. Each entry's
  /// [CharismaModel.totalValue] is the floored coin total the backend shipped;
  /// the server is the source of truth, so a new value always replaces the old
  /// (no monotonic guard).
  Future<void> updateCharisma(
    UpdateCharismaEvent event,
    Emitter<CharismaState> emit,
  ) async {
    emit(state.copyWith(reqStateExtraData: RequestState.idle));

    final List<CharismaModel> temp = List.of(state.data ?? []);

    for (final newItem in event.data) {
      final existingIndex =
          temp.indexWhere((user) => user.userId == newItem.userId);
      if (existingIndex != -1) {
        temp[existingIndex] = newItem;
      } else {
        temp.add(newItem);
      }
    }

    emit(state.copyWith(
      data: temp,
      reqStateExtraData: RequestState.loaded,
    ));
    CharismaCache.save(temp);
  }

  /// See [AccumulateCharismaFromGiftEvent] — adds the per-gift value onto
  /// each receiver's current total (read from this bloc's own state), then
  /// writes the results the same way [updateCharisma] does.
  Future<void> _accumulateCharismaFromGift(
    AccumulateCharismaFromGiftEvent event,
    Emitter<CharismaState> emit,
  ) async {
    if (event.giftValue <= 0 || event.receiverIds.isEmpty) return;

    final existing = state.data ?? const <CharismaModel>[];
    final updates = <CharismaModel>[];
    for (final rid in event.receiverIds) {
      final userId = int.tryParse(rid) ?? 0;
      if (userId <= 0) continue;
      var currentTotal = 0;
      for (final e in existing) {
        if (e.userId == userId) {
          currentTotal = e.totalValue;
          break;
        }
      }
      final newTotal = currentTotal + event.giftValue;
      updates.add(
        CharismaModel(
          userId: userId,
          total: Methods().convertToAbbreviatedString(newTotal),
          position: 0,
          totalValue: newTotal,
        ),
      );
    }
    if (updates.isEmpty) return;
    add(UpdateCharismaEvent(data: updates));
  }

  Future<void> _fetchCharismaLevels(
    FetchCharismaLevelsEvent event,
    Emitter<CharismaState> emit,
  ) async {
    // If levels are already cached, skip API call
    if (_cachedLevels.isNotEmpty) {
      debugPrint('[CharismaLevels] Using cached levels: ${_cachedLevels.length}');
      return;
    }

    try {
      final levels = await getCharismaLevelsUC.call();
      _cachedLevels = levels;
      debugPrint('[CharismaLevels] Fetched and cached ${levels.length} levels');
    } catch (e) {
      debugPrint('[CharismaLevels] Failed to fetch: $e');
    }
  }
}

/// This phone's copy of every seat's charisma total, per room.
///
/// The server only sends the owner's total on entry (`microphones` is empty
/// with the UTD seats), so everyone else showed 0 after leaving and coming
/// back. Every total this phone sees is saved here and shown again on
/// re-entry until a newer server value replaces it. A reset is detected when
/// the server's owner total is below the saved one.
class CharismaCache {
  /// Room the totals belong to (set when entering a room).
  static String? roomId;

  static const Duration _maxAge = Duration(days: 3);

  static String _key(String id) => 'charisma_cache_$id';

  static Future<void> save(List<CharismaModel> data) async {
    final id = roomId;
    if (id == null || id.isEmpty) return;
    try {
      final totals = <String, int>{
        for (final e in data)
          if (e.userId > 0 && e.totalValue > 0) '${e.userId}': e.totalValue,
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key(id),
        jsonEncode({'t': DateTime.now().millisecondsSinceEpoch, 'd': totals}),
      );
    } catch (_) {}
  }

  static Future<Map<int, int>> load(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(id));
      if (raw == null) return const {};
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = int.tryParse('${json['t'] ?? 0}') ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - savedAt;
      if (age > _maxAge.inMilliseconds) {
        await prefs.remove(_key(id));
        return const {};
      }
      final d = json['d'];
      if (d is! Map) return const {};
      return {
        for (final e in d.entries)
          if ((int.tryParse('${e.key}') ?? 0) > 0)
            int.parse('${e.key}'): int.tryParse('${e.value}') ?? 0,
      };
    } catch (_) {
      return const {};
    }
  }

  static Future<void> clear([String? id]) async {
    final key = id ?? roomId;
    if (key == null || key.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(key));
    } catch (_) {}
  }
}

/// Remembers, per room, that the owner switched charisma OFF. Charisma is on
/// by default: the owner's entry turns it on unless this says they turned
/// it off themselves.
class CharismaPrefs {
  static String _key(String roomId) => 'charisma_off_$roomId';

  static Future<bool> isTurnedOff(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key(roomId)) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setTurnedOff(String roomId, bool off) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (off) {
        await prefs.setBool(_key(roomId), true);
      } else {
        await prefs.remove(_key(roomId));
      }
    } catch (_) {}
  }
}
