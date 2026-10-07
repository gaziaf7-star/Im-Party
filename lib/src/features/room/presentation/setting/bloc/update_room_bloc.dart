import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_event.dart';
import 'package:general/src/features/room/room.dart';
part 'update_room_states.dart';
part 'update_room_events.dart';

class UpdateRoomBloc extends Bloc<UpdateRoomEvents, UpdateRoomStates> {
  final UpdateRoomUC _updateRoomUseCase;
  final ImagePicker _imagePicker = ImagePicker();
  static UpdateRoomBloc get(context) => BlocProvider.of(context);
  UpdateRoomBloc(
    this._updateRoomUseCase,
  ) : super(const UpdateRoomStates()) {
    on<UpdateRoomEvent>(_updateRoom);
    on<PickImageEvent>(_onPickImage);
  }

  Future<void> _updateRoom(
    UpdateRoomEvent event,
    Emitter<UpdateRoomStates> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await _updateRoomUseCase.call(
      ParameterUpdate(
        ownerId: event.ownerId,
        roomCover: event.roomCover,
        roomType: event.roomType,
        roomName: event.roomName,
        freeMic: event.freeMic,
        roomIntro: event.roomIntro,
        roomBackgroundId: event.roomBackgroundId,
        roomClass: event.roomClass,
        roomPass: event.roomPass,
        change: event.change,
        roomId: event.roomId,
        roomVideoType: event.roomVideoType,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          error: NetworkExceptions.getErrorMessage(failure),
          requestState: RequestState.error,
        ),
      ),
      (success) {
        emit(
          state.copyWith(
            data: success.data!,
            requestState: RequestState.loaded,
            successMessage: success.message,
          ),
        );
        if (!di<FetchMyRoomDataBloc>().state.requestState.isLoading) {
          di<FetchMyRoomDataBloc>().add(const FetchMyRoomDataEvent());
        }
        // Reflect the edit in the CURRENTLY OPEN room immediately for the
        // person who just saved it -- previously only FetchMyRoomDataBloc
        // (the home screen's "my room" card) was refreshed, so the room
        // header behind this dialog kept showing the old name/intro/cover
        // until you left and re-entered the room. Same fields/notifier the
        // realtime "changeBackground" RTM handler already uses in
        // room_controller.dart's changeBackgroundRoom(), which is what
        // pushes this same update live to every OTHER viewer in the room.
        final updated = success.data;
        if (updated != null && RoomData.instance.room.id == updated.id) {
          RoomData.instance.room.roomName = updated.roomName;
          RoomData.instance.room.roomIntro = updated.roomIntro;
          RoomData.instance.room.roomCover = updated.roomCover;
          RoomData.instance.roomDataUpdates['room_name'] =
              updated.roomName ?? '';
          RoomData.instance.roomDataUpdates['room_intro'] =
              updated.roomIntro ?? '';
          RoomData.instance.roomDataUpdates['room_img'] =
              updated.roomCover ?? '';
          OwnerOfRoom.isEditRoom.value = OwnerOfRoom.isEditRoom.value + 1;
        }
      },
    );
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<UpdateRoomStates> emit,
  ) async {
    try {
      final pickedFile =
          await Methods.pickImageSafely(_imagePicker, source: event.source);

      if (pickedFile != null) {
        final filePath = pickedFile.path;
        final file = File(filePath);

        if (filePath.toLowerCase().endsWith('.gif') ||
            filePath.toLowerCase().endsWith('webp')) {
          Methods.showToast(
            event.context,
            message: StringManager.warningGif.tr(),
            isError: true,
          );
          return;
        }
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        if (fileSizeInMB > 2) {
          Methods.showToast(
            event.context,
            message: StringManager.picSize.tr(),
            isError: true,
          );
          return;
        }

        final result = await Methods().compressFile(xFile: pickedFile);

        emit(state.copyWith(
          imagePath: result.path,
          requestStatePickImage: RequestState.loaded,
        ));

        di<UpdateRoomBloc>().add(
          UpdateRoomEvent(
            roomCover: File(result.path),
            ownerId: event.ownerId,
            roomId: RoomData.instance.room.id.toString(),
            roomVideoType: RoomData.instance.room.streamType.toString(),
          ),
        );
      } else {
        emit(state.copyWith(
          errorPickImage: 'No image selected',
          requestStatePickImage: RequestState.loaded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorPickImage: '$e'));
    }
  }
}
