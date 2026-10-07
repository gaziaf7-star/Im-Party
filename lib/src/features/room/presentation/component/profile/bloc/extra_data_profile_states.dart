part of 'extra_data_profile_bloc.dart';

class FetchExtraDataStates extends Equatable {
  final ExtraProfileDataModel? extraProfileData;
  final RequestState requestState;
  final String extraDataMessage;

  const FetchExtraDataStates({
    this.extraProfileData,
    this.extraDataMessage = '',
    this.requestState = RequestState.idle,
  });

  FetchExtraDataStates copyWith({
    ExtraProfileDataModel? extraProfileData,
    String? extraDataMessage,
    RequestState? requestState,
  }) {
    return FetchExtraDataStates(
      extraProfileData: extraProfileData ?? this.extraProfileData,
      extraDataMessage: extraDataMessage ?? this.extraDataMessage,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [
    extraProfileData,
        extraDataMessage,
        requestState,
      ];
}
