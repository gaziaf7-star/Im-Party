part of 'mall_bloc.dart';

class GetDataMallStates extends Equatable {
  final List<MallEntity> carsMall;
  final RequestState carMallRequest;
  final String carMallMessage;
  final MallEntity? selectedItem;

  final List<MallEntity> framesMall;
  final RequestState frameMallRequest;
  final String frameMallMessage;

  final List<MallEntity> bubblesMall;
  final RequestState bubbleMallRequest;
  final String bubbleMallMessage;

  final List<MallEntity> emojisMall;
  final RequestState emojisMallRequest;
  final String emojisMallMessage;

  final List<MallEntity> profileFramesMall;
  final RequestState profileFramesMallRequest;
  final String? profileFramesMallMessage;

  final int tabBarIndex;

  const GetDataMallStates({
    this.selectedItem,
    this.carsMall = const [],
    this.carMallRequest = RequestState.loading,
    this.carMallMessage = "",
    this.framesMall = const [],
    this.frameMallRequest = RequestState.loading,
    this.frameMallMessage = "",
    this.bubblesMall = const [],
    this.bubbleMallRequest = RequestState.loading,
    this.bubbleMallMessage = "",
    this.emojisMall = const [],
    this.emojisMallRequest = RequestState.loading,
    this.emojisMallMessage = "",
    this.profileFramesMall = const [],
    this.profileFramesMallRequest = RequestState.loading,
    this.profileFramesMallMessage = "",
    this.tabBarIndex = 0,
  });

  GetDataMallStates copyWith({
    List<MallEntity>? carsMall,
    MallEntity? selectedItem,
    RequestState? carMallRequest,
    String? carMallMessage,
    List<MallEntity>? framesMall,
    RequestState? frameMallRequest,
    String? frameMallMessage,
    List<MallEntity>? bubblesMall,
    RequestState? bubbleMallRequest,
    String? bubbleMallMessage,
    List<MallEntity>? emojisMall,
    RequestState? emojisMallRequest,
    String? emojisMallMessage,
    List<MallEntity>? profileFramesMall,
    RequestState? profileFramesMallRequest,
    String? profileFramesMallMessage,
    int? tabBarIndex,
  }) {
    return GetDataMallStates(
      selectedItem: selectedItem ?? this.selectedItem,
      carsMall: carsMall ?? this.carsMall,
      carMallRequest: carMallRequest ?? this.carMallRequest,
      carMallMessage: carMallMessage ?? this.carMallMessage,
      framesMall: framesMall ?? this.framesMall,
      frameMallRequest: frameMallRequest ?? this.frameMallRequest,
      frameMallMessage: frameMallMessage ?? this.frameMallMessage,
      bubblesMall: bubblesMall ?? this.bubblesMall,
      bubbleMallRequest: bubbleMallRequest ?? this.bubbleMallRequest,
      bubbleMallMessage: bubbleMallMessage ?? this.bubbleMallMessage,
      emojisMall: emojisMall ?? this.emojisMall,
      emojisMallRequest: emojisMallRequest ?? this.emojisMallRequest,
      emojisMallMessage: emojisMallMessage ?? this.emojisMallMessage,
      profileFramesMall: profileFramesMall ?? this.profileFramesMall,
      profileFramesMallRequest:
          profileFramesMallRequest ?? this.profileFramesMallRequest,
      profileFramesMallMessage:
          profileFramesMallMessage ?? this.profileFramesMallMessage,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,
    );
  }

  @override
  List<Object?> get props => [
        carsMall,
        carMallMessage,
        carMallRequest,
        frameMallMessage,
        frameMallRequest,
        framesMall,
        bubblesMall,
        bubbleMallRequest,
        bubbleMallMessage,
        emojisMall,
        emojisMallRequest,
        emojisMallMessage,
        profileFramesMall,
        profileFramesMallRequest,
        profileFramesMallMessage,
        tabBarIndex,
        selectedItem,
      ];
}
