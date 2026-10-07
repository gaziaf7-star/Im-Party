part of 'groups_list_bloc.dart';

abstract class GroupsListEvent extends Equatable {
  const GroupsListEvent();

  @override
  List<Object?> get props => [];
}

class FetchGroupsEvent extends GroupsListEvent {
  final bool isLoading;
  const FetchGroupsEvent({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

class RefreshGroupsEvent extends GroupsListEvent {
  const RefreshGroupsEvent();
}

class LoadMoreGroupsEvent extends GroupsListEvent {
  const LoadMoreGroupsEvent();
}

class UpsertGroupLocallyEvent extends GroupsListEvent {
  final GroupEntity group;
  const UpsertGroupLocallyEvent(this.group);

  @override
  List<Object?> get props => [group];
}

class RemoveGroupLocallyEvent extends GroupsListEvent {
  final int groupId;
  const RemoveGroupLocallyEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Internal: a `group_updated` realtime signal arrived. Merges the non-sensitive
/// metadata (name/avatar/privacy/join_policy/only_admins_post/members_count) onto
/// the matching in-memory group IN-PLACE — keeping role/unread/invite_token — so
/// the groups tab refreshes live for every member without a cold start. A no-op
/// when the group isn't currently loaded in the tab.
class ApplyGroupMetaUpdateEvent extends GroupsListEvent {
  final Map<String, dynamic> payload;
  const ApplyGroupMetaUpdateEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}
