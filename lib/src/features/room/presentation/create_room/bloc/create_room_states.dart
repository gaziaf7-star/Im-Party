part of 'create_room_bloc.dart';

class CreateRoomStates extends Equatable {
  final List<RoomTypesEntity> typesRoom;
  final String typesMsg;
  final RequestState typesRoomState;
  final CreateRoomModel? createRoomData;
  final String createRoomMsg;
  final RequestState reqState;
  final File? image;
  final bool isImageNull;
  final TextEditingController name, bio;
  final GlobalKey<FormState> formKey;
  final int selectedRoomTypeId;

  final CreatePaidRoomEntity? createPaidRoomEntity;
  final String createPaidRoomMsg;
  final RequestState createPaidRoomState;

  const CreateRoomStates({
    this.createPaidRoomEntity,
    this.createPaidRoomMsg = '',
    this.createPaidRoomState = RequestState.idle,
    this.typesRoom = const [],
    this.typesMsg = '',
    this.createRoomMsg = '',
    this.typesRoomState = RequestState.idle,
    this.createRoomData,
    this.selectedRoomTypeId = -1,
    required this.formKey,
    required this.name,
    required this.bio,
    this.image,
    this.isImageNull = false,
    this.reqState = RequestState.idle,
  });

  CreateRoomStates copyWith({
    List<RoomTypesEntity>? typesRoom,
    RequestState? typesRoomState,
    String? typesMsg,
    String? createRoomMsg,
    CreateRoomModel? createRoomData,
    RequestState? reqState,
    File? image,
    bool clearImage = false,
    bool? isImageNull,
    String? name,
    String? bio,
    GlobalKey<FormState>? formKey,
    int? selectedRoomTypeId,
    CreatePaidRoomEntity? createPaidRoomEntity,
    String? createPaidRoomMsg,
    RequestState? createPaidRoomState,
  }) {
    return CreateRoomStates(
      typesRoom: typesRoom ?? this.typesRoom,
      name: this.name.copyWith(text: name),
      bio: this.bio.copyWith(text: bio),
      image: clearImage ? null : image ?? this.image,
      formKey: formKey ?? this.formKey,
      isImageNull: isImageNull ?? this.isImageNull,
      typesRoomState: typesRoomState ?? this.typesRoomState,
      createRoomMsg: createRoomMsg ?? this.createRoomMsg,
      typesMsg: typesMsg ?? this.typesMsg,
      createRoomData: createRoomData ?? this.createRoomData,
      reqState: reqState ?? this.reqState,
      selectedRoomTypeId: selectedRoomTypeId ?? this.selectedRoomTypeId,
      createPaidRoomEntity: createPaidRoomEntity ?? this.createPaidRoomEntity,
      createPaidRoomMsg: createPaidRoomMsg ?? this.createPaidRoomMsg,
      createPaidRoomState: createPaidRoomState ?? this.createPaidRoomState,
    );
  }

  @override
  List<Object?> get props => [
        typesRoom,
        typesMsg,
        typesRoomState,
        createRoomData,
        reqState,
        image,
        isImageNull,
        name,
        formKey,
        selectedRoomTypeId,
        createPaidRoomEntity,
        createPaidRoomMsg,
        createPaidRoomState,
      ];
}
