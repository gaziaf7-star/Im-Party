import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/usecases/group_usecases.dart';

part 'groups_list_event.dart';
part 'groups_list_state.dart';

class GroupsListBloc extends Bloc<GroupsListEvent, GroupsListState> {
  final FetchGroupsUC _fetchGroups;
  final RealtimeClient _realtimeClient;

  StreamSubscription<RealtimeNonChatEvent>? _realtimeSub;

  GroupsListBloc(this._fetchGroups, this._realtimeClient)
      : super(const GroupsListState()) {
    on<FetchGroupsEvent>(_onFetch);
    on<RefreshGroupsEvent>(_onRefresh);
    on<LoadMoreGroupsEvent>(_onLoadMore);
    on<UpsertGroupLocallyEvent>(_onUpsertLocally);
    on<RemoveGroupLocallyEvent>(_onRemoveLocally);
    on<ApplyGroupMetaUpdateEvent>(_onApplyMetaUpdate);

    // Live group-metadata updates (rename / new photo / settings) fanned out to
    // every member: merge them onto the in-memory tab in-place so the list
    // refreshes without a cold start. Mirrors get_my_data_bloc's nonChatEvents
    // subscription pattern.
    _realtimeSub = _realtimeClient.nonChatEvents.listen((event) {
      if (event.event == 'group_updated' && event.payload is Map) {
        add(ApplyGroupMetaUpdateEvent(
          Map<String, dynamic>.from(event.payload as Map),
        ));
      }
    });
  }

  Future<void> _onFetch(
      FetchGroupsEvent event, Emitter<GroupsListState> emit) async {
    if (event.isLoading) {
      emit(state.copyWith(reqState: RequestState.loading, currentPage: 1));
    }
    await _load(emit, page: 1, replace: true);
  }

  Future<void> _onRefresh(
      RefreshGroupsEvent event, Emitter<GroupsListState> emit) async {
    await _load(emit, page: 1, replace: true);
  }

  Future<void> _onLoadMore(
      LoadMoreGroupsEvent event, Emitter<GroupsListState> emit) async {
    if (state.currentPage >= state.lastPage || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _load(emit, page: state.currentPage + 1, replace: false);
    emit(state.copyWith(isLoadingMore: false));
  }

  Future<void> _load(
    Emitter<GroupsListState> emit, {
    required int page,
    required bool replace,
  }) async {
    final result = await _fetchGroups(page);
    result.fold(
      (left) => emit(state.copyWith(
        error: left,
        reqState: handleErrorResponse(left),
      )),
      (right) {
        final fetched = right.data ?? const <GroupEntity>[];
        final merged = handlePaginationResponse<GroupEntity>(
          result: fetched,
          currentList: state.groups,
          currentPage: replace ? 1 : page,
        );
        emit(state.copyWith(
          groups: merged,
          currentPage: page,
          lastPage: right.paginates?.lastPage ?? state.lastPage,
          reqState: handleLoadedResponse<List<GroupEntity>>(merged),
        ));
      },
    );
  }

  void _onUpsertLocally(
      UpsertGroupLocallyEvent event, Emitter<GroupsListState> emit) {
    final list = List<GroupEntity>.from(state.groups);
    final index = list.indexWhere((g) => g.id == event.group.id);
    if (index != -1) {
      list[index] = event.group;
    } else {
      list.insert(0, event.group);
    }
    emit(state.copyWith(groups: list, reqState: RequestState.loaded));
  }

  void _onRemoveLocally(
      RemoveGroupLocallyEvent event, Emitter<GroupsListState> emit) {
    final list = List<GroupEntity>.from(state.groups)
      ..removeWhere((g) => g.id == event.groupId);
    emit(state.copyWith(
      groups: list,
      reqState: list.isEmpty ? RequestState.empty : RequestState.loaded,
    ));
  }

  void _onApplyMetaUpdate(
      ApplyGroupMetaUpdateEvent event, Emitter<GroupsListState> emit) {
    final id = _asInt(event.payload['id']);
    if (id == null) return;
    final list = List<GroupEntity>.from(state.groups);
    final index = list.indexWhere((g) => g.id == id);
    if (index == -1) return; // not in the tab → nothing to refresh in-place

    final current = list[index];
    final p = event.payload;
    list[index] = current.copyWith(
      name: p['name']?.toString(),
      avatar: (p['avatar'] ?? p['image'])?.toString(),
      privacy: p['privacy'] != null
          ? GroupPrivacy.fromString(p['privacy'].toString())
          : null,
      joinPolicy: p['join_policy'] != null
          ? GroupJoinPolicy.fromString(p['join_policy'].toString())
          : null,
      onlyAdminsPost: p['only_admins_post'] is bool
          ? p['only_admins_post'] as bool
          : (p['only_admins_post'] != null
              ? (p['only_admins_post'].toString() == 'true' ||
                  p['only_admins_post'].toString() == '1')
              : null),
      membersCount: _asInt(p['members_count']),
      maxMembers: _asInt(p['max_members']),
    );
    emit(state.copyWith(groups: list, reqState: RequestState.loaded));
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
