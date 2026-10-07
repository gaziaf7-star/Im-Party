
part of'make_react_bloc.dart';

abstract class BaseMakeReactEvent  extends Equatable {
  const BaseMakeReactEvent();
}

class MakeReactEvent extends BaseMakeReactEvent {
  final MakeReactParamsUC params;

  const MakeReactEvent({required this.params});

  @override
  List<Object?> get props => [params];
}


