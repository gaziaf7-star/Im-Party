part of 'get_setting_bloc.dart';

abstract class BaseGetSettingEvent extends Equatable {
  const BaseGetSettingEvent();
}

class GetSettingsEvent extends BaseGetSettingEvent {
  const GetSettingsEvent();
  @override
  List<Object?> get props => const [];
}
