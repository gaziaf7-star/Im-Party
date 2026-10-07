part of 'update_room_bloc.dart';

class UpdateRoomStates extends Equatable {
  final EnterRoomModel? data;
  final String error;
  final String successMessage;
  final RequestState requestState;

  final String imagePath;
  final String errorPickImage;
  final RequestState requestStatePickImage;

  const UpdateRoomStates({
    this.data, // Default empty list
    this.error = '', // Default empty error message
    this.successMessage = '', // Default empty error message
    this.requestState = RequestState.idle,
    this.imagePath = '', // Default empty list
    this.errorPickImage = '', // Default empty error message
    this.requestStatePickImage = RequestState.idle, // Default request state
  });

  UpdateRoomStates copyWith({
    EnterRoomModel? data,
    String? error,
    String? successMessage,
    RequestState? requestState,
    String? imagePath,
    String? errorPickImage,
    RequestState? requestStatePickImage,
  }) {
    return UpdateRoomStates(
      data: data ?? this.data,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
      requestState: requestState ?? this.requestState,
      imagePath: imagePath ?? this.imagePath,
      errorPickImage: errorPickImage ?? this.errorPickImage,
      requestStatePickImage:
          requestStatePickImage ?? this.requestStatePickImage,
    );
  }
  @override
  List<Object?> get props => [
    data,
    error,
    successMessage,
    requestState,
    imagePath,
    errorPickImage,
    requestStatePickImage,
  ];
}