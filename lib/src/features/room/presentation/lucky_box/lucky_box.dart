import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/lucky_box/component/lucky_box_content.dart';
import 'package:general/src/features/room/room.dart';

class LuckyBox extends StatelessWidget {
  final EnterRoomModel roomData;
  const LuckyBox({required this.roomData, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LuckyBoxBloc, LuckyBoxState>(
      bloc: di<LuckyBoxBloc>(),
      listener: (context, state) {
        if (state.sendLuckyBoxReqState?.isLoading == true) {
          Methods.showToast(
            context,
            isLoading: true,
          );
        }
        if (state.sendLuckyBoxReqState?.isLoaded == true) {
          RoomData.instance.chatController?.sendMessage(
            StringManager.sendBoxMessageKey,
            userData: {
              "coins": state.sendLuckyBoxEntity?.coins.toString() ?? "",
              "id": state.sendLuckyBoxEntity?.id.toString() ?? "",
              "name": state.sendLuckyBoxEntity?.user.name ?? "",
              "image": state.sendLuckyBoxEntity?.user.image ?? "",
              "uuid": state.sendLuckyBoxEntity?.user.uuid ?? "",
              "usersNumber": state.sendLuckyBoxEntity?.usersNum ?? "",
              "ownerId": state.sendLuckyBoxEntity?.user.id.toString() ?? "",
              "roomId": RoomData.instance.room.id.toString(),
              "remTime": state.sendLuckyBoxEntity?.endTime.toString() ?? "",
              "box_type":
                  state.sendLuckyBoxEntity?.type.toLowerCase() == "super"
                      ? "super"
                      : "normal",
              'type': 'games',
            },
          );

          di<LuckyBoxBloc>().add(ResetPickupLuckyBoxEvent());
          Navigator.pop(context);
        }
        if (state.sendLuckyBoxReqState?.isError == true) {
          Methods.showToast(
            context,
            isError: true,
            message: state.message ?? '',
          );
        }
      },
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.getLuckyBoxReqState ?? RequestState.idle,
          title: '',
          subTitle: '',
          isNeedLoadingWidget: false,
          // No fixed height here -- LuckyBoxContent already sizes itself
          // to its own content (Column with mainAxisSize.min). A fixed
          // height forced this wrapper to stretch taller than the actual
          // content, leaving a chunk of the sheet's gradient background
          // showing as empty space below the white card.
          child: SizedBox(
            width: ScreenUtil().screenWidth,
            child: LuckyBoxContent(
              luckyBoxEntity: state.boxData,
              room: roomData,
            ),
          ),
        );
      },
    );
  }
}
