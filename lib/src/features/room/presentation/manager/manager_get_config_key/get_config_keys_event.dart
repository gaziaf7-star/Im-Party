import 'package:general/src/core/index.dart';

abstract class BaseGetConfigKeysEvent extends Equatable {
  const BaseGetConfigKeysEvent();

  @override
  List<Object> get props => [];
}

class GetConfigKeyEvent extends BaseGetConfigKeysEvent {
  final GetConfigKeyPram getConfigKeyPram;
  const GetConfigKeyEvent({required this.getConfigKeyPram});
}
