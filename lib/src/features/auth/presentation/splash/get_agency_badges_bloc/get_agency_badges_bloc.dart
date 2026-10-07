import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/agency_badge_model.dart';
import 'package:general/src/features/auth/domain/use_cases/get_agency_badges_uc.dart';

part 'get_agency_badges_event.dart';
part 'get_agency_badges_state.dart';

class GetAgencyBadgesBloc
    extends Bloc<BaseAgencyBadgesEvent, GetAgencyBadgesState> {
  final GetAgencyBadgesUc _getAgencyBadgesUc;

  GetAgencyBadgesBloc(this._getAgencyBadgesUc)
      : super(const GetAgencyBadgesState()) {
    on<GetAgencyBadgesEvent>(_getAgencyBadgesEvent);
  }

  Future<void> _getAgencyBadgesEvent(
    GetAgencyBadgesEvent event,
    Emitter<GetAgencyBadgesState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await _getAgencyBadgesUc();

    await result.fold(
      (failure) async {
        Methods.printLog('❌ API error: $failure');

        final cachedJson = HiveManager().getData<String>(
          KeysManager.AGENCY_BADDES_BOX,
          KeysManager.AGENCY_BADGES_KEY,
        );

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            final cachedList =
                decoded.map((e) => AgencyBadgeModel.fromJson(e)).toList();

            emit(state.copyWith(
              requestState: RequestState.loaded,
              data: cachedList,
            ));

            Methods.printLog('📦 Loaded AgencyBadges from cache.');
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
          KeysManager.AGENCY_BADDES_BOX,
          KeysManager.AGENCY_BADGES_KEY,
        );

        Map<int, AgencyBadgeModel> cachedMap = {};

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            cachedMap = {
              for (final item in decoded)
                AgencyBadgeModel.fromJson(item).id ?? 0:
                    AgencyBadgeModel.fromJson(item)
            };
          } catch (e) {
            Methods.printLog('❌ Error decoding cache: $e');
          }
        }

        bool hasChanges = false;

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
            Methods.printLog('🔁 AgencyBadge $action (id: $newId)');
          }
        }

        final currentIds =
            data.map((element) => element.id).whereType<int>().toSet();
        final idsToRemove =
            cachedMap.keys.where((id) => !currentIds.contains(id)).toList();

        for (final id in idsToRemove) {
          cachedMap.remove(id);
          hasChanges = true;
          Methods.printLog('🗑️ AgencyBadge removed from cache (id: $id)');
        }

        if (hasChanges) {
          final updatedJsonList =
              cachedMap.values.map((element) => element.toJson()).toList();

          await HiveManager().saveData(
            KeysManager.AGENCY_BADDES_BOX,
            KeysManager.AGENCY_BADGES_KEY,
            jsonEncode(updatedJsonList),
          );
          Methods.printLog('📥 AgencyBadges cache updated.');
        } else {
          Methods.printLog('✅ AgencyBadges cache already up-to-date.');
        }
        Methods().saveCurrentUtcTimeToCache(TypesCache.badges);
      },
    );
  }
}
