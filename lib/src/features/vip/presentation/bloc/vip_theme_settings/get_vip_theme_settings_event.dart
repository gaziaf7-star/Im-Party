part of 'get_vip_theme_settings_bloc.dart';

abstract class BaseGetVipThemeSettingsEvent extends Equatable {
  const BaseGetVipThemeSettingsEvent();

  @override
  List<Object?> get props => [];
}

class GetVipThemeSettingsEvent extends BaseGetVipThemeSettingsEvent {
  const GetVipThemeSettingsEvent();
}
