import 'package:equatable/equatable.dart';

abstract class FetchUserGiftEvent extends Equatable {
  const FetchUserGiftEvent();
  @override
  List<Object?> get props => [];
}

class FetchAppGiftEvent extends FetchUserGiftEvent {
  const FetchAppGiftEvent();

  @override
  List<Object?> get props => [];
}

class FetchAppGiftImagesEvent extends FetchUserGiftEvent {
  const FetchAppGiftImagesEvent();

  @override
  List<Object?> get props => [];
}