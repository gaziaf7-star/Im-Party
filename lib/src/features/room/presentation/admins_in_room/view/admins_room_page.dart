part of '../../setting/view/setting_page.dart';

class AdminsRoomPage extends StatefulWidget {
  final String ownerId;
  final bool isAdmin;
  final bool isRoomManager;

  const AdminsRoomPage(
      {required this.ownerId,
        super.key,
        this.isAdmin = false,
        this.isRoomManager = false});

  @override
  State<AdminsRoomPage> createState() => _AdminsRoomPageState();
}

class _AdminsRoomPageState extends State<AdminsRoomPage> {
  @override
  void initState() {
    di<AdminRoomBloc>().add(GetAdminsEvent(
      ownerId: widget.ownerId,
      roomId: RoomData.instance.room.id.toString(),
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final title = di<RoomStateManager>().isInAudioRoom
        ? StringManager.noAdmins.tr()
        : StringManager.noAdminsLive.tr();
    final subTitle = di<RoomStateManager>().isInAudioRoom
        ? StringManager.noAdminsEmptySubTitle.tr()
        : StringManager.noAdminsEmptySubTitleLive.tr();
    return widget.isRoomManager
        ? Container(
      color: ColorManager.white,
      child: BlocBuilder<AdminRoomBloc, AdminRoomStates>(
        bloc: di<AdminRoomBloc>(),
        buildWhen: (prev, curr) =>
        prev.adminsReqState != curr.adminsReqState ||
            prev.admins != curr.admins,
        builder: (context, state) {
          return RefreshIndicatorWidget(
            onRefresh: () async {
              di<AdminRoomBloc>().add(GetAdminsEvent(
                ownerId: widget.ownerId,
                roomId: RoomData.instance.room.id.toString(),
              ));
            },
            child: HandlingDataWidget(
              reqState: state.adminsReqState,
              title: title,
              subTitle: subTitle,
              titleStyle:
              context.bodyLarge.bold.colorExt(ColorManager.black),
              onTap: () => di<AdminRoomBloc>().add(GetAdminsEvent(
                ownerId: widget.ownerId,
                roomId: RoomData.instance.room.id.toString(),
              )),
              child: ListView.separated(
                padding: context.paddingZero(),
                itemCount: state.admins.length,
                separatorBuilder: (context, state) {
                  return Container(
                    color: ColorManager.grey.withValues(alpha: 0.1),
                    height: 1.h,
                    width: ScreenUtil().screenWidth,
                  );
                },
                itemBuilder: (context, index) {
                  return UserRowWidget(
                    isAdmin: true,
                    ownerId: widget.ownerId.toString(),
                    frame: state.admins[index].frame ?? '',
                    frameType: state.admins[index].frameType ?? '',
                    vip: state.admins[index].vip?.img1 ?? "",
                    image: state.admins[index].profile?.image ?? "",
                    name: state.admins[index].name ?? "",
                    id: state.admins[index].id.toString(),
                    gender: state.admins[index].profile?.gender ?? 1,
                    senderImage:
                    state.admins[index].level?.senderImage ?? "",
                    receiverImage:
                    state.admins[index].level?.receiverImage ?? "",
                    uuid: state.admins[index].uuid.toString(),
                    age: 0,
                    coloredName: state.admins[index].colorName != null &&
                        (state.admins[index].colorName ?? '')
                            .isNotEmpty
                        ? Color(
                      int.parse(
                        (state.admins[index].colorName ?? '')
                            .replaceFirst('#', '0xff'),
                      ),
                    )
                        : Colors.black,
                    imageColorEntity:
                    state.admins[index].imageColorEntity,
                    specialId: state.admins[index].specialId,
                    idImage: state.admins[index].idImage ?? '',
                  );
                },
              ),
            ),
          );
        },
      ),
    )
        : Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.white,
        title: StringManager.roomManager,
        titleStyle: context.bodyLarge.bold.colorExt(Colors.black),
        iconColor: Colors.black,
      ),
      // Demote refreshes the list itself (UserRowWidget re-dispatches
      // GetAdminsEvent), so no add/remove req-state listener is needed.
      body: BlocBuilder<AdminRoomBloc, AdminRoomStates>(
        bloc: di<AdminRoomBloc>(),
        builder: (context, state) {
          return RefreshIndicatorWidget(
            onRefresh: () async {
              di<AdminRoomBloc>().add(GetAdminsEvent(
                ownerId: widget.ownerId,
                roomId: RoomData.instance.room.id.toString(),
              ));
            },
            child: HandlingDataWidget(
              reqState: state.adminsReqState,
              title: StringManager.noAdmins.tr(),
              subTitle: StringManager.noAdminsEmptySubTitle.tr(),
              titleStyle:
              context.bodyLarge.bold.colorExt(ColorManager.black),
              onTap: () => di<AdminRoomBloc>().add(GetAdminsEvent(
                ownerId: widget.ownerId,
                roomId: RoomData.instance.room.id.toString(),
              )),
              child: ListView.separated(
                padding: context.paddingZero(),
                itemCount: state.admins.length,
                separatorBuilder: (context, state) {
                  return Container(
                    color: ColorManager.grey.withValues(alpha: 0.1),
                    height: 1.h,
                    width: ScreenUtil().screenWidth,
                  );
                },
                itemBuilder: (context, index) {
                  return UserRowWidget(
                    isAdmin: true,
                    ownerId: widget.ownerId.toString(),
                    frame: state.admins[index].frame ?? '',
                    frameType: state.admins[index].frameType ?? '',
                    vip: state.admins[index].vip?.img1 ?? "",
                    image: state.admins[index].profile?.image ?? "",
                    name: state.admins[index].name ?? "",
                    id: state.admins[index].id.toString(),
                    gender: state.admins[index].profile?.gender ?? 1,
                    senderImage:
                    state.admins[index].level?.senderImage ?? "",
                    receiverImage:
                    state.admins[index].level?.receiverImage ?? "",
                    uuid: state.admins[index].uuid.toString(),
                    age: 0,
                    coloredName: state.admins[index].colorName != null &&
                        (state.admins[index].colorName ?? '')
                            .isNotEmpty
                        ? Color(
                      int.parse(
                        (state.admins[index].colorName ?? '')
                            .replaceFirst('#', '0xff'),
                      ),
                    )
                        : Colors.black,
                    imageColorEntity:
                    state.admins[index].imageColorEntity,
                    specialId: state.admins[index].specialId,
                    idImage: state.admins[index].idImage ?? '',
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}