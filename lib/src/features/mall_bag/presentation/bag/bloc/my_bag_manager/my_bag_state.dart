part of'my_bag_bloc.dart';

class MyBagState extends Equatable {
  final List<MyBagEntity> carsBag;
  final RequestState carBagRequest;
  final String carBagMessage;
  final MyBagEntity? selectedItemBubble;
  final MyBagEntity? selectedItemFrame;
  final MyBagEntity? selectedItemIntro;
  final MyBagEntity? selectedItemSpecialId;
  final MyBagEntity? selectedItem;
  final MyBagEntity? selectedItemProfileFrame;

  final List<MyBagEntity> vipBag;
  final RequestState vipBagRequest;
  final String vipBagMessage;

  final List<MyBagEntity> framesBag;
  final RequestState frameBagRequest;
  final String frameBagMessage;

  final List<MyBagEntity> bubblesBag;
  final RequestState bubbleBagRequest;
  final String bubbleBagMessage;

  final List<MyBagEntity> emojisBag;
  final RequestState emojisBagRequest;
  final String emojisBagMessage;

  final RequestState profileFrameRequest;
  final String profileFrameMessage;
  final List<MyBagEntity> profileFrames;

  final int tabBarIndex;
  final bool? isFrameNull;
  final bool? isBubbleNull;
  final bool? isIntroNull;
  final bool? isSpecialIdNull;
  final bool? isProfileFrameNull;
  const MyBagState({
    this.selectedItemBubble,
    this.selectedItemFrame,
    this.selectedItemIntro,
    this.selectedItemSpecialId,
    this.selectedItemProfileFrame,
    this.selectedItem,
    this.isFrameNull,
    this.isBubbleNull,
    this.isIntroNull,
    this.isSpecialIdNull,
    this.isProfileFrameNull,
    this.vipBag = const [],
    this.vipBagRequest = RequestState.loading,
    this.vipBagMessage = "",
    this.carsBag = const [],
    this.carBagRequest = RequestState.loading,
    this.carBagMessage = "",
    this.framesBag = const [],
    this.frameBagRequest = RequestState.loading,
    this.frameBagMessage = "",
    this.bubblesBag = const [],
    this.bubbleBagRequest = RequestState.loading,
    this.bubbleBagMessage = "",
    this.emojisBag = const [],
    this.emojisBagRequest = RequestState.loading,
    this.emojisBagMessage = "",
    this.profileFrameRequest = RequestState.loading,
    this.profileFrameMessage = '',
    this.profileFrames = const [],
    this.tabBarIndex = 0,

  });

  MyBagState copyWith({
    List<MyBagEntity>? vipBag,
    RequestState? vipBagRequest,
    String? vipBagMessage,
    List<MyBagEntity>? carsBag,
    RequestState? carBagRequest,
    String? carBagMessage,
    List<MyBagEntity>? framesBag,
    RequestState? frameBagRequest,
    String? frameBagMessage,
    List<MyBagEntity>? bubblesBag,
    RequestState? bubbleBagRequest,
    String? bubbleBagMessage,
    List<MyBagEntity>? emojisBag,
    RequestState? emojisBagRequest,
    String? emojisBagMessage,
    RequestState? profileFrameRequest,
    String? profileFrameMessage,
    List<MyBagEntity>? profileFrames,
    int? tabBarIndex,
    MyBagEntity? selectedItemBubble,
    MyBagEntity? selectedItemFrame,
    MyBagEntity? selectedItemIntro,
    MyBagEntity? selectedItemSpecialId,
    MyBagEntity? selectedItem,
    MyBagEntity? selectedItemProfileFrame,
    bool ? isFrameNull,
    bool ? isBubbleNull,
    bool ? isIntroNull,
    bool ? isSpecialIdNull,
    bool ? isProfileFrameNull,

  }) {
    return MyBagState(
      selectedItemBubble: selectedItemBubble ?? this.selectedItemBubble,
      selectedItemProfileFrame: selectedItemProfileFrame ?? this.selectedItemProfileFrame,
      selectedItemFrame: selectedItemFrame ?? this.selectedItemFrame,
      selectedItemIntro: selectedItemIntro ?? this.selectedItemIntro,
      selectedItemSpecialId: selectedItemSpecialId ?? this.selectedItemSpecialId,
      selectedItem: selectedItem ?? this.selectedItem,
      isFrameNull: isFrameNull ?? this.isFrameNull,
      isBubbleNull: isBubbleNull ?? this.isBubbleNull,
      isIntroNull: isIntroNull ?? this.isIntroNull,
      isSpecialIdNull: isSpecialIdNull ?? this.isSpecialIdNull,
      isProfileFrameNull: isProfileFrameNull ?? this.isProfileFrameNull,
      vipBag: vipBag ?? this.vipBag,
      vipBagRequest: vipBagRequest ?? this.vipBagRequest,
      vipBagMessage: vipBagMessage ?? this.vipBagMessage,
      carsBag: carsBag ?? this.carsBag,
      carBagRequest: carBagRequest ?? this.carBagRequest,
      carBagMessage: carBagMessage ?? this.carBagMessage,
      framesBag: framesBag ?? this.framesBag,
      frameBagRequest: frameBagRequest ?? this.frameBagRequest,
      frameBagMessage: frameBagMessage ?? this.frameBagMessage,
      bubblesBag: bubblesBag ?? this.bubblesBag,
      bubbleBagRequest: bubbleBagRequest ?? this.bubbleBagRequest,
      bubbleBagMessage: bubbleBagMessage ?? this.bubbleBagMessage,
      emojisBag: emojisBag ?? this.emojisBag,
      emojisBagRequest: emojisBagRequest ?? this.emojisBagRequest,
      emojisBagMessage: emojisBagMessage ?? this.emojisBagMessage,
      profileFrameRequest: profileFrameRequest ?? this.profileFrameRequest,
      profileFrameMessage: profileFrameMessage ?? this.profileFrameMessage,
      profileFrames: profileFrames ?? this.profileFrames,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,

    );
  }

  @override
  List<Object?> get props => [
    vipBag,
    vipBagMessage,
    vipBagRequest,
    carsBag,
    carBagMessage,
    carBagRequest,
    frameBagMessage,
    frameBagRequest,
    framesBag,
    bubblesBag,
    bubbleBagRequest,
    bubbleBagMessage,
    emojisBag,
    emojisBagRequest,
    emojisBagMessage,
    tabBarIndex,
    selectedItemBubble,
    selectedItemFrame,
    selectedItemIntro,
    selectedItemSpecialId,
    selectedItemProfileFrame,
    profileFrameRequest,
    profileFrameMessage,
    profileFrames,
    selectedItem,
    isFrameNull,
    isBubbleNull,
    isIntroNull,
    isSpecialIdNull,isProfileFrameNull
  ];
}
