import 'package:equatable/equatable.dart';
import 'package:general/src/features/room/data/model/get_config_key_model.dart';

abstract class GetConfigKeysState extends Equatable {
  const GetConfigKeysState();

  @override
  List<Object> get props => [];
}

class GetConfigKeysInitial extends GetConfigKeysState {}

class GetConfigKeysLoading extends GetConfigKeysState {}

class GetConfigKeysSucsses extends GetConfigKeysState {
  final GetConfigKeyModel getConfigKey;
  const GetConfigKeysSucsses({required this.getConfigKey});
}

class GetConfigKeysError extends GetConfigKeysState {
  final String error;
  const GetConfigKeysError({required this.error});
}
