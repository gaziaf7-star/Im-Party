// ignore_for_file: must_be_immutable
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/room/room.dart';

class HostTopCenterWidget extends StatelessWidget {
  UserModel? userEntity;
  EnterRoomModel? room;
  HostTopCenterWidget({
    super.key,
    this.userEntity,
    this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 85.h,
        right: 320.w,
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: 90.w,
              // child: Image(
              //   image: AssetImage(AssetsManager.topInRoom),
              // ),
            ),
            if (userEntity?.id != null)
              Stack(
                alignment: Alignment.center,
                children: [
                  UserImage(
                    image: userEntity?.profile?.image ?? "",
                    displayName: userEntity?.name ?? "",
                    imageSize: 50.sp,
                  ),
                  if (userEntity?.frame != "")
                    Positioned(
                      child: SizedBox(
                        width: 70.w,
                        height: 70.h,
                        child: Methods().isSvgaFile(userEntity?.frame ?? '')
                            ? CacheSvgaWidget(
                                url: userEntity?.frame ?? '',
                                height: 70.h,
                              )
                            : ImageViewWidget(
                                url: userEntity?.frame ?? '',
                                height: 70.h,
                              ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
