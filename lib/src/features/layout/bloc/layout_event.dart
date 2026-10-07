part of 'layout_bloc.dart';

sealed class LayoutEvent extends Equatable {
  final int currentIdex;

  const LayoutEvent({this.currentIdex = 0});

  @override
  List<Object?> get props => [currentIdex];
}

final class ChangeIndexEvent extends LayoutEvent {
  const ChangeIndexEvent({super.currentIdex});
}
