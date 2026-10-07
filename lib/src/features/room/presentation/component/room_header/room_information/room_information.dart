import 'package:general/src/features/room/presentation/component/room_header/room_information/add_room_cover.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../../../core/index.dart';

class RoomInformation extends StatefulWidget {
  final EnterRoomModel? roomData;
  final String introRoom;
  final String roomImg;
  final String roomName;
  const RoomInformation({
    required this.roomName,
    required this.roomData,
    required this.introRoom,
    required this.roomImg,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CreatRoomScreenState();
}

class _CreatRoomScreenState extends State<RoomInformation> {
  late TextEditingController name, bio;

  @override
  void initState() {
    name = TextEditingController(
        text: widget.roomName == ""
            ? widget.roomData?.roomName
            : widget.roomName);
    bio = TextEditingController(
        text: widget.introRoom == ""
            ? widget.roomData?.roomIntro
            : widget.introRoom);
    name.addListener(() => setState(() {}));
    bio.addListener(() => setState(() {}));

    super.initState();
  }

  @override
  dispose() {
    name.dispose();
    bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: widget.roomData!.ownerId != MyDataModel.getInstance().id
            ? ScreenUtil().screenHeight * 0.60
            : ScreenUtil().screenHeight * 0.65,
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: ColorManager.offWhite,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          padding: context.paddingSymmetric(
            vertical: 20,
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.roomData!.ownerId == MyDataModel.getInstance().id)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (AddRoomCoverState.image != null) {
                          di<UpdateRoomBloc>().add(
                            UpdateRoomEvent(
                              ownerId:
                                  widget.roomData?.ownerId?.toString() ?? "",
                              roomId: widget.roomData?.id?.toString() ?? "",
                              roomName: name.text,
                              roomIntro: bio.text,
                              roomVideoType:
                                  widget.roomData?.streamType.toString() ?? "",
                              roomCover: AddRoomCoverState.image,
                            ),
                          );
                        } else {
                          di<UpdateRoomBloc>().add(
                            UpdateRoomEvent(
                              ownerId:
                                  widget.roomData?.ownerId?.toString() ?? "",
                              roomId: widget.roomData?.id?.toString() ?? "",
                              roomName: name.text,
                              roomIntro: bio.text,
                              roomVideoType:
                                  widget.roomData?.streamType.toString() ?? "",
                            ),
                          );
                        }
                        AddRoomCoverState.image = null;
                      },
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(20.r),
                        shadowColor: ColorManager.secondaryColor,
                        child: Container(
                          width: 70.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: Colors.black,
                          ),
                          child: Center(
                            child: TextWidget(
                              StringManager.save.tr(),
                              style: context.bodySmall.w400
                                  .colorExt(ColorManager.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              10.hBox,
              AddRoomCover(
                canEdit:
                    widget.roomData!.ownerId == MyDataModel.getInstance().id,
                img: widget.roomImg == ""
                    ? widget.roomData!.roomCover ?? ""
                    : widget.roomImg,
                imageQuality: 30,
              ),
              30.hBox,
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       StringManager.roomName.tr(),
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         fontSize: 14.sp,
              //         color: Colors.black,
              //       ),
              //     ),
              //     Image.asset(
              //       AssetsManager.editIcon,
              //       scale: 4,
              //       color: Colors.black,
              //     ),
              //   ],
              // ),
              // 5.hBox,
              TextInputWidget(
                title: StringManager.roomName.tr(),
                validator: (value) {
                  if (value == "") {
                    return StringManager.requiredField.tr();
                  } else {
                    return null;
                  }
                },
                StringManager.enterRoomName.tr(),
                controller: name,
                readOnly:
                    widget.roomData!.ownerId != MyDataModel.getInstance().id,
                textColor: Colors.black,
              ),
              20.hBox,
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       StringManager.roomIntro.tr(),
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         fontSize: 14.sp,
              //         color: Colors.black,
              //       ),
              //     ),
              //     Image.asset(
              //       AssetsManager.editIcon,
              //       scale: 4,
              //       color: Colors.black,
              //     ),
              //   ],
              // ),
              // 5.hBox,
              TextInputWidget(
                title: StringManager.roomDescription.tr(),
                validator: (value) {
                  if (value == "") {
                    return StringManager.requiredField.tr();
                  } else {
                    return null;
                  }
                },
                StringManager.enterRoomIntro.tr(),
                controller: bio,
                minLines: 6,
                maxLines: 10,
                readOnly:
                    widget.roomData!.ownerId != MyDataModel.getInstance().id,
                textColor: ColorManager.textPrimary,
                fillColor: ColorManager.surfaceCardColor,
              ),
              20.hBox,
              // Room Level Section
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.roomLevelScreen);
                },
                child: Container(
                  width: double.infinity,
                  padding: context.paddingAll(12),
                  decoration: BoxDecoration(
                    color: ColorManager.surfaceCardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ColorManager.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: ColorManager.green,
                            size: 24.sp,
                          ),
                          10.wBox,
                          TextWidget(
                            StringManager.roomLevel.tr(),
                            style: context.bodyMedium.w500
                                .size(14)
                                .colorExt(ColorManager.textPrimary),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
