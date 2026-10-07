import 'package:general/src/core/index.dart';

abstract class BaseAddOrDeleteBlockListEvent extends Equatable {
  const BaseAddOrDeleteBlockListEvent();

  @override
  List<Object?> get props => const [];
}

class DeleteBlockListEvent extends BaseAddOrDeleteBlockListEvent {
  final String userId;
  final BuildContext context;

  const DeleteBlockListEvent(this.context, {required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddBlockListEvent extends BaseAddOrDeleteBlockListEvent {
  final String userId;
  final BuildContext context;
  const AddBlockListEvent(this.context, {required this.userId});

  @override
  List<Object?> get props => [userId];
}
