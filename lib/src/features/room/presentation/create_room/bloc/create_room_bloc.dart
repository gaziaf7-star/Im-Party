import 'dart:async';
import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/create_room_model.dart';
import 'package:general/src/features/home/domain/entities/room_types_entity.dart';
import 'package:general/src/features/home/domain/home_use_case/create_room_use_case.dart';
import 'package:general/src/features/home/domain/home_use_case/get_all_room_types_uc.dart';
import 'package:general/src/features/room/domain/entities/create_paid_room_entity.dart';
import 'package:general/src/features/room/domain/use_case/create_paid_room_us.dart';

part 'create_room_events.dart';

part 'create_room_states.dart';

class CreateRoomBloc extends Bloc<CreateRoomEvents, CreateRoomStates> {
  final CreateRoomUC _createRoomUsecase;
  final GetAllRoomTypesUC _getAllRoomTypesUC;
  final CreatePaidRoomUs _createPaidRoomUs;
  bool _isCreatingRoom = false;

  CreateRoomBloc(
      this._createRoomUsecase, this._getAllRoomTypesUC, this._createPaidRoomUs)
      : super(CreateRoomStates(
          formKey: GlobalKey<FormState>(),
          name: TextEditingController(),
          bio: TextEditingController(),
        )) {
    on<CreateAudioRoomEvent>(_createRoom);
    on<GetTypesRoomEvent>(_getTypeRooms);
    on<PickRoomImage>(_pickFileEvent);
    on<RemoveRoomImage>(_removeFileEvent);
    on<SelectRoomTypeEvent>(_selectRoomTypeEvent);
    on<DisposeEvent>(_disposeEvent);
    on<CreatePaidRoomEvent>(_createPaidRoom);
  }

  Future<void> _createRoom(
    CreateAudioRoomEvent event,
    Emitter<CreateRoomStates> emit,
  ) async {
    if (_isCreatingRoom) return;
    _isCreatingRoom = true;

    try {
      emit(state.copyWith(reqState: RequestState.loading));

      final result = await _createRoomUsecase.call(
        CreateRoomParameter(
          roomCover: event.roomCover,
          roomType: event.roomType,
          roomPassword: event.password,
          roomIntero: event.roomIntero,
          roomName: event.roomName,
          type: event.type,
        ),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            createRoomMsg: NetworkExceptions.getErrorMessage(failure),
            reqState: RequestState.error,
          ));
        },
        (success) {
          emit(state.copyWith(
            createRoomData: success.data,
            reqState: RequestState.loaded,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        createRoomMsg: e.toString(),
        reqState: RequestState.error,
      ));
    } finally {
      _isCreatingRoom = false;
    }
  }

  Future<void> _selectRoomTypeEvent(
      SelectRoomTypeEvent event, Emitter<CreateRoomStates> emit) async {
    emit(state.copyWith(selectedRoomTypeId: event.roomTypeId));
  }

  void _disposeEvent(DisposeEvent event, Emitter<CreateRoomStates> emit) {
    state.bio.clear();
    emit(state.copyWith(
      clearImage: true,
      isImageNull: false,
      selectedRoomTypeId: -1,
    ));
    di<CreateRoomBloc>().add(SelectRoomTypeEvent(-1));
    state.name.clear();
  }

  Future<void> _getTypeRooms(
      GetTypesRoomEvent event, Emitter<CreateRoomStates> emit) async {
    final result = await _getAllRoomTypesUC.call();
    result.fold(
        (failure) => emit(state.copyWith(
            typesMsg: NetworkExceptions.getErrorMessage(failure),
            typesRoomState: RequestState.error)),
        (success) => emit(state.copyWith(
            typesRoom: success.data, typesRoomState: RequestState.loaded)));
  }

  Future<void> _removeFileEvent(
      RemoveRoomImage event, Emitter<CreateRoomStates> emit) async {
    emit(
      state.copyWith(
        image: null,
        clearImage: true,
        isImageNull: false,
        reqState: RequestState.idle,
      ),
    );
  }

  Future<void> _pickFileEvent(
    PickRoomImage event,
    Emitter<CreateRoomStates> emit,
  ) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile =
          await Methods.pickImageSafely(picker, source: ImageSource.gallery);

      if (pickedFile != null) {
        final String extension = pickedFile.path.split('.').last.toLowerCase();
        if (extension == 'gif' || extension == 'webp') {
          Methods.safeShowToast(
            message: StringManager.warningGif.tr(),
            isError: true,
          );
          emit(state.copyWith(
            isImageNull: true,
            reqState: RequestState.idle,
          ));
          return;
        }

        File imageFile = File(pickedFile.path);
        final fileSizeInBytes = await imageFile.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 2) {
          Methods.safeShowToast(
            message: StringManager.picSize.tr(),
            isError: true,
          );
          emit(state.copyWith(
            isImageNull: true,
            reqState: RequestState.idle,
          ));
          return;
        }

        emit(state.copyWith(
          image: imageFile,
          reqState: RequestState.idle,
        ));
      } else {
        emit(state.copyWith(
          isImageNull: true,
          reqState: RequestState.idle,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        isImageNull: true,
        reqState: RequestState.idle,
      ));
    }
  }

  Future<void> _createPaidRoom(
    CreatePaidRoomEvent event,
    Emitter<CreateRoomStates> emit,
  ) async {
    final result = await _createPaidRoomUs.call();
    result.fold(
      (failure) => emit(
        state.copyWith(
          createPaidRoomMsg: NetworkExceptions.getErrorMessage(failure),
          createPaidRoomState: RequestState.error,
        ),
      ),
      (success) => emit(
        state.copyWith(
          createPaidRoomEntity: success.data,
          createPaidRoomState: RequestState.loaded,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    state.name.dispose();
    state.bio.dispose();
    return super.close();
  }
}
