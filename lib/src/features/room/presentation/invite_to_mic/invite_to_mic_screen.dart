import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../core/index.dart';

class SelectUserToMicDialog extends StatefulWidget {
  final int roomOwnerId;
  final String seatIndex;

  const SelectUserToMicDialog({
    super.key,
    required this.roomOwnerId,
    required this.seatIndex,
  });

  @override
  State<SelectUserToMicDialog> createState() => _SelectUserToMicDialogState();
}

class _SelectUserToMicDialogState extends State<SelectUserToMicDialog> {
  List<UTDParticipant> users_ = [];

  @override
  void initState() {
    super.initState();
    _initUsers();
  }

  void _initUsers() {
    final allUsers = RoomService.instance.getAllUsers();
    for (var user in allUsers) {
      if (!(RoomData.instance.utdController?.seatController
                  .isUserOnSeat(user.id) ??
              false) &&
          MyDataModel.getInstance().id.toString() != user.id) {
        users_.add(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.surfaceCardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      height: MediaQuery.sizeOf(context).height * 0.52,
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (users_.isEmpty)
              Expanded(
                child: Center(
                  child: ErrorOrEmptyWidget(
                    image: AssetsManager.empty,
                    title: StringManager.noDataYet.tr(),
                    message: '',
                  ),
                ),
              ),
            if (users_.isNotEmpty)
              Padding(
                padding: context.paddingOnly(start: 15, top: 15),
                child: TextWidget(
                  StringManager.inviteFriend.tr(),
                  style: context.bodyLarge.colorExt(ColorManager.black).bold,
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: users_.length,
                separatorBuilder: (context, index) => SizedBox(height: 5.h),
                itemBuilder: (context, index) {
                  final user = users_[index];
                  final userId = int.tryParse(user.id) ?? 0;
                  final cachedUser = UsersCache().getUser(userId);

                  if (cachedUser != null) {
                    return _UserRowBody(
                      seatIndex: widget.seatIndex,
                      userData: cachedUser,
                    );
                  } else {
                    return FutureBuilder<Map<int, UserInRoomModel>>(
                      future: getUsersByIds([userId]),
                      builder: (context, snapshot) {
                        final fetchedUser =
                            snapshot.data?[userId] ?? const UserInRoomModel();
                        return _UserRowBody(
                          seatIndex: widget.seatIndex,
                          userData: fetchedUser,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRowBody extends StatelessWidget {
  const _UserRowBody({
    required this.seatIndex,
    required this.userData,
  });

  final String seatIndex;
  final UserInRoomModel userData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: 12.0.radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10.w),
            UserImage(
              image: userData.image ?? "",
              boxFit: BoxFit.cover,
              imageSize: 40,
              displayName: userData.name ?? "",
            ),
            SizedBox(width: 15.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientTextVip(
                      text: userData.name ?? "",
                      width: 200.w,
                      textStyle: context.bodyMedium
                          .size(13)
                          .w700
                          .colorExt(ColorManager.textPrimary),
                      isVip: false,
                    ),
                    5.wBox,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: 20.radius,
                        color: userData.gender == 1
                            ? ColorManager.tapBarDivider
                            : ColorManager.pink.withValues(alpha: 0.4),
                      ),
                      child: Transform.rotate(
                        angle: 0.7,
                        child: Icon(
                          userData.gender == 1 ? Icons.male : Icons.female,
                          color: ColorManager.white,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    LevelContainer(
                      image: userData.senderLevelImage,
                      isComment: true,
                      height: 20.h,
                      width: 30.w,
                    ),
                    if (userData.senderLevelImage?.isNotEmpty == true) 5.wBox,
                    LevelContainer(
                      image: userData.receiverLevelImage,
                      isComment: true,
                      height: 20.h,
                      width: 30.w,
                    ),
                    if (userData.receiverLevelImage?.isNotEmpty == true) 5.wBox,
                    VipContainer(width: 30.w, vip: userData.vipImage),
                  ],
                ),
              ],
            ),
            const Spacer(),
            MainButton(
              title: StringManager.invite.tr(),
              onTap: () async {
                Navigator.pop(context);
                // Use package API to invite user to speak
                final controller = RoomData.instance.utdController;
                if (controller == null) return;
                try {
                  final result = await controller.inviteToSpeak(
                    userData.id.toString(),
                    seatIndex: int.tryParse(seatIndex),
                  );
                  if (result == null) {
                    final ctx = navKey.currentContext;
                    if (ctx != null && ctx.mounted) {
                      Methods.showToast(ctx,
                          message: 'Failed to send invitation', isError: true);
                    }
                  }
                } catch (e) {
                  final ctx = navKey.currentContext;
                  if (ctx != null && ctx.mounted) {
                    Methods.showToast(ctx,
                        message: e.toString(), isError: true);
                  }
                }
              },
              style: context.bodyMedium.colorExt(ColorManager.white).w400,
              width: 75.w,
              height: 25.h,
            ),
          ],
        ),
      ),
    );
  }
}
