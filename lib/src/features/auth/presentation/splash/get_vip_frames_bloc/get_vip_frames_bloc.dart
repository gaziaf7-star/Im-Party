import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/vip_frames_model.dart';
import 'package:general/src/features/auth/domain/use_cases/get_vip_frames_uc.dart';

part 'get_vip_frames_event.dart';
part 'get_vip_frames_state.dart';

class GetVipFramesBloc extends Bloc<BaseGetVipFrameEvent, GetVipFramesState> {
  final GetVipFramesUc _getVipFramesUc;

  GetVipFramesBloc(this._getVipFramesUc) : super(const GetVipFramesState()) {
    on<GetVipFramesEvent>(_getVipFramesEvent);
  }

  Future<void> _getVipFramesEvent(
    GetVipFramesEvent event,
    Emitter<GetVipFramesState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await _getVipFramesUc();

    await result.fold(
      (failure) async {
        Methods.printLog('❌ API error: $failure');

        final cachedJson = HiveManager().getData<String>(
          KeysManager.FRAMES_BOX,
          KeysManager.VIP_FRAMES_KEY,
        );

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            final cachedList = decoded
                .map((element) =>
                    VipFramesModel.fromJson(element as Map<String, dynamic>))
                .toList();

            emit(state.copyWith(
              requestState: RequestState.loaded,
              data: cachedList,
            ));
          } catch (e) {
            emit(state.copyWith(requestState: RequestState.error));
          }
        } else {
          emit(state.copyWith(requestState: RequestState.error));
        }
      },
      (right) async {
        final List<VipFramesModel> data =
            List<VipFramesModel>.from(right.data ?? []);
        emit(state.copyWith(requestState: RequestState.loaded, data: data));

        final cachedJson = HiveManager().getData<String>(
          KeysManager.FRAMES_BOX,
          KeysManager.VIP_FRAMES_KEY,
        );

        Map<int, VipFramesModel> cachedMap = {};

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            cachedMap = {
              for (final item in decoded)
                VipFramesModel.fromJson(item).id ?? 0:
                    VipFramesModel.fromJson(item)
            };
          } catch (e) {
            Methods.printLog('❌ Error decoding VIP Frames cache: $e');
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
          }
        }

        final currentIds =
            data.map((element) => element.id).whereType<int>().toSet();
        final idsToRemove =
            cachedMap.keys.where((id) => !currentIds.contains(id)).toList();

        for (final id in idsToRemove) {
          cachedMap.remove(id);
          hasChanges = true;
          Methods.printLog('🗑️ VIP Frame removed from cache (id: $id)');
        }

        if (hasChanges) {
          final updatedJsonList =
              cachedMap.values.map((element) => element.toJson()).toList();

          await HiveManager().saveData(
            KeysManager.FRAMES_BOX,
            KeysManager.VIP_FRAMES_KEY,
            jsonEncode(updatedJsonList),
          );
          Methods.printLog('📥 VIP Frames cache updated.');
        } else {
          Methods.printLog('✅ VIP Frames cache already up-to-date.');
        }
        Methods().saveCurrentUtcTimeToCache(TypesCache.frame);
      },
    );
  }
}
