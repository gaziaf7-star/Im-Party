import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class MomentStates extends Equatable {
  final List<MomentEntity> moments;
  final List<MomentEntity> followMoments;
  final List<MomentEntity> latestMoments;
  final RequestState reqState;
  final RequestState reqFollowState;
  final RequestState reqLatestState;
  //final TextEditingController createMomentController;

  final List<MomentEntity> myMoments;
  final RequestState myReqState;
  final String myMessage;

  final String message;
  final String followMessage;
  final String latestMessage;

  final bool isAddMoment;

  final RequestState reportMomentReqState;
  final String reportMomentMessage;

  final RequestState addMomentReqState;
  final String addMomentMessage;

  final File? image;

  final RequestState deleteMomentReqState;
  final String deleteMomentMessage;

  final RequestState likeMomentReqState;
  final String likeMomentMessage;
  final int currentPageMoment,
      lastPageMoment,
      lastPageMyMoment,
      currentPageMyMoment,
      currentPageFollowMoment,
      currentPageLatestMoment,
      lastPageFollowMoment,
      lastPageLatestMoment;
  final ScrollController scrollControllerMyMoment;
  final ScrollController scrollControllerMoment;
  final ScrollController scrollControllerFollowMoment;
  final ScrollController scrollControllerLatestMoment;
  final List<File> multiImages;
  final bool isFormValid;
  final bool showEmoji;
  final bool isPaginatingMoment;
  final bool isPaginatingFollowMoment;
  final bool isPaginatingLatestMoment;

  const MomentStates({
    this.moments = const [],
    this.myMoments = const [],
    this.myReqState = RequestState.loading,
    this.myMessage = '',
    this.followMoments = const [],
    this.followMessage = '',
    this.latestMoments = const [],
    this.latestMessage = '',
        this.isFormValid =false ,
        this.showEmoji =false ,
        this.isPaginatingMoment = false,
        this.isPaginatingFollowMoment = false,
        this.isPaginatingLatestMoment = false,

    this.reqFollowState = RequestState.loading,
    this.reqLatestState = RequestState.loading,
    this.reqState = RequestState.loading,
    this.message = '',
    this.addMomentReqState = RequestState.idle,
    this.reportMomentReqState = RequestState.idle,
    this.addMomentMessage = '',
    this.reportMomentMessage = '',
    this.image,
    this.deleteMomentReqState = RequestState.loading,
    this.deleteMomentMessage = '',
    this.likeMomentReqState = RequestState.loading,
    this.likeMomentMessage = '',
    this.lastPageMoment = -1,
    this.lastPageMyMoment = -1,
    this.currentPageMoment = 1,
    this.currentPageMyMoment = 1,
    this.multiImages = const [],
    this.lastPageFollowMoment = -1,
    this.currentPageFollowMoment = 1,
    this.lastPageLatestMoment = -1,
    this.currentPageLatestMoment = 1,
    required this.scrollControllerMyMoment,
    required this.scrollControllerMoment,
    required this.scrollControllerFollowMoment,
    required this.scrollControllerLatestMoment,
    //required this.createMomentController,
    this.isAddMoment = true,
  });

  MomentStates copyWith(
      {
        List<MomentEntity>? moments,
      RequestState? reqState,
      String? message,
      List<MomentEntity>? myMoments,
      RequestState? myReqState,
      String? myMessage,
      List<MomentEntity>? followMoments,
      String? followMessage,
      List<MomentEntity>? latestMoments,
      String? latestMessage,
      RequestState? reqFollowState,
      RequestState? reqLatestState,
      RequestState? addMomentReqState,
      RequestState? reportMomentReqState,
      String? addMomentMessage,
      String? reportMomentMessage,
      File? image,
      bool isImageNull = false,
      RequestState? deleteMomentReqState,
      String? deleteMomentMessage,
      RequestState? likeMomentReqState,
      String? likeMomentMessage,
      int? currentPageMyMoment,
      int? lastPageMyMoment,
      int? currentPageMoment,
      int? lastPageMoment,
      int? currentPageFollowMoment,
      int? lastPageFollowMoment,
      int? currentPageLatestMoment,
      int? lastPageLatestMoment,
      List<File>? multiImages,
      bool? isAddMoment,
      ScrollController? scrollControllerMyMoment,
      ScrollController? scrollControllerMoment,
      ScrollController? scrollControllerFollowMoment,
      ScrollController? scrollControllerLatestMoment,
      String? createMomentController,
     bool? isFormValid,
     bool? showEmoji,
     bool? isPaginatingMoment,
     bool? isPaginatingFollowMoment,
     bool? isPaginatingLatestMoment,
      }) {
    return MomentStates(
      moments: moments ?? this.moments,
      myMoments: myMoments ?? this.myMoments,
      myReqState: myReqState ?? this.myReqState,
      myMessage: myMessage ?? this.myMessage,
      followMessage: followMessage ?? this.followMessage,
      followMoments: followMoments ?? this.followMoments,
      latestMessage: latestMessage ?? this.latestMessage,
      latestMoments: latestMoments ?? this.latestMoments,
      reqFollowState: reqFollowState ?? this.reqFollowState,
      reqLatestState: reqLatestState ?? this.reqLatestState,
      isAddMoment: isAddMoment ?? this.isAddMoment,
      reqState: reqState ?? this.reqState,
      message: message ?? this.message,
      addMomentReqState: addMomentReqState ?? this.addMomentReqState,
      reportMomentReqState: reportMomentReqState ?? this.reportMomentReqState,
      addMomentMessage: addMomentMessage ?? this.addMomentMessage,
      reportMomentMessage: reportMomentMessage ?? this.reportMomentMessage,
      image: isImageNull ? null : image ?? this.image,
      deleteMomentReqState: deleteMomentReqState ?? this.deleteMomentReqState,
      deleteMomentMessage: deleteMomentMessage ?? this.deleteMomentMessage,
      likeMomentReqState: likeMomentReqState ?? this.likeMomentReqState,
      likeMomentMessage: likeMomentMessage ?? this.likeMomentMessage,
      lastPageMoment: lastPageMoment ?? this.lastPageMoment,
      currentPageMoment: currentPageMoment ?? this.currentPageMoment,
      lastPageMyMoment: lastPageMyMoment ?? this.lastPageMyMoment,
      currentPageMyMoment: currentPageMyMoment ?? this.currentPageMyMoment,
      lastPageFollowMoment: lastPageFollowMoment ?? this.lastPageFollowMoment,
      currentPageFollowMoment:
          currentPageFollowMoment ?? this.currentPageFollowMoment,
      lastPageLatestMoment: lastPageLatestMoment ?? this.lastPageLatestMoment,
      currentPageLatestMoment:
          currentPageLatestMoment ?? this.currentPageLatestMoment,
      scrollControllerMyMoment:
          scrollControllerMyMoment ?? this.scrollControllerMyMoment,
      scrollControllerMoment:
          scrollControllerMoment ?? this.scrollControllerMoment,
      scrollControllerFollowMoment:
          scrollControllerFollowMoment ?? this.scrollControllerFollowMoment,
      scrollControllerLatestMoment:
          scrollControllerLatestMoment ?? this.scrollControllerLatestMoment,
      multiImages: multiImages ?? this.multiImages,
      // createMomentController:
      //     this.createMomentController.copyWith(text: createMomentController),

      isFormValid: isFormValid??this.isFormValid,
      showEmoji: showEmoji??this.showEmoji,
      isPaginatingMoment: isPaginatingMoment ?? this.isPaginatingMoment,
      isPaginatingFollowMoment: isPaginatingFollowMoment ?? this.isPaginatingFollowMoment,
      isPaginatingLatestMoment: isPaginatingLatestMoment ?? this.isPaginatingLatestMoment,
    );
  }

  @override
  List<Object?> get props => [
        moments,
        reqState,
        myMoments,
        myReqState,
        myMessage,
        message,
        isAddMoment,
        reportMomentReqState,
        reportMomentMessage,
        addMomentReqState,
        addMomentMessage,
        image,
        deleteMomentReqState,
        deleteMomentMessage,
        likeMomentReqState,
        likeMomentMessage,
        currentPageMoment,
        currentPageMyMoment,
        lastPageMyMoment,
        scrollControllerMoment,
        lastPageMoment,
        currentPageFollowMoment,
        lastPageFollowMoment,
        currentPageLatestMoment,
        scrollControllerMyMoment,
        lastPageLatestMoment,
        scrollControllerFollowMoment,
        scrollControllerLatestMoment,
        reqLatestState,
        reqFollowState,
        followMessage,
        followMoments,
        latestMessage,
        latestMoments,
        multiImages,
        //createMomentController,
        isFormValid,
        showEmoji,
        isPaginatingMoment,
        isPaginatingFollowMoment,
        isPaginatingLatestMoment,
      ];
}
