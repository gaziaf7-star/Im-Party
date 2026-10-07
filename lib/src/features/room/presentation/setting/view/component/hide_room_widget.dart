part of '../setting_page.dart';

class HideRoomWidget extends StatefulWidget {
  const HideRoomWidget({super.key});

  @override
  State<HideRoomWidget> createState() => _HideRoomWidgetState();
}

class _HideRoomWidgetState extends State<HideRoomWidget> {
  @override
  initState() {
    di<MangerGetVipPrevBloc>().add(const GetVipPrevEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangerGetVipPrevBloc, MangerGetVipPrevState>(
      bloc: di<MangerGetVipPrevBloc>(),
      buildWhen: (prev, curr) => prev.requestState != curr.requestState || prev.data != curr.data,
      builder: (context, state) {
        switch (state.requestState) {
          case RequestState.loading:
            return Container(
              width: ScreenUtil().screenWidth,
              color: ColorManager.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    StringManager.hideRoom.tr(),
                    style: context.bodyLarge.bold.colorExt(ColorManager.black),
                  ),
                  CupertinoSwitch(
                    activeTrackColor: ColorManager.brandGradientColors.last,
                    value: MyDataModel.getInstance().isHideRoom ?? false,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (LockRoomDialog.roomIsLoked) {
                        bottomDailog(
                          context: context,
                          widget: UnLockRoom(roomId: RoomData.instance.room.id.toString()),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.r),
                            ),
                            insetPadding:
                            const EdgeInsets.symmetric(horizontal: 30),
                            child: const LockRoomDialog(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          case RequestState.loaded:
            GetVipPrevModel reslt =
                state.data.firstWhere((element) => element.key == "room");

            return Container(
              width: ScreenUtil().screenWidth,
              height: 40.h,
              decoration: const BoxDecoration(
                color: ColorManager.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    StringManager.hideRoom.tr(),
                    style: context.bodyLarge.bold.colorExt(ColorManager.black),
                  ),
                  CupertinoSwitch(
                    activeTrackColor: ColorManager.brandGradientColors.last,
                    value: reslt.isActive!,
                    onChanged: (value) {
                      if (reslt.isAllowToUser != true) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AnimatedDialog(
                              onTap: () {
                                context.popRoute();
                                context.pushNamedRoute(Routes.vipScreen,
                                    arguments: 0);
                              },
                              description: StringManager
                                      .thisFeatureisNotAvailableForYou(
                                          vip: reslt.mine.toString())
                                  .tr(),
                              title: reslt.titleAr ?? '',
                            );
                          },
                        );
                      } else {
                        if (reslt.isActive == false) {
                          di<PrivacyBloc>()
                              .add(ActivePrivacy(type: reslt.key!));
                        } else {
                          di<PrivacyBloc>()
                              .add(DisposePrivacy(type: reslt.key!));
                        }
                      }
                    },
                  )
                ],
              ),
            );
          case RequestState.error:
            return Container(
              width: ScreenUtil().screenWidth,
              height: 40.h,
              decoration: BoxDecoration(
                color: ColorManager.grey,
                borderRadius: 8.radius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    StringManager.hideRoom.tr(),
                    style: context.bodyLarge.bold.colorExt(ColorManager.black),
                  ),
                  CupertinoSwitch(
                    activeTrackColor: ColorManager.brandGradientColors.last,
                    value: MyDataModel.getInstance().isHideRoom!,
                    onChanged: (value) {
                      if (!(MyDataModel.getInstance().isHideRoom!)) {
                      } else {}
                    },
                  ),
                ],
              ),
            );
          case RequestState.offline:
            return const SizedBox();
          case null:
            return const SizedBox();
          case RequestState.idle:
            return const SizedBox();
          case RequestState.empty:
            return const SizedBox();
          case RequestState.ban_user:
            return const SizedBox();
        }
      },
    );
  }
}
