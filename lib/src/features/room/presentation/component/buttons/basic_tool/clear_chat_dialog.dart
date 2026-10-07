import 'dart:convert';
import 'package:general/src/features/room/room.dart';
import '../../../../../../core/index.dart';

Future<void> showClearChatDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: 20.radius,
        ),
        child: Container(
          padding: context.paddingAll(5),
          height: 220.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringManager.cleanchat.tr(),
                style: context.bodyMedium.size(24),
              ),
              20.hBox,
              Text(
                StringManager.cleanchatSubtitle.tr(),
              ),
              20.hBox,
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MainButton(
                    title: StringManager.cancel.tr(),
                    width: 80.w,
                    height: 40.w,
                    padding: context.paddingAll(5),
                    buttonColor: ColorManager.black,
                    titleColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  MainButton(
                    title: StringManager.confirm.tr(),
                    width: 80.w,
                    height: 40.w,
                    padding: context.paddingAll(5),
                    buttonColor: ColorManager.white,
                    borderColor: ColorManager.pink,
                    titleColor: ColorManager.pink,
                    onTap: () {
                      RoomData.instance.chatController?.clearMessages();
                      var mapInformation = {
                        "messageContent": {
                          "message": "removeChat",
                        }
                      };
                      String map = jsonEncode(mapInformation);
                      sendRoomData(data: jsonDecode(map));
                      SafeNavigator.pop();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
