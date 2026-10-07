part of 'games_images_bloc.dart';

class FetchGamesImagesEvent extends Equatable {
  final bool isFirstLoad;

  const FetchGamesImagesEvent({
    this.isFirstLoad = false,
  });

  @override
  List<Object?> get props => [ isFirstLoad];
}
