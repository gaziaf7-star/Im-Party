import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_event.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/room/room.dart';

part 'components/form_add_info_body.dart';
part 'components/pick_image_body.dart';

class CreateRoomPage extends StatelessWidget {
  /// When true, creates a LIVE show (sends `type: 'live'`) and enters the live
  /// room as host on success; otherwise creates an audio room (default).
  final bool isLive;

  const CreateRoomPage({super.key, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBgAlt,
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.scaffoldBgAlt,
        title: isLive ? StringManager.goLive.tr() : StringManager.createRoom.tr(),
      ),
      body: BlocConsumer<CreateRoomBloc, CreateRoomStates>(
        bloc: di<CreateRoomBloc>(),
        listener: (_, state) {
          if (state.reqState.isLoaded) {
            di<FetchMyRoomDataBloc>().add(const FetchMyRoomDataEvent());
            RoomData.instance.room = EnterRoomModel(
              ownerId: MyDataModel.getInstance().id,
              id: state.createRoomData?.id??0,
              roomName: state.createRoomData?.name ?? "",
              roomCover: state.createRoomData?.cover ?? "",
              roomBackground:
                  state.createRoomData?.background ?? "",
              mode: state.createRoomData?.mode.toString() ?? '',
              uuidOwnerRoom: MyDataModel.getInstance().uuid ?? "",
              giftPrice: state.createRoomData?.giftPrice ?? "",
            );

            Navigator.pop(context);
            final navContext = SafeNavigator.context;
            if (navContext == null) return;
            if (isLive) {
              // Live: enter the new live room as host via RoomStateManager so
              // room state, background service and wakelock stay consistent with
              // the normal live-entry path.
              di<RoomStateManager>().navigateToRoom(
                RoomEntryRequest(
                  context: navContext,
                  roomData: RoomEntity(
                    ownerId: MyDataModel.getInstance().id,
                    id: state.createRoomData?.id,
                    name: state.createRoomData?.name,
                    cover: state.createRoomData?.cover,
                    roomBackground: state.createRoomData?.background,
                    mode: state.createRoomData?.mode.toString(),
                    uuidOwnerRoom: MyDataModel.getInstance().uuid ?? "",
                    giftPrice: state.createRoomData?.giftPrice,
                    ownerSpecialId: MyDataModel.getInstance().specialIdImage,
                    ownerImageColor: MyDataModel.getInstance().imageColorEntity,
                    streamType: "live",
                    isLive: true,
                  ),
                  isLive: true,
                ),
              );
            } else {
              Navigator.pushNamed(
                navContext,
                Routes.roomScreen,
                arguments: RoomParameter(
                  myDataModel: MyDataModel.getInstance(),
                  roomId: '${state.createRoomData?.id}',
                  ownerId: '${MyDataModel.getInstance().id}',
                  isHost: true,
                  isLocked: false,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                25.hBox,
                const PickImageBody(),
                10.wBox,
                15.hBox,
                _FormAddInfoBody(isLive: isLive),
              ],
            ),
          );
        },
      ),
    );
  }
}
