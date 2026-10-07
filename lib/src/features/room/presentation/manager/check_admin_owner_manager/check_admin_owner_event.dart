part of 'check_admin_owner_bloc.dart';

abstract class BaseCheckAdminOwnerEvent extends Equatable {
  const BaseCheckAdminOwnerEvent();
}

class CheckAdminOwnerEvent extends BaseCheckAdminOwnerEvent {

  final CheckAdminOwnerParam params;
  final BuildContext context;
  final void Function()? callback;

  const CheckAdminOwnerEvent(
      { required this.params,required this.context, this.callback});

  @override
  List<Object?> get props => [params, context, callback];
}