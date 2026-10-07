part of 'agnecy_member_bloc.dart';

abstract class BaseAgnecyMemberEvent extends Equatable {
  const BaseAgnecyMemberEvent();
  @override
  List<Object?> get props => [];
}

class AgnecyMemberEvent extends BaseAgnecyMemberEvent {
  final String page;
  final bool isFirsLoading;
  const AgnecyMemberEvent({
    required this.page,
     this.isFirsLoading=false,
  });

  @override
  List<Object?> get props => [page];
}

class LoadMoreAgnecyMemberEvent extends BaseAgnecyMemberEvent {
  final String page;
  const LoadMoreAgnecyMemberEvent({required this.page});
  @override
  List<Object?> get props => [page];
}
