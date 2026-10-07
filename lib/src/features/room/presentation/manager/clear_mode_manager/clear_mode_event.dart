
import 'package:equatable/equatable.dart';

abstract class BaseClearModeEvent extends Equatable {
  const BaseClearModeEvent();
  @override
  List<Object?> get props => [];
}


class ClearModeEvent extends BaseClearModeEvent{
  final String key ;
  const ClearModeEvent({required this.key});
  @override
  List<Object?> get props => [key];
}