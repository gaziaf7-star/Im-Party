import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/data/model/close_effect_model.dart';

abstract class ClearModeState extends Equatable {
  const ClearModeState();
  @override
  List<Object?> get props => [];
}

class ClearModeInitial extends ClearModeState {
  const ClearModeInitial();
}

class ClearModeLoadingState extends ClearModeState {
  const ClearModeLoadingState();
}

class ClearModeSuccessState extends ClearModeState {
  final CloseEffectModel data;
  const ClearModeSuccessState({required this.data});
  @override
  List<Object?> get props => [data];
}

class ClearModeErrorState extends ClearModeState {
  final String message;
  const ClearModeErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}
