import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/feed_back/feed_back_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/feed_back/feed_back_state.dart';


class FeedbackBloc extends Bloc<BaseFeedBackEvent, FeedBackState> {
  FeedbackBloc()
      : super(
      FeedBackState(
      selectedProblem: StringManager.functionalProblem.tr(),
      problemTypes: [
        StringManager.functionalProblem.tr(),
        StringManager.suggestion.tr(),
        StringManager.recharge.tr(),
        StringManager.other.tr(),
      ],
    ),
  ) {
    on<SelectProblemTypeEvent>((event, emit) {
        emit(state.copyWith(selectedProblem: event.problemType));
      },
    );
  }


}
