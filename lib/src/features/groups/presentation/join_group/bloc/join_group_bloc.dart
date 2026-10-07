import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/usecases/group_usecases.dart';

part 'join_group_event.dart';
part 'join_group_state.dart';

class JoinGroupBloc extends Bloc<JoinGroupEvent, JoinGroupState> {
  final JoinGroupUC _joinGroup;

  JoinGroupBloc(this._joinGroup) : super(const JoinGroupState()) {
    on<SubmitJoinGroupEvent>(_onSubmit);
    on<ResetJoinGroupEvent>(_onReset);
  }

  Future<void> _onSubmit(
      SubmitJoinGroupEvent event, Emitter<JoinGroupState> emit) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await _joinGroup(event.params);
    result.fold(
      (left) => emit(state.copyWith(
        reqState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        reqState: RequestState.loaded,
        joinedGroup: right.data,
        message: right.message,
      )),
    );
  }

  void _onReset(ResetJoinGroupEvent event, Emitter<JoinGroupState> emit) {
    emit(const JoinGroupState());
  }
}
