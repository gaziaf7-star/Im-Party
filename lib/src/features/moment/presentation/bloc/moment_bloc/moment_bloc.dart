import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/domain/usecases/report_moment_uc.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import '../../../../auth/domain/entities/profile_room_entity.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../moment_likes_bloc/get_moment_likes_event.dart';
import '../moment_likes_bloc/moment_likes_bloc_bloc.dart';

class MomentBloc extends Bloc<MomentEvent, MomentStates> {
  final FetchMomentUseCase fetchMomentUseCase;
  final AddMomentUseCase addMomentUseCase;
  final DeleteMomentUseCase deleteMomentUseCase;
  final LikeMomentUseCase likeMomentUseCase;
  final ReportMomentUC reportMomentUC;

  MomentBloc({
    required this.fetchMomentUseCase,
    required this.addMomentUseCase,
    required this.deleteMomentUseCase,
    required this.likeMomentUseCase,
    required this.reportMomentUC,
  }) : super(MomentStates(
          scrollControllerMoment: ScrollController(),
          scrollControllerFollowMoment: ScrollController(),
          scrollControllerLatestMoment: ScrollController(),
          scrollControllerMyMoment: ScrollController(),
        )) {
    on<FetchMomentData>(fetchMoment);
    on<FetchLatestMomentData>(fetchLatestMoment);
    on<FetchFollowMomentData>(fetchFollowMoment);
    on<FetchMyMomentData>(fetchMyMoment);
    on<ReportMomentEvent>(_reportMoment);
    on<FetchMoreMoments>(fetchMoreMoment);
    on<InitializeFormEvent>(_initializeFormEvent);
    on<AddMomentData>(addMoment);
    on<DeleteMomentData>(deleteMoment);
    on<LikeMomentData>(likeMoment);
    on<PickImageMomentEvent>(_pickFileEvent);
    on<RemovePickedImageEvent>(_removePickFileEvent);
    on<RemoveMultiPickedImageEvent>(_removeMultiPickFileEvent);
    on<ChangeRankIconEvent>(_changeIcon);
    on<UpdateIsLikeEvent>(_updateIsLikeEvent);
    on<UpdateCommentEvent>(_updateCommentsEvent);
    on<AddListenerMomentEvent>(_addEventListenerMoment);
    on<AddListenerMyMomentEvent>(_addEventListenerMyMoment);
    on<AddListenerFollowMomentEvent>(_addEventListenerFollowMoment);
    on<AddListenerLatestMomentEvent>(_addEventListenerLatestMoment);
    on<RemoveListenerMomentEvent>(_removeEventListenerMoment);
    on<RemoveListenerFollowMomentEvent>(_removeEventListenerFollowMoment);
    on<RemoveListenerMyMomentEvent>(_removeEventListenerMyMoment);
    on<AddListenerMyMomentWithoutControllerEvent>(
        _listenerMyMomentWithoutController);
    on<RemoveListenerLatestMomentEvent>(_removeEventListenerLatestMoment);
    on<PickMultiPicEvent>(_pickMultiImages);
    on<UpdateValidationEvent>(_updateFormValidationEvent);
    on<MomentFollowEvent>(_momentFollowEvent);
    on<ShowEmojiPickerEvent>(_showEmojiPickerEvent);
    on<MomentShareEvent>(_momentShareEvent);
    on<RemoveMomentLocally>(_removeMomentLocallyEvent);
    on<ResetMyMomentsEvent>(_resetMyMoments);
  }

  Future<void> fetchLatestMoment(
      FetchLatestMomentData event, Emitter<MomentStates> emit) async {
    if (event.isRefresh == true) {
      emit(state.copyWith(
          currentPageLatestMoment: 1, isPaginatingLatestMoment: false));
    } else if (state.latestMoments.isNotEmpty) {
      emit(state.copyWith(isPaginatingLatestMoment: true));
    }
    final result = await fetchMomentUseCase.call(MomentsParam(
        type: "5" /*event.type*/,
        page: state.currentPageLatestMoment.toString(),
        userId: event.userId));
    result.fold(
      (l) => emit(
        state.copyWith(
            reqLatestState: RequestState.error,
            isPaginatingLatestMoment: false,
            latestMessage: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          lastPageLatestMoment: r.paginates?.lastPage,
          isPaginatingLatestMoment: false,
          reqLatestState: handleLoadedResponse<List<MomentEntity>>(r.data),
          latestMoments: handlePaginationResponse<MomentEntity>(
            result: r.data,
            currentList: state.latestMoments,
            currentPage: state.currentPageLatestMoment,
          ),
        ));
      },
    );
  }

  Future<void> _momentShareEvent(
      MomentShareEvent event, Emitter<MomentStates> emit) async {
    List<MomentEntity> momentEntity = List.from(state.moments);
    momentEntity.removeWhere(
      (element) => element.momentId == event.currentMoment.momentId,
    );
    momentEntity.insert(0, event.currentMoment);
    emit(state.copyWith(moments: momentEntity));
  }

  Future<void> fetchFollowMoment(
      FetchFollowMomentData event, Emitter<MomentStates> emit) async {
    if (event.isRefresh == true) {
      emit(state.copyWith(
          currentPageFollowMoment: 1, isPaginatingFollowMoment: false));
    } else if (state.followMoments.isNotEmpty) {
      emit(state.copyWith(isPaginatingFollowMoment: true));
    }
    final result = await fetchMomentUseCase.call(MomentsParam(
        type: "6" /*event.type*/,
        page: state.currentPageFollowMoment.toString(),
        userId: event.userId));
    result.fold(
      (l) => emit(
        state.copyWith(
            reqFollowState: RequestState.error,
            isPaginatingFollowMoment: false,
            followMessage: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          lastPageFollowMoment: r.paginates?.lastPage,
          isPaginatingFollowMoment: false,
          reqFollowState: handleLoadedResponse<List<MomentEntity>>(r.data),
          followMoments: handlePaginationResponse<MomentEntity>(
            result: r.data,
            currentList: state.followMoments,
            currentPage: state.currentPageFollowMoment,
          ),
        ));
      },
    );
  }

  Future<void> fetchMoment(
      FetchMomentData event, Emitter<MomentStates> emit) async {
    if (event.isRefresh == true) {
      emit(state.copyWith(currentPageMoment: 1, isPaginatingMoment: false));
    } else if (state.moments.isNotEmpty) {
      emit(state.copyWith(isPaginatingMoment: true));
    }
    final result = await fetchMomentUseCase.call(MomentsParam(
        type: "4",
        page: state.currentPageMoment.toString(),
        userId: event.userId));
    result.fold(
      (l) => emit(
        state.copyWith(
            reqState: RequestState.error,
            isPaginatingMoment: false,
            message: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          lastPageMoment: r.paginates?.lastPage,
          isPaginatingMoment: false,
          reqState: handleLoadedResponse<List<MomentEntity>>(r.data),
          moments: handlePaginationResponse<MomentEntity>(
            result: r.data,
            currentList: state.moments,
            currentPage: state.currentPageMoment,
          ),
        ));
      },
    );
  }

  Future<void> fetchMyMoment(
      FetchMyMomentData event, Emitter<MomentStates> emit) async {
    final result = await fetchMomentUseCase.call(MomentsParam(
        type: event.type,
        page: state.currentPageMyMoment.toString(),
        userId: event.userId));
    result.fold(
      (l) => emit(
        state.copyWith(
            myReqState: RequestState.error,
            myMessage: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          lastPageMyMoment: r.paginates?.lastPage,
          myReqState: handleLoadedResponse<List<MomentEntity>>(r.data),
          myMoments: handlePaginationResponse<MomentEntity>(
            result: r.data,
            currentList: state.myMoments,
            currentPage: state.currentPageMyMoment,
          ),
        ));
      },
    );
  }

  Future<void> _reportMoment(
      ReportMomentEvent event, Emitter<MomentStates> emit) async {
    emit(state.copyWith(
      reportMomentReqState: RequestState.loading,
    ));
    final result = await reportMomentUC.call(event.reportMomentParam);

    result.fold(
      (l) {
        emit(
          state.copyWith(
              reportMomentReqState: RequestState.error,
              reportMomentMessage: NetworkExceptions.getErrorMessage(l)),
        );

        Navigator.pop(event.context);
        Methods.showToast(event.context,
            message: state.reportMomentMessage, isError: true);
      },
      (r) {
        emit(state.copyWith(
            reportMomentMessage: r.message,
            reportMomentReqState: RequestState.loaded));
        Navigator.pop(event.context);
        Methods.showToast(event.context, message: state.reportMomentMessage);
      },
    );
  }

  Future<void> fetchMoreMoment(
      FetchMoreMoments event, Emitter<MomentStates> emit) async {
    final result = await fetchMomentUseCase
        .call(MomentsParam(page: event.page, type: event.type));
    result.fold(
      (l) => emit(
        state.copyWith(
            reqState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          moments: [...state.moments, ...?r.data], // Append new data
          reqState: RequestState.loaded,
        ));
      },
    );
  }

  Future<void> _initializeFormEvent(
      InitializeFormEvent event, Emitter<MomentStates> emit) async {
    emit(state.copyWith(
      createMomentController: "",
      multiImages: [],
    ));
  }

  Future<void> addMoment(
      AddMomentData event, Emitter<MomentStates> emit) async {
    emit(state.copyWith(addMomentReqState: RequestState.loading));
    log(' Text Description: ${event.moment}');
    for (var i = 0; i < state.multiImages.length; i++) {
      log('MULTI image [$i]: ${state.multiImages[i].path}');
    }
    final result = await addMomentUseCase.call(AddMomentParametersUC(
      text: event.moment,
      multiImages: state.multiImages,
    ));
    result.fold(
      (l) {
        emit(
          state.copyWith(
              addMomentReqState: RequestState.error,
              addMomentMessage: NetworkExceptions.getErrorMessage(l)),
        );
        Methods.showToast(event.context,
            isError: true, message: state.addMomentMessage);
      },
      (r) {
        emit(state.copyWith(
          addMomentMessage: r.message,
          addMomentReqState: RequestState.loaded,
        ));
        emit(state.copyWith(addMomentReqState: RequestState.idle));
        add(const FetchMomentData(type: '4'));
      },
    );
  }

  Future<void> deleteMoment(
    DeleteMomentData event,
    Emitter<MomentStates> emit,
  ) async {
    emit(state.copyWith(deleteMomentReqState: RequestState.loading));
    Methods.showToast(event.context, message: "Deleting...", isLoading: true);

    final result = await deleteMomentUseCase.call(event.momentId);

    result.fold(
      (left) {
        final errorMsg = NetworkExceptions.getErrorMessage(left);
        emit(state.copyWith(
          deleteMomentReqState: RequestState.error,
          deleteMomentMessage: errorMsg,
        ));
        Methods.showToast(event.context, isError: true, message: errorMsg);
      },
      (right) {
        add(RemoveMomentLocally(
          momentId: int.parse(event.momentId),
          type: event.type,
        ));

        final momentIdStr = event.momentId;
        final updatedState = state.copyWith(
          deleteMomentReqState: RequestState.loaded,
          deleteMomentMessage: right.message,
          latestMoments: state.latestMoments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
          followMoments: state.followMoments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
          myMoments: state.myMoments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
          moments: state.moments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
        );

        emit(updatedState);
        Methods.showToast(event.context, message: right.message);
      },
    );
  }

  Future<void> likeMoment(
      LikeMomentData event, Emitter<MomentStates> emit) async {
    final result = await likeMomentUseCase.call(event.momentId);
    result.fold(
      (l) => emit(
        state.copyWith(
            likeMomentReqState: RequestState.error,
            likeMomentMessage: NetworkExceptions.getErrorMessage(l)),
      ),
      (r) {
        emit(state.copyWith(
          likeMomentMessage: r.data,
          likeMomentReqState: RequestState.loaded,
        ));
        di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
            momentId: event.momentId, page: "1", isLoading: false));
      },
    );
  }

  Future<void> _pickFileEvent(
    PickImageMomentEvent event,
    Emitter<MomentStates> emit,
  ) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await Methods.pickImageSafely(picker, source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        emit(state.copyWith(image: imageFile));
      } else {
        emit(state.copyWith(isImageNull: true));
      }
    } catch (error) {
      emit(state.copyWith(isImageNull: true));
      throw '$error';
    }
  }

  Future<void> _pickMultiImages(
    PickMultiPicEvent event,
    Emitter<MomentStates> emit,
  ) async {
    List<File> files = [];
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      if (result.files.first.path!.toLowerCase().endsWith('.gif')) {
        Methods().showWaringGifDialog();
      }
      for (final file in result.files) {
        if (['jpg', 'jpeg', 'png'].contains(file.extension)) {
          final originalFile = File(file.path!);

          final xFile = XFile(originalFile.path);

          final compressedXFile = await Methods().compressFile(xFile: xFile);

          files.add(File(compressedXFile.path));
        }
      }

      final int remainingSlots = 9 - state.multiImages.length;

      if (files.length > remainingSlots) {
        files = files.sublist(0, remainingSlots);
      }

      emit(state.copyWith(
        multiImages: [...state.multiImages, ...files],
        isFormValid: true,
      ));
    }
  }

  Future<void> _removeMultiPickFileEvent(
    RemoveMultiPickedImageEvent event,
    Emitter<MomentStates> emit,
  ) async {
    final List<File> currentFiles = List.from(state.multiImages);
    currentFiles.removeAt(event.element);
    emit(state.copyWith(
        multiImages: currentFiles,
        isFormValid: currentFiles.isNotEmpty || event.moment.isNotEmpty));
  }

  Future<void> _removePickFileEvent(
    RemovePickedImageEvent event,
    Emitter<MomentStates> emit,
  ) async {
    emit(state.copyWith(image: null, isImageNull: true));
  }

  Future<void> _changeIcon(
    ChangeRankIconEvent event,
    Emitter<MomentStates> emit,
  ) async {
    emit(state.copyWith(isAddMoment: event.isAddMoment));
  }

  Future<void> _updateIsLikeEvent(
    UpdateIsLikeEvent event,
    Emitter<MomentStates> emit,
  ) async {
    try {
      // recommend moments
      if (event.type == MomentType.recommend) {
        // Find the moment to update
        final List<MomentEntity> updatedMoments = state.moments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(
                isLike: event.isLike, likeNum: event.likeNum);
          }
          return moment;
        }).toList();

        emit(state.copyWith(
          moments: updatedMoments,
          reqState: RequestState.loaded,
        ));

        // di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
        //     momentId: event.momentId.toString(), page: "1", isLoading: false));
      }

      // follow moments
      if (event.type == MomentType.follow) {
        final List<MomentEntity> updatedMoments =
            state.followMoments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(
                isLike: event.isLike, likeNum: event.likeNum);
          }
          return moment;
        }).toList();

        emit(state.copyWith(
          followMoments: updatedMoments,
          reqFollowState: RequestState.loaded,
        ));

        // di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
        //     momentId: event.momentId.toString(), page: "1" , isLoading: false));
      }

      // latest moments
      if (event.type == MomentType.latest) {
        final List<MomentEntity> updatedMoments =
            state.latestMoments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(
                isLike: event.isLike, likeNum: event.likeNum);
          }
          return moment;
        }).toList();

        emit(state.copyWith(
          latestMoments: updatedMoments,
          reqLatestState: RequestState.loaded,
        ));

        // di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
        //     momentId: event.momentId.toString(), page: "1", isLoading: false));
      }
      if (event.type == MomentType.myMoment) {
        final List<MomentEntity> updatedMoments = state.myMoments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(
                isLike: event.isLike, likeNum: event.likeNum);
          }
          return moment;
        }).toList();

        emit(state.copyWith(
          myMoments: updatedMoments,
          // myReqState: RequestState.loaded,
        ));

        // di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
        //     momentId: event.momentId.toString(), page: "1", isLoading: false));
      }
    } catch (error) {
      throw 'Failed to update isLike: $error';
    }
  }

  Future<void> _momentFollowEvent(
    MomentFollowEvent event,
    Emitter<MomentStates> emit,
  ) async {
    di<FollowBloc>().add(
      FollowEvent(
        userEntity: UserEntity(
          name: event.currentMoment.userName,
          id: event.currentMoment.userId,
          profile: ProfileRoomEntity(
            image: event.currentMoment.userImage,
          ),
        ),
        relationType: RelationType.profile,
      ),
    );

    final List<MomentEntity> updatedMoments = state.moments.map((moment) {
      if (moment.userId == event.userID) {
        return moment.copyWith(
          isFollow: true,
        );
      }
      return moment;
    }).toList();

    final List<MomentEntity> updatedFollowMoments =
        state.followMoments.map((moment) {
      if (moment.userId == event.userID) {
        return moment.copyWith(
          isFollow: true,
        );
      }
      return moment;
    }).toList();

    final List<MomentEntity> updatedLatestMoments =
        state.latestMoments.map((moment) {
      if (moment.userId == event.currentMoment.userId) {
        return moment.copyWith(
          isFollow: true,
        );
      }
      return moment;
    }).toList();

    emit(state.copyWith(
      moments: updatedMoments,
      followMoments: updatedFollowMoments,
      latestMoments: updatedLatestMoments,
      reqState: RequestState.loaded,
    ));
  }

  Future<void> _updateFormValidationEvent(
    UpdateValidationEvent event,
    Emitter<MomentStates> emit,
  ) async {
    bool isValid = event.moment.isNotEmpty || state.multiImages.isNotEmpty;
    if (state.isFormValid != isValid) {
      emit(state.copyWith(isFormValid: isValid));
    }
  }

  void _showEmojiPickerEvent(
    ShowEmojiPickerEvent event,
    Emitter<MomentStates> emit,
  ) {
    emit(state.copyWith(showEmoji: event.showEmoji));
  }

  Future<void> _updateCommentsEvent(
    UpdateCommentEvent event,
    Emitter<MomentStates> emit,
  ) async {
    try {
      // recommend moments
      if (event.type == MomentType.recommend) {
        // Find the moment to update
        final List<MomentEntity> updatedMoments = state.moments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(commentNum: event.commentsNum);
          }
          return moment;
        }).toList();
        emit(state.copyWith(
          moments: updatedMoments,
          reqState: RequestState.loaded,
        ));
      }
      // follow moments
      if (event.type == MomentType.follow) {
        final List<MomentEntity> updatedMoments =
            state.followMoments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(commentNum: event.commentsNum);
          }
          return moment;
        }).toList();
        emit(state.copyWith(
          followMoments: updatedMoments,
          reqFollowState: RequestState.loaded,
        ));
      }
      // latest moments
      if (event.type == MomentType.latest) {
        final List<MomentEntity> updatedMoments =
            state.latestMoments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(commentNum: event.commentsNum);
          }
          return moment;
        }).toList();
        emit(state.copyWith(
          latestMoments: updatedMoments,
          reqLatestState: RequestState.loaded,
        ));
      }
      // user prfile moments
      if (event.type == MomentType.myMoment) {
        final List<MomentEntity> updatedMoments = state.myMoments.map((moment) {
          if (moment.momentId == event.momentId) {
            return moment.copyWith(commentNum: event.commentsNum);
          }
          return moment;
        }).toList();
        emit(state.copyWith(
          myMoments: updatedMoments,
          reqLatestState: RequestState.loaded,
        ));
      }
    } catch (error) {
      throw 'Failed to update isLike: $error';
    }
  }

  void _addEventListenerMoment(
    AddListenerMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final visitScrollCtrl = state.scrollControllerMoment
      ..addListener(_listenerMoment);
    emit(state.copyWith(scrollControllerMoment: visitScrollCtrl));
  }

  void _addEventListenerFollowMoment(
    AddListenerFollowMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final scrollCtrl = state.scrollControllerFollowMoment
      ..addListener(_listenerFollowMoment);
    emit(state.copyWith(scrollControllerFollowMoment: scrollCtrl));
  }

  void _addEventListenerMyMoment(
    AddListenerMyMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final scrollCtrl = state.scrollControllerMyMoment
      ..addListener(() {
        _listenerMyMoment(event.userID);
      });
    emit(state.copyWith(scrollControllerMyMoment: scrollCtrl));
  }

  void _addEventListenerLatestMoment(
    AddListenerLatestMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final scrollCtrl = state.scrollControllerLatestMoment
      ..addListener(_listenerLatestMoment);
    emit(state.copyWith(scrollControllerLatestMoment: scrollCtrl));
  }

  void _removeEventListenerMoment(
    RemoveListenerMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final visitorsScroll = state.scrollControllerMoment
      ..removeListener(_listenerMoment);
    emit(state.copyWith(scrollControllerMoment: visitorsScroll));
  }

  void _removeEventListenerFollowMoment(
    RemoveListenerFollowMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final scrollCtrl = state.scrollControllerFollowMoment
      ..removeListener(_listenerFollowMoment);
    emit(state.copyWith(scrollControllerFollowMoment: scrollCtrl));
  }

  void _listenerMyMomentWithoutController(
    AddListenerMyMomentWithoutControllerEvent event,
    Emitter<MomentStates> emit,
  ) {
    if (state.currentPageMyMoment < state.lastPageMyMoment) {
      final int currentPage = state.currentPageMyMoment + 1;
      emit(state.copyWith(currentPageMyMoment: currentPage));
      add(FetchMyMomentData(userId: event.userID, type: '1'));
    }
  }

  void _removeEventListenerMyMoment(
    RemoveListenerMyMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final scrollCtrl = state.scrollControllerMyMoment
      ..removeListener(() {
        _listenerMyMoment(event.userID);
      });
    emit(state.copyWith(scrollControllerMyMoment: scrollCtrl));
  }

  void _removeEventListenerLatestMoment(
    RemoveListenerLatestMomentEvent event,
    Emitter<MomentStates> emit,
  ) {
    final scrollCtrl = state.scrollControllerLatestMoment
      ..removeListener(_listenerLatestMoment);
    emit(state.copyWith(scrollControllerLatestMoment: scrollCtrl));
  }

  void _listenerMoment() {
    handleScrollListener(
      controller: state.scrollControllerMoment,
      currentPage: state.currentPageMoment,
      lastPage: state.lastPageMoment,
      fun: () {
        final int currentPage = state.currentPageMoment + 1;
        emit(state.copyWith(currentPageMoment: currentPage));
        add(const FetchMomentData());
      },
    );
  }

  void _listenerFollowMoment() {
    handleScrollListener(
      controller: state.scrollControllerFollowMoment,
      currentPage: state.currentPageFollowMoment,
      lastPage: state.lastPageFollowMoment,
      fun: () {
        final int currentPage = state.currentPageFollowMoment + 1;
        emit(state.copyWith(currentPageFollowMoment: currentPage));
        add(const FetchFollowMomentData());
      },
    );
  }

  void _listenerMyMoment(String userId) {
    handleScrollListener(
      controller: state.scrollControllerMyMoment,
      currentPage: state.currentPageMyMoment,
      lastPage: state.lastPageMyMoment,
      fun: () {
        final int currentPage = state.currentPageMyMoment + 1;
        emit(state.copyWith(currentPageMyMoment: currentPage));
        add(FetchMyMomentData(userId: userId, type: '1'));
      },
    );
  }

  void _listenerLatestMoment() {
    handleScrollListener(
      controller: state.scrollControllerLatestMoment,
      currentPage: state.currentPageLatestMoment,
      lastPage: state.lastPageLatestMoment,
      fun: () {
        final int currentPage = state.currentPageLatestMoment + 1;
        emit(state.copyWith(currentPageLatestMoment: currentPage));
        add(const FetchLatestMomentData());
      },
    );
  }

  void _resetMyMoments(
    ResetMyMomentsEvent event,
    Emitter<MomentStates> emit,
  ) {
    emit(state.copyWith(
      myMoments: [],
      myReqState: RequestState.loading,
      currentPageMyMoment: 1,
      lastPageMyMoment: -1,
    ));
  }

  Future<void> _removeMomentLocallyEvent(
    RemoveMomentLocally event,
    Emitter<MomentStates> emit,
  ) async {
    final momentIdStr = event.momentId.toString();

    switch (event.type) {
      case MomentType.latest:
        emit(state.copyWith(
          latestMoments: state.latestMoments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
        ));
        break;

      case MomentType.follow:
        emit(state.copyWith(
          followMoments: state.followMoments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
        ));
        break;

      case MomentType.recommend:
        emit(state.copyWith(
          moments: state.moments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
        ));
        break;

      case MomentType.myMoment:
        emit(state.copyWith(
          myMoments: state.myMoments
              .where((e) => e.momentId.toString() != momentIdStr)
              .toList(),
        ));
        break;
    }
  }
}
