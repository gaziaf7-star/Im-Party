part of 'get_wabbles_bloc.dart';

abstract class BaseWabblesEvent extends Equatable {
  const BaseWabblesEvent();
  @override
  List<Object?> get props => [];
}

final class GetWabblesEvent extends BaseWabblesEvent {}
