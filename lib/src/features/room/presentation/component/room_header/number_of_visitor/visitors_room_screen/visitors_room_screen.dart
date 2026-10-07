import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/presentation/component/room_header/number_of_visitor/visitors_room_screen/widgets/visitor_tab_bar.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_information/user_row_widget.dart';
import 'package:general/src/features/room/room.dart';

class VisitorsRoomScreen extends StatefulWidget {
  const VisitorsRoomScreen({
    required this.roomData,
    required this.vistors,
    super.key,
  });

  final EnterRoomModel roomData;
  final List<UTDParticipant> vistors;

  @override
  State<VisitorsRoomScreen> createState() => _VisitorsRoomScreenState();
}

class _VisitorsRoomScreenState extends State<VisitorsRoomScreen>
    with TickerProviderStateMixin {
  late final TabController controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450.h,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.r),
          topLeft: Radius.circular(15.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          15.hBox,
          VisitorTabBar(controller: controller, usersNo: widget.vistors.length),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: [
                ListView.separated(
                  itemCount: widget.vistors.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, state) {
                    return Container(
                      color: ColorManager.grey.withValues(alpha: 0.1),
                      height: 1.h,
                      width: ScreenUtil().screenWidth,
                    );
                  },
                  itemBuilder: (context, index) {
                    final userId = int.parse(widget.vistors[index].id);
                    final cachedUser = UsersCache().getUser(userId);

                    if (cachedUser != null) {
                      return UserRowWidget(
                        isAdmin: false,
                        ownerId: widget.roomData.ownerId.toString(),
                        frame: cachedUser.frame ?? "",
                        frameType: cachedUser.frameType ?? "",
                        vip: cachedUser.vipImage ?? "",
                        image: cachedUser.image ?? "",
                        name: cachedUser.name ?? "",
                        id: widget.vistors[index].id,
                        gender: cachedUser.gender ?? 1,
                        senderImage: cachedUser.senderLevelImage ?? "",
                        receiverImage: cachedUser.receiverLevelImage ?? "",
                        age: cachedUser.age ?? 0,
                        uuid: cachedUser.uuid ?? "",
                        coloredName:
                            Methods.safeHexColor(cachedUser.vipColorName) ??
                                ColorManager.black,
                        imageColorEntity: cachedUser.imageColorEntity,
                        specialId: cachedUser.specialId,
                        idImage: cachedUser.idImage??'',
                      );
                    } else {
                      return FutureBuilder<Map<int, UserInRoomModel>>(
                        future: getUsersByIds([userId]),
                        builder: (context, snapshot) {
                          final fetchedUser =
                              snapshot.data?[userId] ?? const UserInRoomModel();

                          return UserRowWidget(
                            isAdmin: false,
                            ownerId: widget.roomData.ownerId.toString(),
                            frame: fetchedUser.frame ?? "",
                            frameType: fetchedUser.frameType ?? "",
                            vip: fetchedUser.vipImage ?? "",
                            image: fetchedUser.image ?? "",
                            name: fetchedUser.name ?? "",
                            id: widget.vistors[index].id,
                            gender: fetchedUser.gender ?? 1,
                            senderImage: fetchedUser.senderLevelImage ?? "",
                            receiverImage: fetchedUser.receiverLevelImage ?? "",
                            age: fetchedUser.age ?? 0,
                            uuid: fetchedUser.uuid ?? "",
                            coloredName:
                                Methods.safeHexColor(fetchedUser.vipColorName) ??
                                    ColorManager.black,
                            imageColorEntity: fetchedUser.imageColorEntity,
                            specialId: fetchedUser.specialId,
                            idImage: fetchedUser.idImage??'',
                          );
                        },
                      );
                    }
                  },
                ),
                AdminsRoomPage(
                  isRoomManager: true,
                  ownerId: widget.roomData.ownerId.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
