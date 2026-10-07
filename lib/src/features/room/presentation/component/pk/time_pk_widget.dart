import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/pk/pk_functions.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_bloc.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_events.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';

class TimePKWidget extends StatefulWidget {
  final Function() notifyRoom;
  final String roomId;
  const TimePKWidget({
    super.key,
    required this.notifyRoom,
    required this.roomId,
  });

  @override
  TimePKWidgetState createState() => TimePKWidgetState();
}

class TimePKWidgetState extends State<TimePKWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      padding: context.paddingSymmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: ColorManager.black,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          // Container(
          //   height: 3.h,
          //   width: 150.w,
          //   margin: context.paddingOnly(top: 15),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.only(
          //         topLeft: 10.radiusCircular, topRight: 10.radiusCircular),
          //     color: ColorManager.textForgteColor,
          //   ),
          // ),
          15.hBox,
          TextWidget(
            StringManager.chooseTimePK.tr(),
          ),
          5.hBox,
          Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  title: StringManager.fiveMin.tr(),
                  height: 40,
                  radius: 15.r,
                  fontWeight: FontWeight.normal,
                  fontSize: 12.sp,
                  borderColor: PkController.timeMinutePK == 5
                      ? ColorManager.transparent
                      : ColorManager.white,
                  titleColor: ColorManager.white,
                  backgroundColor: PkController.timeMinutePK == 5
                      ? ColorManager.primary
                      : ColorManager.transparent,
                  onPressed: () {
                    setState(() {
                      PkController.timeMinutePK = 5;
                    });
                  },
                ),
              ),
              10.wBox,
              Expanded(
                child: ButtonWidget(
                  title: StringManager.fiftyMin.tr(),
                  height: 40,
                  radius: 15.r,
                  fontWeight: FontWeight.normal,
                  fontSize: 12.sp,
                  borderColor: PkController.timeMinutePK == 15
                      ? ColorManager.transparent
                      : ColorManager.white,
                  titleColor: ColorManager.white,
                  backgroundColor: PkController.timeMinutePK == 15
                      ? ColorManager.primary
                      : ColorManager.transparent,
                  onPressed: () {
                    setState(() {
                      PkController.timeMinutePK = 15;
                    });
                  },
                ),
              ),
              10.wBox,
              Expanded(
                child: ButtonWidget(
                  title: StringManager.thirtyMin.tr(),
                  height: 40,
                  radius: 15.r,
                  fontWeight: FontWeight.normal,
                  fontSize: 12.sp,
                  borderColor: PkController.timeMinutePK == 30
                      ? ColorManager.transparent
                      : ColorManager.white,
                  titleColor: ColorManager.white,
                  backgroundColor: PkController.timeMinutePK == 30
                      ? ColorManager.primary
                      : ColorManager.transparent,
                  onPressed: () {
                    setState(() {
                      PkController.timeMinutePK = 30;
                    });
                  },
                ),
              ),
            ],
          ),
          40.hBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ButtonWidget(
                  title: StringManager.cancel.tr(),
                  height: 45.h,
                  fontSize: 14.sp,
                  titleColor: ColorManager.blackColor,
                  radius: 50,
                  fontWeight: FontWeight.w400,
                  borderColor: ColorManager.transparent,
                  backgroundColor: ColorManager.scaffoldBg,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              20.wBox,
              Expanded(
                child: ButtonWidget(
                  title: StringManager.start.tr(),
                  height: 45.h,
                  fontSize: 14.sp,
                  radius: 50,
                  backgroundColor: ColorManager.primary,
                  fontWeight: FontWeight.w400,
                  onPressed: () {
                    widget.notifyRoom();
                    if (PkController.timeMinutePK != 0) {
                      di<PKBloc>().add(
                        StartPKEvent(
                          time: '${PkController.timeMinutePK}',
                          roomId: widget.roomId,
                        ),
                      );
                      // LiveKit does not echo our own data messages, so the host
                      // never receives the broadcast `startPK` that starts the
                      // countdown. Start it locally with the chosen duration so
                      // the host's timer ticks immediately (remote participants
                      // start via the RTM handler).
                      startPKLocal(
                        PkController.timeMinutePK,
                        RoomData.instance.room.ownerId.toString(),
                        widget.roomId,
                        context,
                      );
                      Navigator.of(context).pop();
                    } else {
                      Methods.showToast(
                        context,
                        message: "Select time first",
                        isError: true,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
