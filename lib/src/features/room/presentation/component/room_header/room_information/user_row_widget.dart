import 'package:flutter/cupertino.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/male_female_icon.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';
import 'package:general/src/features/room/room.dart';

import '../../../../../../core/index.dart';
import '../../../../../../core/utils/text_sanitizer.dart';
import '../../profile/component/utd_role_helper.dart';

class UserRowWidget extends StatelessWidget {
  final bool isAdmin;
  final String image;
  final String id;
  final String frame;
  final String frameType;
  final String name;
  final String vip;
  final String senderImage;
  final String receiverImage;
  final int gender;
  final int age;
  final String uuid;
  final String idImage;
  final String ownerId;
  final num? specialId;
  final Color coloredName;
  final ImageColorEntity? imageColorEntity;
  final Widget? actionButton;
  final bool? canClick;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const UserRowWidget({
    super.key,
    required this.isAdmin,
    required this.image,
    required this.id,
    required this.frame,
    required this.frameType,
    required this.name,
    required this.vip,
    required this.senderImage,
    required this.receiverImage,
    required this.gender,
    required this.age,
    required this.uuid,
    required this.ownerId,
    required this.coloredName,
    this.actionButton,
    this.canClick,
    this.padding,
    this.textStyle,
    required this.imageColorEntity,
    required this.idImage,
    required this.specialId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? context.paddingSymmetric(vertical: 13, horizontal: 5),
      decoration: BoxDecoration(
        color: ColorManager.transparent,
        borderRadius: 10.radius,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (id != '-1' && (canClick ?? true)) {
                Methods().userProfileNavigator(
                  context: context,
                  userId: id,
                  comesFromRoom: true,
                );
              }
            },
            child: UserImage(
              image: image,
              uniquId: id,
              displayName: name,
              imageSize: 50.sp,
              frame: frame,
              frameType: frameType,
              frameSize: 70.sp,
            ),
          ),
          10.wBox,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (id != '-1' && (canClick ?? true)) {
                        Methods().userProfileNavigator(
                          context: context,
                          userId: id,
                        );
                      }
                    },
                    child: GradientTextVip(
                      width: 150.w,
                      isVip: coloredName != ColorManager.black,
                      text: name.sanitizedForDisplay,
                      color: coloredName,
                      mainAxisAlignment: MainAxisAlignment.start,
                      textAlign: TextAlign.center,
                      textStyle: textStyle ??
                          context.bodyMedium.bold
                              .size(13)
                              .colorExt(coloredName),
                    ),
                  ),
                  5.wBox,
                  if (age != 0)
                    MaleFemaleIcon(
                      maleOrFeamle: gender,
                      age: age,
                    ),
                ],
              ),
              5.hBox,
              Row(
                children: [
                  IdWithCopyIcon(
                    userId: uuid,
                    isNeedCopyIcon: false,
                    isSpecial: ((specialId ?? '') != ''),
                    specialImg: idImage,
                    color: imageColorEntity?.color,
                    img: imageColorEntity?.image,
                    mainAxisAlignment: MainAxisAlignment.start,
                    idColor: ColorManager.black.withValues(alpha: (0.5)),
                    idStyle: context.bodyMedium
                        .size(11)
                        .w500
                        .colorExt(Colors.black.withValues(alpha: (0.5))),
                  ),
                  5.wBox,
                  if (vip != "")
                    VipContainer(
                      vip: vip,
                      width: 30.w,
                      height: 18.h,
                    ),
                  5.wBox,
                  LevelContainer(
                    width: 35.w,
                    height: 15.h,
                    image: senderImage,
                  ),
                  5.wBox,
                  LevelContainer(
                    width: 35.w,
                    height: 15.h,
                    image: receiverImage,
                  ),
                ],
              ),
            ],
          ),
          if (isAdmin == true) ...[
            if ((RoomData.instance.room.ownerId ==
                    MyDataModel.getInstance().id) &&
                (id != ownerId))
              const Spacer(),
            // Owner-only: edit this admin's granular permissions.
            if ((RoomData.instance.room.ownerId ==
                    MyDataModel.getInstance().id) &&
                (id != ownerId) &&
                RoomData.instance.adminsInRoom.containsKey(id))
              IconButton(
                onPressed: () => editAdminPermissions(id, name),
                icon: Icon(
                  Icons.settings_outlined,
                  color: ColorManager.iconColor,
                  size: 22.sp,
                ),
              ),
            if ((RoomData.instance.room.ownerId ==
                    MyDataModel.getInstance().id) &&
                (id != ownerId) &&
                RoomData.instance.adminsInRoom.containsKey(id))
              IconButton(
                onPressed: () async {
                  // Optimistic removal for instant feedback, then demote via
                  // the engine and reconcile the list.
                  di<AdminRoomBloc>().add(RemoveAdminsLocallyEvent(userId: id));
                  await demoteToAudienceById(id, name);
                  di<AdminRoomBloc>().add(
                    GetAdminsEvent(
                      ownerId: ownerId,
                      roomId: RoomData.instance.room.id.toString(),
                      isLoading: false,
                    ),
                  );
                },
                icon: const Icon(
                  CupertinoIcons.delete,
                  color: ColorManager.redAccount,
                ),
              ),
          ],
          if (actionButton != null) const Spacer(),
          actionButton ?? const SizedBox(),
        ],
      ),
    );
  }
}
