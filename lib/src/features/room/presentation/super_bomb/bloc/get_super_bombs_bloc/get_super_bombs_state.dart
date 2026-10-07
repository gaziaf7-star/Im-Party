part of 'get_super_bombs_bloc.dart';

class GetSuperBombsState extends Equatable {
  final SuperBombModel? data;
  final String message;
  final RequestState state;
  final int selectedIndex;

  final SuberBoomVideoseModel? videosData;
  final String videoMessage;
  final RequestState videoState;

  final BombRulesResponse? rulesData;
  final String rulesMessage;
  final RequestState rulesState;

  const GetSuperBombsState({
    this.data,
    this.message = '',
    this.state = RequestState.idle,
    this.selectedIndex = 0,
    this.videosData,
    this.videoMessage = '',
    this.videoState = RequestState.idle,
    this.rulesData,
    this.rulesMessage = '',
    this.rulesState = RequestState.idle,
  });

  GetSuperBombsState copyWith({
    SuperBombModel? data,
    String? message,
    RequestState? state,
    int? selectedIndex,
    SuberBoomVideoseModel? videosData,
    String? videoMessage,
    RequestState? videoState,
    BombRulesResponse? rulesData,
    String? rulesMessage,
    RequestState? rulesState,
  }) {
    return GetSuperBombsState(
      data: data ?? this.data,
      message: message ?? this.message,
      state: state ?? this.state,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      videosData: videosData ?? this.videosData,
      videoMessage: videoMessage ?? this.videoMessage,
      videoState: videoState ?? this.videoState,
      rulesData: rulesData ?? this.rulesData,
      rulesMessage: rulesMessage ?? this.rulesMessage,
      rulesState: rulesState ?? this.rulesState,
    );
  }

  @override
  List<Object?> get props => [
        data,
        message,
        state,
        selectedIndex,
        videosData,
        videoMessage,
        videoState,
        rulesData,
        rulesMessage,
        rulesState,
      ];
}
