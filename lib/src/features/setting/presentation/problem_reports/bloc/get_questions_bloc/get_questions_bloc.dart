import '../../../../../../core/index.dart';
import 'get_questions_state.dart';

part 'get_questions_event.dart';

class GetQuestionsBloc extends Bloc<GetQuestionsEvent, GetQuestionsState> {
  GetQuestionsBloc(super.initialState);
  // final SupportQuestionsUs supportQuestionsUs;

  // GetQuestionsBloc({required this.supportQuestionsUs}) : super(const GetQuestionsState()) {
  //   on<GetQuestionsDetailsEvent>((event, emit) async {
  //     final result = await supportQuestionsUs();
  //     result.fold(
  //           (l) => emit(
  //               state.copyWith(
  //           reqState: RequestState.error,
  //           message: NetworkExceptions.getErrorMessage(l))),
  //           (r) {
  //         emit(state.copyWith(
  //           data: r.data,
  //           reqState:
  //           handleLoadedResponse<List<SupportQuestionsEntity>>(r.data),
  //         ),
  //         );
  //       },
  //     );    });

  // }
}
