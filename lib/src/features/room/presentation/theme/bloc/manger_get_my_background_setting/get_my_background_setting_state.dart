part of 'get_my_background_setting_bloc.dart';

class GetMyBackgroundSettingState extends Equatable {
  final BackgroundSettingModel? backgroundSettingData;
  final String message;
  final RequestState requestState;

  const GetMyBackgroundSettingState({
    this.backgroundSettingData,
    this.message = '',
    this.requestState = RequestState.idle,
  });

  GetMyBackgroundSettingState copyWith({
    BackgroundSettingModel? backgroundSettingData,
    String? message,
    RequestState? requestState,
  }) {
    return GetMyBackgroundSettingState(
      backgroundSettingData:
          backgroundSettingData ?? this.backgroundSettingData,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object> get props => [message, requestState];
}
