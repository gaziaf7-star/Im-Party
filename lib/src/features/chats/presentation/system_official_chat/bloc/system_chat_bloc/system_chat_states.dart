part of 'system_chat_bloc.dart';
class GetSystemChatsStates extends Equatable {
  final RequestState systemReqState;
  final List<SystemAndOfficialMessagesEntity> systemEntity;
  final bool hasReachedMaxSystem;
  final int systemPage;

  final RequestState officialReqState;
  final List<SystemAndOfficialMessagesEntity> officialEntity;
  final bool hasReachedMaxOfficial;
  final int officialPage;

  const GetSystemChatsStates({
    this.systemReqState = RequestState.idle,
    this.systemEntity = const [],
    this.hasReachedMaxSystem = false,
    this.systemPage = 1,
    this.officialReqState = RequestState.idle,
    this.officialEntity = const [],
    this.hasReachedMaxOfficial = false,
    this.officialPage = 1,
  });

  GetSystemChatsStates copyWith({
    RequestState? systemReqState,
    List<SystemAndOfficialMessagesEntity>? systemEntity,
    bool? hasReachedMaxSystem,
    int? systemPage,

    RequestState? officialReqState,
    List<SystemAndOfficialMessagesEntity>? officialEntity,
    bool? hasReachedMaxOfficial,
    int? officialPage,
  }) {
    return GetSystemChatsStates(
      systemReqState: systemReqState ?? this.systemReqState,
      systemEntity: systemEntity ?? this.systemEntity,
      hasReachedMaxSystem: hasReachedMaxSystem ?? this.hasReachedMaxSystem,
      systemPage: systemPage ?? this.systemPage,
      officialReqState: officialReqState ?? this.officialReqState,
      officialEntity: officialEntity ?? this.officialEntity,
      hasReachedMaxOfficial: hasReachedMaxOfficial ?? this.hasReachedMaxOfficial,
      officialPage: officialPage ?? this.officialPage,
    );
  }

  @override
  List<Object?> get props => [
    systemReqState,
    systemEntity,
    hasReachedMaxSystem,
    systemPage,
    officialReqState,
    officialEntity,
    hasReachedMaxOfficial,
    officialPage,
  ];
}

// class GetSystemChatsStates extends Equatable {
//   final RequestState systemReqState;
//   final RequestState officialReqState;
//   final List<SystemAndOfficialMessagesModel>? systemEntity;
//   final List<SystemAndOfficialMessagesModel>? officialEntity;
//
//   const GetSystemChatsStates({
//     this.systemReqState = RequestState.idle,
//     this.officialReqState = RequestState.idle,
//     this.systemEntity,
//     this.officialEntity,
//   });
//
//   GetSystemChatsStates copyWith({
//     RequestState? systemReqState,
//     RequestState? officialReqState,
//     List<SystemAndOfficialMessagesModel>? systemEntity,
//     List<SystemAndOfficialMessagesModel>? officialEntity,
//   }) {
//     return GetSystemChatsStates(
//       systemReqState: systemReqState ?? this.systemReqState,
//       officialReqState: officialReqState ?? this.officialReqState,
//       systemEntity: systemEntity ?? this.systemEntity,
//       officialEntity: officialEntity ?? this.officialEntity,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     systemEntity,
//     officialEntity,
//     officialReqState,
//     systemReqState,
//   ];
// }
