part of 'config_app_bloc.dart';

abstract class BaseConfigAppEvent extends Equatable {
  const BaseConfigAppEvent();
  @override
  List<Object?> get props => [];
}

final class ConfigAppEvent extends BaseConfigAppEvent {
  final String versionApp;
  final String devicePLATFORM;



  const ConfigAppEvent({
    required this.versionApp,
    required this.devicePLATFORM,

  });

  @override
  List<Object?> get props => [versionApp , devicePLATFORM];
}

