part of'cp_relations_bloc.dart';

abstract class CpRelationsEvents extends Equatable {
  const CpRelationsEvents();

  @override
  List<Object> get props => [];
}

class GetCpRelationsEvents extends CpRelationsEvents {


}

class CpRelationRespondEvents extends CpRelationsEvents {

  final String cpId;
  final String messageId;
  final String status;

  const CpRelationRespondEvents({required this.cpId, required this.messageId, required this.status});


}
