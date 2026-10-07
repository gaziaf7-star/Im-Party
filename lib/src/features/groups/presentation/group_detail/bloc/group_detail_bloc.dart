import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/usecases/group_usecases.dart';

part 'group_detail_event.dart';
part 'group_detail_state.dart';

/// Owns a single group's detail/settings: load it, edit metadata, delete it,
/// leave it, and transfer ownership. The list screen listens to [lastAction]
/// transitions to keep itself in sync (upsert/remove) without a full refetch.
class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final FetchGroupDetailUC _fetchDetail;
  final UpdateGroupUC _updateGroup;
  final DeleteGroupUC _deleteGroup;
  final LeaveGroupUC _leaveGroup;
  final TransferGroupOwnershipUC _transferOwnership;

  GroupDetailBloc(
    this._fetchDetail,
    this._updateGroup,
    this._deleteGroup,
    this._leaveGroup,
    this._transferOwnership,
  ) : super(const GroupDetailState()) {
    on<LoadGroupDetailEvent>(_onLoad);
    on<UpdateGroupEvent>(_onUpdate);
    on<DeleteGroupEvent>(_onDelete);
    on<LeaveGroupEvent>(_onLeave);
    on<TransferOwnershipEvent>(_onTransfer);
  }

  Future<void> _onLoad(
      LoadGroupDetailEvent event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await _fetchDetail(event.groupId);
    result.fold(
      (left) => emit(state.copyWith(
        reqState: handleErrorResponse(left),
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        group: right.data,
        reqState: right.data == null
            ? RequestState.empty
            : RequestState.loaded,
      )),
    );
  }

  Future<void> _onUpdate(
      UpdateGroupEvent event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(actionState: RequestState.loading, lastAction: GroupAction.none));
    final result = await _updateGroup(event.params);
    result.fold(
      (left) => emit(state.copyWith(
        actionState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        group: right.data ?? state.group,
        actionState: RequestState.loaded,
        message: right.message,
        lastAction: GroupAction.updated,
      )),
    );
  }

  Future<void> _onDelete(
      DeleteGroupEvent event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(actionState: RequestState.loading, lastAction: GroupAction.none));
    final result = await _deleteGroup(event.groupId);
    result.fold(
      (left) => emit(state.copyWith(
        actionState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        actionState: RequestState.loaded,
        message: right.message,
        lastAction: GroupAction.deleted,
      )),
    );
  }

  Future<void> _onLeave(
      LeaveGroupEvent event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(actionState: RequestState.loading, lastAction: GroupAction.none));
    final result = await _leaveGroup(event.groupId);
    result.fold(
      (left) => emit(state.copyWith(
        actionState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        actionState: RequestState.loaded,
        message: right.message,
        lastAction: GroupAction.left,
      )),
    );
  }

  Future<void> _onTransfer(
      TransferOwnershipEvent event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(actionState: RequestState.loading, lastAction: GroupAction.none));
    final result = await _transferOwnership(event.params);
    result.fold(
      (left) => emit(state.copyWith(
        actionState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        actionState: RequestState.loaded,
        message: right.message,
        lastAction: GroupAction.ownershipTransferred,
      )),
    );
  }
}
