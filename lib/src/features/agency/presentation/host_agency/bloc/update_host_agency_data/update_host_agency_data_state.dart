part of 'update_host_agency_data_bloc.dart';

class UpdateHostAgencyDataState extends Equatable {
  final String message;
  final InformationAgencyEntity? data;
  final RequestState requestState;
  final String pathImg;
  final File? imageFile;

  const UpdateHostAgencyDataState({
    this.message = '',
    this.pathImg = '',
    this.data,
    this.imageFile,
    this.requestState = RequestState.idle,
  });

  /// Creates a copy of the current state with updated values.
  UpdateHostAgencyDataState copyWith(
      {String? message,
      String? pathImg,
      InformationAgencyEntity? data,
      RequestState? requestState,
      File? imageFile}) {
    return UpdateHostAgencyDataState(
      message: message ?? this.message,
      pathImg: pathImg ?? this.pathImg,
      data: data ?? this.data,
      requestState: requestState ?? this.requestState,
      imageFile: imageFile ?? this.imageFile,
    );
  }

  @override
  List<Object?> get props => [message, pathImg, imageFile, data, requestState];
}
