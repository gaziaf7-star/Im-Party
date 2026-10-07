part of 'games_images_bloc.dart';

class GamesImagesState extends Equatable {
  final RequestState state;
  final String message;
  final SvgaDataModel? data;

  const GamesImagesState({
    this.state = RequestState.idle,
    this.message = '',
    this.data,
  });

  GamesImagesState copyWith({
    RequestState? state,
    String? message,
    SvgaDataModel? data,
  }) {
    return GamesImagesState(
      state: state ?? this.state,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [state, message, data ?? ''];
}
