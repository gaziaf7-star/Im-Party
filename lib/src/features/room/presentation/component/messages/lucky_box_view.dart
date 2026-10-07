import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/gifts/view/gift_room_page.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/dialog_lucky_box.dart';
import 'package:general/src/features/room/room.dart';

class LuckyBoxView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String name;
  final double fontSize;
  const LuckyBoxView({
    super.key,
    required this.data,
    required this.name,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bottomDailog(
          context: context,
          widget: DialogLuckyBox(
            coins: data['coins'] ?? "",
            luckyBoxId: data['id'] ?? "",
            ownerBoxName: data['name'] ?? "",
            typeLuckyBox: data['box_type'] == "super"
                ? TypeLuckyBox.superBox
                : TypeLuckyBox.normalBox,
            ownerImage: data['image'] ?? "",
            uid: data['uuid'] ?? "",
            usersNumber: int.parse(data['usersNumber'] ?? ""),
            giftButtonCallBack: () {
              bottomDailog(
                context: context,
                barrierColor: ColorManager.transparent,
                widget: GiftScreen(
                  users: RoomService.instance.getAllUsers(),
                  roomData: RoomData.instance.room,
                  myDataModel: MyDataModel.getInstance(),
                  isSingleUser: false,
                  isAudioRoom: true,
                  userId: null,
                  userImage: null,
                  userName: null,
                ),
              );
            },
            roomId: data['roomId'] ?? "",
            remTime: data['remTime'] ?? "",
          ),
        );
      },
      child: Container(
        padding: context.paddingOnly(
          top: Methods.getLang() == 'ar' ? 30.h : 20.h,
          bottom: Methods.getLang() == 'ar' ? 30.h : 20.h,
          end: 100.w,
          start: 20.w,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Methods.getLang() == 'ar'
                  ? AssetsManager.luckyBoxNum7
                  : AssetsManager.luckyBoxNum8,
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                // User-generated name: strip lone surrogates before the native
                // paragraph builder (addText not-well-formed-UTF-16 crash).
                text: name.sanitizedForDisplay,
                style: context.bodySmall
                    .size(fontSize - 3)
                    .colorExt(ColorManager.textPrimary),
              ),
              TextSpan(
                text: StringManager.sendALuckyBagWorht.tr(),
                style: context.bodySmall
                    .size(fontSize - 3)
                    .colorExt(ColorManager.textPrimary),
              ),
              TextSpan(
                text: data['coins'],
                style: context.bodySmall
                    .size(fontSize)
                    .colorExt(ColorManager.yellow3),
              ),
              TextSpan(
                text: StringManager.continueToTheRoom.tr(),
                style: context.bodySmall
                    .size(fontSize - 3)
                    .colorExt(ColorManager.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
