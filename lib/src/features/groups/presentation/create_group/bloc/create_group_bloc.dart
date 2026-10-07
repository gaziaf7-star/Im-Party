import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/usecases/group_usecases.dart';

part 'create_group_event.dart';
part 'create_group_state.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final CreateGroupUC _createGroup;

  CreateGroupBloc(this._createGroup) : super(const CreateGroupState()) {
    on<SubmitCreateGroupEvent>(_onSubmit);
    on<ResetCreateGroupEvent>(_onReset);
  }

  Future<void> _onSubmit(
      SubmitCreateGroupEvent event, Emitter<CreateGroupState> emit) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await _createGroup(event.params);
    result.fold(
      (left) => emit(state.copyWith(
        reqState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        reqState: RequestState.loaded,
        createdGroup: right.data,
        message: right.message,
      )),
    );
  }

  void _onReset(ResetCreateGroupEvent event, Emitter<CreateGroupState> emit) {
    emit(const CreateGroupState());
  }
}
