part of 'get_free_games_images_bloc.dart';


class GetFreeGamesImagesState extends Equatable {
  final FreeGamesEntity? data;
  final RequestState? requestState;
  final String? message;

  const GetFreeGamesImagesState({
    this.data,
    this.requestState,
    this.message,
  });

  GetFreeGamesImagesState copyWith({
    FreeGamesEntity? data,
    RequestState? requestState,
    String? message,
  }) {
    return GetFreeGamesImagesState(
      data: data ?? this.data,
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [data, requestState, message];
}



