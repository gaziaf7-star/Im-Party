part of 'get_vip_theme_settings_bloc.dart';

class GetVipThemeSettingsState extends Equatable {
  final RequestState state;
  final List<VipThemeSetting> data;

  const GetVipThemeSettingsState({
    this.state = RequestState.idle,
    this.data = const [],
  });

  GetVipThemeSettingsState copyWith({
    RequestState? state,
    List<VipThemeSetting>? data,
  }) {
    return GetVipThemeSettingsState(
      state: state ?? this.state,
      data: data ?? this.data,
    );
  }

  /// Get background URL for a specific VIP level
  String? getBackgroundForVip(int vipLevel) {
    final setting = data.firstWhereOrNull((s) => s.vip == vipLevel);
    return setting?.backgroundUrl;
  }

  @override
  List<Object?> get props => [state, data];
}
