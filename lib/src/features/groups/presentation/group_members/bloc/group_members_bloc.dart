import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/usecases/group_usecases.dart';

part 'group_members_event.dart';
part 'group_members_state.dart';

class GroupMembersBloc extends Bloc<GroupMembersEvent, GroupMembersState> {
  final FetchGroupMembersUC _fetchMembers;
  final PromoteGroupMemberUC _promote;
  final DemoteGroupMemberUC _demote;
  final KickGroupMemberUC _kick;
  final MuteGroupMemberUC _mute;
  final AddGroupMembersUC _addMembers;

  GroupMembersBloc(
    this._fetchMembers,
    this._promote,
    this._demote,
    this._kick,
    this._mute,
    this._addMembers,
  ) : super(const GroupMembersState()) {
    on<FetchMembersEvent>(_onFetch);
    on<LoadMoreMembersEvent>(_onLoadMore);
    on<PromoteMemberEvent>(_onPromote);
    on<DemoteMemberEvent>(_onDemote);
    on<KickMemberEvent>(_onKick);
    on<MuteMemberEvent>(_onMute);
    on<AddMembersEvent>(_onAdd);
  }

  Future<void> _onFetch(
      FetchMembersEvent event, Emitter<GroupMembersState> emit) async {
    emit(state.copyWith(
        reqState: RequestState.loading, currentPage: 1, groupGone: false));
    final result = await _fetchMembers(GroupMembersParams(groupId: event.groupId, page: 1));
    result.fold(
      (left) {
        // A 404 means the group was deleted server-side. Flag it distinctly (not
        // a generic error, and not RequestState.empty which is a live group with
        // no members) so the screen can pop + purge the stale drift room.
        if (left is NotFound) {
          emit(state.copyWith(
            reqState: RequestState.empty,
            groupGone: true,
            message: NetworkExceptions.getErrorMessage(left),
          ));
          return;
        }
        emit(state.copyWith(
          reqState: handleErrorResponse(left),
          message: NetworkExceptions.getErrorMessage(left),
        ));
      },
      (right) {
        final members = right.data ?? const <GroupMemberEntity>[];
        emit(state.copyWith(
          members: members,
          currentPage: 1,
          lastPage: right.paginates?.lastPage ?? 1,
          reqState: handleLoadedResponse<List<GroupMemberEntity>>(members),
        ));
      },
    );
  }

  Future<void> _onLoadMore(
      LoadMoreMembersEvent event, Emitter<GroupMembersState> emit) async {
    if (state.currentPage >= state.lastPage || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;
    final result = await _fetchMembers(
        GroupMembersParams(groupId: event.groupId, page: nextPage));
    result.fold(
      (left) => emit(state.copyWith(
        isLoadingMore: false,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) {
        final merged = handlePaginationResponse<GroupMemberEntity>(
          result: right.data,
          currentList: state.members,
          currentPage: nextPage,
        );
        emit(state.copyWith(
          members: merged,
          currentPage: nextPage,
          lastPage: right.paginates?.lastPage ?? state.lastPage,
          isLoadingMore: false,
          reqState: RequestState.loaded,
        ));
      },
    );
  }

  Future<void> _onPromote(
      PromoteMemberEvent event, Emitter<GroupMembersState> emit) async {
    await _roleAction(
      emit,
      userId: event.userId,
      optimistic: (m) => m.copyWith(role: GroupRole.admin),
      call: () => _promote(
          GroupMemberActionParams(groupId: event.groupId, userId: event.userId)),
    );
  }

  Future<void> _onDemote(
      DemoteMemberEvent event, Emitter<GroupMembersState> emit) async {
    await _roleAction(
      emit,
      userId: event.userId,
      optimistic: (m) => m.copyWith(role: GroupRole.member),
      call: () => _demote(
          GroupMemberActionParams(groupId: event.groupId, userId: event.userId)),
    );
  }

  Future<void> _onMute(
      MuteMemberEvent event, Emitter<GroupMembersState> emit) async {
    final mutedUntil = event.durationMinutes != null && event.durationMinutes! > 0
        ? DateTime.now().add(Duration(minutes: event.durationMinutes!))
        : null;
    await _roleAction(
      emit,
      userId: event.userId,
      optimistic: (m) => m.copyWith(
        status: GroupMemberStatus.muted,
        mutedUntil: mutedUntil,
      ),
      call: () => _mute(MuteGroupMemberParams(
        groupId: event.groupId,
        userId: event.userId,
        durationMinutes: event.durationMinutes,
      )),
    );
  }

  Future<void> _onKick(
      KickMemberEvent event, Emitter<GroupMembersState> emit) async {
    final before = List<GroupMemberEntity>.from(state.members);
    final after = before..removeWhere((m) => m.userId == event.userId);
    emit(state.copyWith(members: after, actionState: RequestState.loading));

    final result = await _kick(
        GroupMemberActionParams(groupId: event.groupId, userId: event.userId));
    result.fold(
      (left) => emit(state.copyWith(
        members: before,
        actionState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        actionState: RequestState.loaded,
        message: right.message,
      )),
    );
  }

  Future<void> _onAdd(
      AddMembersEvent event, Emitter<GroupMembersState> emit) async {
    emit(state.copyWith(actionState: RequestState.loading));
    final result = await _addMembers(AddGroupMembersParams(
        groupId: event.groupId, userIds: event.userIds));
    result.fold(
      (left) => emit(state.copyWith(
        actionState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) {
        emit(state.copyWith(
          actionState: RequestState.loaded,
          message: right.message,
        ));
        add(FetchMembersEvent(event.groupId));
      },
    );
  }

  Future<void> _roleAction(
    Emitter<GroupMembersState> emit, {
    required int userId,
    required GroupMemberEntity Function(GroupMemberEntity) optimistic,
    required Future<Either<NetworkExceptions, BaseResponse<void>>> Function() call,
  }) async {
    final before = List<GroupMemberEntity>.from(state.members);
    final after = before.map((m) => m.userId == userId ? optimistic(m) : m).toList();
    emit(state.copyWith(members: after, actionState: RequestState.loading));

    final result = await call();
    result.fold(
      (left) => emit(state.copyWith(
        members: before,
        actionState: RequestState.error,
        message: NetworkExceptions.getErrorMessage(left),
      )),
      (right) => emit(state.copyWith(
        actionState: RequestState.loaded,
        message: right.message,
      )),
    );
  }
}
