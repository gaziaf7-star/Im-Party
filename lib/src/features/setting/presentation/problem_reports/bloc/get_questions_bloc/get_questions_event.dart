part of 'get_questions_bloc.dart';

sealed class GetQuestionsEvent extends Equatable {
  const GetQuestionsEvent();

  @override
  List<Object?> get props => [];
}

class GetQuestionsDetailsEvent extends GetQuestionsEvent {
  final BuildContext context;

  const GetQuestionsDetailsEvent({required this.context});

  @override
  List<Object?> get props => [];
}


