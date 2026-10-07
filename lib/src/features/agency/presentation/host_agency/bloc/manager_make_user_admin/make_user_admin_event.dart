part of 'make_user_admin_bloc.dart';

abstract class BaseMakeUserAdminEvent extends Equatable {
  const BaseMakeUserAdminEvent();

  @override
  List<Object?> get props => [];
}

class MakeUserAdminEvent extends BaseMakeUserAdminEvent {
  final int id;
  final String type;
  final bool isFirstLoading;
  const MakeUserAdminEvent({
    required this.id,
    required this.type,
     this.isFirstLoading=false,
  });

  @override
  List<Object?> get props => [id,isFirstLoading,type];
}
