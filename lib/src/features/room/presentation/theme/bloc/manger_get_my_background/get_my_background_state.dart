import 'package:equatable/equatable.dart';
import 'package:general/src/features/room/room.dart';

abstract class GetMyBackgroundState extends Equatable {
  final List<BackgroundModel> data;
  const GetMyBackgroundState({this.data = const []});

  @override
  List<Object?> get props => [data];
}

class GetMyBackgroundInitial extends GetMyBackgroundState {
  const GetMyBackgroundInitial();
}

class GetMyBackgroundLoadingState extends GetMyBackgroundState {
  const GetMyBackgroundLoadingState();
}

class GetMyBackgroundSuccessState extends GetMyBackgroundState {
  const GetMyBackgroundSuccessState({required super.data});
}

class GetMyBackgroundErrorState extends GetMyBackgroundState {
  final String error;
  const GetMyBackgroundErrorState({required this.error});
  @override
  List<Object> get props => [error];
}

