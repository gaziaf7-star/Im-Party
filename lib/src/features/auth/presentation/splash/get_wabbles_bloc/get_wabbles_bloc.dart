import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/wabbles_model.dart';
import 'package:general/src/features/auth/domain/use_cases/get_wabbles_uc.dart';

part 'get_wabbles_event.dart';
part 'get_wabbles_state.dart';

class GetWabblesBloc extends Bloc<BaseWabblesEvent, GetWabblesState> {
  final GetWabblesUc _getWabblesUc;

  GetWabblesBloc(this._getWabblesUc) : super(const GetWabblesState()) {
    on<GetWabblesEvent>(_getWabblesEvent);
  }

  Future<void> _getWabblesEvent(
    GetWabblesEvent event,
    Emitter<GetWabblesState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await _getWabblesUc();

    await result.fold(
      (failure) async {
        Methods.printLog('❌ API error: $failure');

        final cachedJson = HiveManager().getData<String>(
          KeysManager.WABBLES_BOX,
          KeysManager.WABBLES_KEY,
        );

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            final cachedList = decoded
                .map((element) =>
                    WabblesModel.fromJson(element as Map<String, dynamic>))
                .toList();

            emit(state.copyWith(
              requestState: RequestState.loaded,
              data: cachedList,
            ));

            Methods.printLog('📦 Loaded Wabbles from cache.');
          } catch (e) {
            Methods.printLog('❌ Failed to decode cache: $e');
            emit(state.copyWith(requestState: RequestState.error));
          }
        } else {
          emit(state.copyWith(requestState: RequestState.error));
        }
      },
      (data) async {
        emit(state.copyWith(requestState: RequestState.loaded, data: data));

        final cachedJson = HiveManager().getData<String>(
          KeysManager.WABBLES_BOX,
          KeysManager.WABBLES_KEY,
        );

        Map<int, WabblesModel> cachedMap = {};

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            cachedMap = {
              for (final item in decoded)
                WabblesModel.fromJson(item).id ?? 0: WabblesModel.fromJson(item)
            };
          } catch (e) {
            Methods.printLog('❌ Error decoding cache: $e');
          }
        }

        bool hasChanges = false;

        // element -> New Item
        for (final element in data) {
          final newId = element.id;
          if (newId == null) continue;

          final existingItem = cachedMap[newId];

          final isNew = existingItem == null;
          final isModified = !isNew &&
              !const DeepCollectionEquality().equals(
                existingItem.toJson(),
                element.toJson(),
              );

          if (isNew || isModified) {
            cachedMap[newId] = element;
            hasChanges = true;
            final action = isNew ? 'added' : 'updated';
            Methods.printLog('🔁 Wabble $action (id: $newId)');
          }
        }

        final currentIds =
            data.map((element) => element.id).whereType<int>().toSet();
        final idsToRemove =
            cachedMap.keys.where((id) => !currentIds.contains(id)).toList();

        for (final id in idsToRemove) {
          cachedMap.remove(id);
          hasChanges = true;
          Methods.printLog('🗑️ Wabble removed from cache (id: $id)');
        }

        if (hasChanges) {
          final updatedJsonList =
              cachedMap.values.map((element) => element.toJson()).toList();

          await HiveManager().saveData(
            KeysManager.WABBLES_BOX,
            KeysManager.WABBLES_KEY,
            jsonEncode(updatedJsonList),
          );
          Methods.printLog('📥 Wabbles cache updated.');
        } else {
          Methods.printLog('✅ Wabbles cache already up-to-date.');
        }
        Methods().saveCurrentUtcTimeToCache(TypesCache.wabbles);
      },
    );
  }
}
