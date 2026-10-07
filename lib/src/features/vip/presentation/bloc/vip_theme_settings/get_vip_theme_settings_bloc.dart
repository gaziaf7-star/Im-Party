import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/vip/data/models/vip_theme_setting.dart';
import 'package:general/src/features/vip/domain/use_case/get_vip_theme_settings_uc.dart';

part 'get_vip_theme_settings_event.dart';
part 'get_vip_theme_settings_state.dart';

class GetVipThemeSettingsBloc
    extends Bloc<BaseGetVipThemeSettingsEvent, GetVipThemeSettingsState> {
  final GetVipThemeSettingsUc _getVipThemeSettingsUc;

  GetVipThemeSettingsBloc(this._getVipThemeSettingsUc)
      : super(const GetVipThemeSettingsState()) {
    on<GetVipThemeSettingsEvent>(_getVipThemeSettingsEvent);
  }

  Future<void> _getVipThemeSettingsEvent(
    GetVipThemeSettingsEvent event,
    Emitter<GetVipThemeSettingsState> emit,
  ) async {
    emit(state.copyWith(state: RequestState.loading));

    final result = await _getVipThemeSettingsUc();

    await result.fold(
      (failure) async {
        Methods.printLog('❌ API error: $failure');

        final cachedJson = HiveManager().getData<String>(
          KeysManager.VIP_THEME_SETTINGS_BOX,
          KeysManager.VIP_THEME_SETTINGS_KEY,
        );

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            final cachedList = decoded
                .map((e) => VipThemeSetting.fromJson(e as Map<String, dynamic>))
                .toList();

            emit(state.copyWith(
              state: RequestState.loaded,
              data: cachedList,
            ));

            Methods.printLog('📦 Loaded VipThemeSettings from cache.');
          } catch (e) {
            Methods.printLog('❌ Failed to decode cache: $e');
            emit(state.copyWith(state: RequestState.error));
          }
        } else {
          emit(state.copyWith(state: RequestState.error));
        }
      },
      (right) async {
        final List<VipThemeSetting> data =
            List<VipThemeSetting>.from(right.data ?? []);
        emit(state.copyWith(state: RequestState.loaded, data: data));

        final cachedJson = HiveManager().getData<String>(
          KeysManager.VIP_THEME_SETTINGS_BOX,
          KeysManager.VIP_THEME_SETTINGS_KEY,
        );

        Map<int, VipThemeSetting> cachedMap = {};

        if (cachedJson?.isNotEmpty == true) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedJson!);
            cachedMap = {
              for (final item in decoded)
                VipThemeSetting.fromJson(item).vip:
                    VipThemeSetting.fromJson(item)
            };
          } catch (error) {
            Methods.printLog('❌ Error decoding cache: $error');
          }
        }

        bool hasChanges = false;

        // element -> New Item
        for (final element in data) {
          final newVip = element.vip;

          final existingItem = cachedMap[newVip];

          final isNew = existingItem == null;
          final isModified = !isNew &&
              !const DeepCollectionEquality().equals(
                existingItem.toJson(),
                element.toJson(),
              );

          if (isNew || isModified) {
            cachedMap[newVip] = element;
            hasChanges = true;
            final action = isNew ? 'added' : 'updated';
            Methods.printLog('🔁 VipThemeSetting $action (vip: $newVip)');
          }
        }

        final currentVips =
            data.map((element) => element.vip).whereType<int>().toSet();
        final vipsToRemove =
            cachedMap.keys.where((vip) => !currentVips.contains(vip)).toList();

        for (final vip in vipsToRemove) {
          cachedMap.remove(vip);
          hasChanges = true;
          Methods.printLog(
              '🗑️ VipThemeSetting removed from cache (vip: $vip)');
        }

        if (hasChanges) {
          final updatedJsonList =
              cachedMap.values.map((element) => element.toJson()).toList();

          await HiveManager().saveData(
            KeysManager.VIP_THEME_SETTINGS_BOX,
            KeysManager.VIP_THEME_SETTINGS_KEY,
            jsonEncode(updatedJsonList),
          );
          Methods.printLog('📥 VipThemeSettings cache updated.');
        } else {
          Methods.printLog('✅ VipThemeSettings cache already up-to-date.');
        }
      },
    );
  }

  /// Get background URL for a specific VIP level
  String? getBackgroundForVip(int vipLevel) {
    final setting = state.data.firstWhereOrNull((s) => s.vip == vipLevel);
    return setting?.backgroundUrl;
  }
}
