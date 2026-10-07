
abstract class OpenGameState {}

class OpenGameInitial extends OpenGameState {}

class OpenGameLoadingState extends OpenGameState {}

class OpenGameErrorState extends OpenGameState {
  final String error;
  OpenGameErrorState({required this.error});
}

class OpenGameSuccessState extends OpenGameState {
  final String message;
  OpenGameSuccessState({required this.message});
}
