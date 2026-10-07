part of 'delete_family_bloc.dart';

abstract class BaseDeleteFamilyEvent extends Equatable {
  const BaseDeleteFamilyEvent();

  @override
  List<Object> get props => [];
}

class DeleteFamilyEvent extends BaseDeleteFamilyEvent {
  final String id;
  const DeleteFamilyEvent({required this.id});
}
