import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/component/buttons/basic_tool/basic_tool_dialog.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../../../core/index.dart';

class BasicToolButton extends StatelessWidget {
  final MyDataModel myDataModel;
  final String roomId;
  final String ownerId;
  final bool isOnMic;
  final EnterRoomModel roomData;

  const BasicToolButton({
    required this.roomData,
    required this.myDataModel,
    required this.roomId,
    super.key,
    required this.ownerId,
    required this.isOnMic,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (HomePage.isConnectToInternet == true) {
          bottomDailog(
            context: context,
            widget: BasicToolDialog(
              // ✅ FIXED
              parentContext: context,

              ownerId: ownerId,
              userId: myDataModel.id.toString(),
              isOnMic: isOnMic,
              roomData: roomData,
              isAdmin: RoomData.instance.adminsInRoom.containsKey(
                myDataModel.id.toString(),
              ),
            ),
          );
        } else {
          Methods.showToast(
            context,
            message: StringManager.pleaseCheckInternet.tr(),
            isError: true,
          );
        }
      },
      child: ConstantsManager.isTheme1
          ? Image.asset(
        AssetsManager.basicToolNew,
        width: 36.w,
        height: 36.h,
        fit: BoxFit.cover,
      )
          : CircleAvatar(
        radius: 19.5.r,
        backgroundColor: Colors.black.withValues(alpha: 0.1),
        child: Image.asset(
          AssetsManager.basicTool,
          color: Colors.white,
          width: 29.sp,
          height: 29.sp,
        ),
      ),
    );
  }
}