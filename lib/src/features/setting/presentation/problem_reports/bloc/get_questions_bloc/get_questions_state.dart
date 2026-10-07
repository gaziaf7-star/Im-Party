import 'package:general/src/core/index.dart';

import '../../../../domain/entities/support_questions_entity.dart';

class GetQuestionsState extends Equatable {
 final RequestState reqState;
 final String? message;
 final List<SupportQuestionsEntity> data;

 const GetQuestionsState({
  this.reqState = RequestState.idle,
  this.message,
  this.data = const [],
 });

 GetQuestionsState copyWith({
  RequestState? reqState,
  String? message,
  List<SupportQuestionsEntity>? data,
 }) {
  return GetQuestionsState(
   reqState: reqState ?? this.reqState,
   message: message ?? this.message,
   data: data ?? this.data,

  );
 }

 @override
 List<Object?> get props => [
  reqState,
  message,
  data,
 ];
}
