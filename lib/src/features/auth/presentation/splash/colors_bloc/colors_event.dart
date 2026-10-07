part of 'colors_bloc.dart';

sealed class ColorsEvent extends Equatable {
  const ColorsEvent();

  @override
  List<Object?> get props => [];
}

final class FetchColorsEvent extends ColorsEvent {
  final bool forceRefresh;

  const FetchColorsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
