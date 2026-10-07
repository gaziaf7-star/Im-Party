part of 'theme_bloc.dart';

class ThemeStates extends Equatable {
  final List<BackGroundEntity> backgroundList;
  final String message;
  final RequestState requestState;
  final String imageId;

  const ThemeStates({
    this.backgroundList=const [], 
    this.message = '', 
    this.requestState = RequestState.idle,
    this.imageId = '', 
  });

  ThemeStates copyWith({
    List<BackGroundEntity>? backgroundList,
    String? message,
    RequestState? requestState,
    String? imageId,
  }) {
    return ThemeStates(
      backgroundList: backgroundList ?? this.backgroundList,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
      imageId: imageId ?? this.imageId,
    );
  }
  @override
  List<Object> get props => [backgroundList, message, requestState, imageId];
}