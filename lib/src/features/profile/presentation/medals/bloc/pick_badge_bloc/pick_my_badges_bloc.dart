
import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_use_case/pick_my_badges_uc.dart';
import 'pick_my_badges_event.dart';
import 'pick_my_badges_state.dart';

class PickMyBadgesBloc
    extends Bloc<BasePickMyBadgesEvent, BasePickMyBadgesState> {
  final PickMyBadgesUC pickMyBadgesUC;
  PickMyBadgesBloc({required this.pickMyBadgesUC})
      : super(const PickMyBadgesInitial()) {
    on<PickMyBadgesEvent>(
      (event, emit) async {
        emit(const PickMyBadgesLoadingState());
        final result = await pickMyBadgesUC.call(event.ids);
        result.fold(
          (left) => emit(
            PickMyBadgesErrorState(
              error: NetworkExceptions.getErrorMessage(left),
            ),
          ),
          (right) => emit(PickMyBadgesSucssesState(message: right)),
        );
      },
    );
  }
}
