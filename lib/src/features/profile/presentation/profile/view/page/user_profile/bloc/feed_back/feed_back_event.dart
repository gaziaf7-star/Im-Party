import 'package:equatable/equatable.dart';

abstract class BaseFeedBackEvent extends Equatable {
  const BaseFeedBackEvent();

  @override
  List<Object?> get props => const [];
}



class SelectProblemTypeEvent extends BaseFeedBackEvent {
  final String problemType;

  const SelectProblemTypeEvent({required this.problemType});
  @override
  List<Object?> get props => [problemType];
}


