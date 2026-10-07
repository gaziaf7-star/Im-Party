import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/bubble_padding.dart';
import 'package:general/src/features/room/domain/use_case/get_bubble_pading_uc.dart';

part 'get_bubble_padding_event.dart';
part 'get_bubble_padding_state.dart';

class GetBubblePaddingBloc
    extends Bloc<BaseGetBubblePaddingEvent, GetBubblePaddingState> {
  final GetBubblePaddingUc _getBubblePaddingUc;

  GetBubblePaddingBloc(this._getBubblePaddingUc)
      : super(const GetBubblePaddingState()) {
    on<GetBubblePaddingEvent>(_getBubblePaddingEvent);
  }

  Future<void> _getBubblePaddingEvent(
    GetBubblePaddingEvent event,
    Emitter<GetBubblePaddingState> emit,
  ) async {
    emit(state.copyWith(state: RequestState.loading));

    final result = await _getBubblePaddingUc();

    await result.fold(
      (failure) async {
        Methods.printLog('❌ API error: $failure');

        final cachedJson = HiveManager().getData<String>(
          KeysManager.BUBBLE_PADDING_BOX,
          KeysManager.BUBBLE_PADDING_KEY,
        );

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            final cachedList = decoded
                .map((e) => BubblePadding.fromJson(e as Map<String, dynamic>))
                .toList();

            emit(state.copyWith(
              state: RequestState.loaded,
              data: cachedList,
            ));

            Methods.printLog('📦 Loaded BubblePadding from cache.');
          } catch (e) {
            Methods.printLog('❌ Failed to decode cache: $e');
            emit(state.copyWith(state: RequestState.error));
          }
        } else {
          emit(state.copyWith(state: RequestState.error));
        }
      },
      (right) async {
        final List<BubblePadding> data =
            List<BubblePadding>.from(right.data ?? []);
        emit(state.copyWith(state: RequestState.loaded, data: data));

        final cachedJson = HiveManager().getData<String>(
          KeysManager.BUBBLE_PADDING_BOX,
          KeysManager.BUBBLE_PADDING_KEY,
        );

        Map<int, BubblePadding> cachedMap = {};

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            cachedMap = {
              for (final item in decoded)
                BubblePadding.fromJson(item).id: BubblePadding.fromJson(item)
            };
          } catch (error) {
            Methods.printLog('❌ Error decoding cache: $error');
          }
        }

        bool hasChanges = false;

        // element -> New Item
        for (final element in data) {
          final newId = element.id;

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
            Methods.printLog('🔁 BubblePadding $action (id: $newId)');
          }
        }

        final currentIds =
            data.map((element) => element.id).whereType<int>().toSet();
        final idsToRemove =
            cachedMap.keys.where((id) => !currentIds.contains(id)).toList();

        for (final id in idsToRemove) {
          cachedMap.remove(id);
          hasChanges = true;
          Methods.printLog('🗑️ BubblePadding removed from cache (id: $id)');
        }

        if (hasChanges) {
          final updatedJsonList =
              cachedMap.values.map((element) => element.toJson()).toList();

          await HiveManager().saveData(
            KeysManager.BUBBLE_PADDING_BOX,
            KeysManager.BUBBLE_PADDING_KEY,
            jsonEncode(updatedJsonList),
          );
          Methods.printLog('📥 BubblePadding cache updated.');
        } else {
          Methods.printLog('✅ BubblePadding cache already up-to-date.');
        }
        Methods().saveCurrentUtcTimeToCache(TypesCache.bubble);
      },
    );
  }
}
