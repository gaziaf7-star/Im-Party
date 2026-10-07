import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/buttons/basic_tool/lock_room_dialog.dart';
import 'package:general/src/features/room/presentation/manager/room_manager/on_room_bloc.dart';
import 'package:general/src/features/room/presentation/manager/room_manager/on_room_events.dart';
import 'package:general/src/features/room/room.dart';

class UnLockRoom extends StatelessWidget {
  final String roomId;
  const UnLockRoom({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        color: const Color(0xff0B080F).withValues(alpha: (0.7 )),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            InkWell(
              onTap: () {
                di<OnRoomBloc>().add(RemovePassRoomEvent(roomId: roomId));
                LockRoomDialog.roomIsLoked = false;
                RoomData.instance.isRoomLocked.value = false;
                sendRoomData(data: {
                  "messageContent": {"message": "roomPassword", "value": false}
                });
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50.h,
                decoration: BoxDecoration(
                  color: ColorManager.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: ColorManager.primary,
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Text(
                    StringManager.unLockRoom.tr(),
                    style: context.bodyMedium.size(16).w500.colorExt(ColorManager.primary)
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            MainButton(
              title: StringManager.cancel.tr(),
              titleSize: 18.sp,
              buttonColor: ColorManager.primary,
              height: 50.h,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
