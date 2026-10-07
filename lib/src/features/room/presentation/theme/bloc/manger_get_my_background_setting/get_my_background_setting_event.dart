part of 'get_my_background_setting_bloc.dart';

abstract class BaseGetMyBackgroundEvent extends Equatable {
  const BaseGetMyBackgroundEvent();

  @override
  List<Object?> get props => [];
}



class GetMyBackgroundSettingEvent extends BaseGetMyBackgroundEvent{
  final BuildContext context;
  const GetMyBackgroundSettingEvent({required this.context});
    @override
  List<Object?> get props => [context];
}
