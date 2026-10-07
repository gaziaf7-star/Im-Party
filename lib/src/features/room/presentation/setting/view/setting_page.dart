import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/room/presentation/component/buttons/basic_tool/un_lock_room.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_activity/room_activity_screen.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_information/user_row_widget.dart';
import 'package:general/src/features/room/presentation/setting/view/component/type_image_pick_dialog.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/setting/data/model/get_vip_prev.dart';

part '../../admins_in_room/view/admins_room_page.dart';

part 'component/add_room_live_pic.dart';

part 'component/edit_name_intro_screen.dart';

part 'component/hide_room_widget.dart';

part 'widgets/row_builder_widget.dart';

class SettingScreen extends StatelessWidget {
  final EnterRoomModel roomData;

  const SettingScreen({super.key, required this.roomData});

  bool get _isOwner => roomData.ownerId == MyDataModel.getInstance().id;

  bool get _isOwnerOrAdmin =>
      _isOwner ||
          RoomData.instance.adminsInRoom
              .containsKey(MyDataModel.getInstance().id.toString());

  // Fixed light-grey hairline, regardless of admin theme -- this page is
  // always white now, so a mutable dark scaffoldBgAlt divider would vanish
  // or turn into a heavy dark bar depending on the admin panel's setting.
  Widget _divider() =>
      Container(height: 10.h, color: ColorManager.grey2.withValues(alpha: 0.12));

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromView(View.of(context)),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: ColorManager.white,
          appBar: AppBarWidget(
            title: StringManager.roomInformation.tr(),
            backgroundColor: ColorManager.white,
            iconColor: ColorManager.black,
            titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
          ),
          body: Column(
            children: [
              Container(
                // A Container can't take both `color` and `decoration` --
                // Flutter throws "Cannot provide both a color and a
                // decoration" (this crashed the whole page on open). The
                // white fill now lives inside the same BoxDecoration as the
                // bottom border instead of as a separate `color:` arg.
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  border: Border(
                    bottom: BorderSide(
                      color: ColorManager.grey2.withValues(alpha: 0.2),
                      width: 0.6,
                    ),
                  ),
                ),
                child: TabBar(
                  labelColor: ColorManager.black,
                  unselectedLabelColor: ColorManager.black.withValues(alpha: 0.45),
                  indicatorColor: ColorManager.primary,
                  indicatorWeight: 2.5,
                  labelStyle: context.bodyMedium.w700,
                  tabs: [
                    Tab(text: StringManager.room.tr()),
                    Tab(text: StringManager.owner.tr()),
                    Tab(text: StringManager.adminsTool.tr()),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _roomTab(context),
                    _ownerTab(context),
                    AdminsRoomPage(
                      ownerId: roomData.ownerId.toString(),
                      isRoomManager: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Room tab ─────────────────────────
  // Password / Background(theme) / Manager / Charisma were REMOVED here — they
  // live in the room Tools sheet now. Keeps: portrait, id, name, notice,
  // activity, level.
  Widget _roomTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _divider(),
          RowBuilderWidget(
            title: StringManager.roomPortrait.tr(),
            onTap: () {},
            lastWidget: Row(
              children: [
                _isOwner
                    ? ValueListenableBuilder(
                    valueListenable: OwnerOfRoom.isEditRoom,
                    builder: (context, editValue, _) {
                      return _AddRoomLivePic(
                        roomCover:
                        RoomData.instance.roomDataUpdates['room_img'] ==
                            ''
                            ? roomData.roomCover ?? ""
                            : RoomData.instance
                            .roomDataUpdates['room_img'] ??
                            "",
                        ownerId: roomData.ownerId.toString(),
                      );
                    })
                    : ValueListenableBuilder(
                    valueListenable: OwnerOfRoom.isEditRoom,
                    builder: (context, editValue, _) {
                      return ImageViewWidget(
                        width: 55.w,
                        height: 55.h,
                        radius: 0.r,
                        boxFit: BoxFit.cover,
                        url: RoomData.instance
                            .roomDataUpdates['room_img'] ==
                            ''
                            ? roomData.roomCover ?? ""
                            : RoomData.instance
                            .roomDataUpdates['room_img'] ??
                            "",
                      );
                    }),
                5.wBox,
                if (_isOwner)
                  Icon(Icons.arrow_forward_ios,
                      color: ColorManager.grey, size: 14.h),
              ],
            ),
          ),
          _divider(),
          RowBuilderWidget(
            title: StringManager.roomId.tr(),
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: roomData.uuidOwnerRoom.toString()));
              Methods.showToast(context,
                  message: StringManager.theTextHasBeenCopied.tr());
            },
            lastWidget: IdWithCopyIcon(
              isNeedCopyIcon: true,
              isSpecial: (roomData.ownerSpecialId != null &&
                  (roomData.ownerSpecialId ?? '') != ''),
              specialImg: roomData.ownerSpecialId ?? '',
              color: roomData.ownerImageColor?.color,
              img: roomData.ownerImageColor?.image,
              idStyle: context.bodyMedium.w400
                  .colorExt(ColorManager.greyColor)
                  .copyWith(height: 0.1, fontSize: 11.sp),
              userId: roomData.uuidOwnerRoom ?? '',
            ),
          ),
          _divider(),
          RowBuilderWidget(
            title: StringManager.roomName.tr(),
            onTap: () {
              if (_isOwner) {
                bottomDailog(
                  context: context,
                  widget: EditNameIntroScreen(
                      room: roomData, title: StringManager.roomName.tr()),
                );
              }
            },
            lastWidget: Row(
              children: [
                ValueListenableBuilder(
                    valueListenable: OwnerOfRoom.isEditRoom,
                    builder: (context, editValue, _) {
                      return SizedBox(
                        width: 250.w,
                        child: Text(
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          RoomData.instance.roomDataUpdates['room_name'] == ''
                              ? roomData.roomName ?? ""
                              : RoomData.instance
                              .roomDataUpdates['room_name'] ??
                              '',
                          style: context.bodyMedium
                              .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                        ),
                      );
                    }),
                5.wBox,
                if (_isOwner)
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: ColorManager.grey, size: 14.h),
              ],
            ),
          ),
          if (_isOwner) ...[
            _divider(),
            RowBuilderWidget(
              title: StringManager.roomNotice.tr(),
              onTap: () {
                bottomDailog(
                  context: context,
                  widget: EditNameIntroScreen(
                      room: roomData, title: StringManager.roomNotice.tr()),
                );
              },
              lastWidget: Row(
                children: [
                  SizedBox(
                    width: 100.w,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      roomData.roomIntro ?? "",
                      textAlign: TextAlign.end,
                      style: context.bodySmall.w700
                          .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                    ),
                  ),
                  5.wBox,
                  Icon(Icons.arrow_forward_ios,
                      color: ColorManager.grey, size: 14.h),
                ],
              ),
            ),
          ],
          if (ConstantsManager.isShowRoomActivity && _isOwnerOrAdmin) ...[
            _divider(),
            RowBuilderWidget(
              title: StringManager.roomActivity.tr(),
              onTap: () {
                bottomDailog(
                  context: context,
                  widget: MediaQuery(
                    data: MediaQueryData.fromView(View.of(context)),
                    child: const RoomActivityScreen(),
                  ),
                );
              },
              lastWidget: Icon(Icons.arrow_forward_ios_rounded,
                  color: ColorManager.grey, size: 14.h),
            ),
          ],
          if (_isOwnerOrAdmin) ...[
            _divider(),
            RowBuilderWidget(
              title: StringManager.roomLevel.tr(),
              onTap: () {
                Navigator.pushNamed(context, Routes.roomLevelScreen);
              },
              lastWidget: Icon(Icons.arrow_forward_ios_rounded,
                  color: ColorManager.grey, size: 14.h),
            ),
          ],
          20.hBox,
        ],
      ),
    );
  }

  // ───────────────────────── Owner tab ─────────────────────────
  Widget _ownerTab(BuildContext context) {
    return SingleChildScrollView(
      padding: context.paddingSymmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserImage(
            image: roomData.ownerImage ?? '',
            displayName: roomData.ownerName ?? '',
            imageSize: 90,
          ),
          14.hBox,
          TextWidget(
            roomData.ownerName ?? '',
            style: context.bodyLarge.w700.colorExt(ColorManager.black),
          ),
          10.hBox,
          IdWithCopyIcon(
            isNeedCopyIcon: true,
            isSpecial: (roomData.ownerSpecialId != null &&
                (roomData.ownerSpecialId ?? '') != ''),
            specialImg: roomData.ownerSpecialId ?? '',
            color: roomData.ownerImageColor?.color,
            img: roomData.ownerImageColor?.image,
            idStyle: context.bodyMedium.w400
                .colorExt(ColorManager.greyColor)
                .copyWith(fontSize: 12.sp),
            userId: roomData.uuidOwnerRoom ?? '',
          ),
          20.hBox,
          GestureDetector(
            onTap: () {
              final id = roomData.ownerId;
              if (id == null || id == 0) return;
              Methods().userProfileNavigator(
                context: context,
                userId: id.toString(),
              );
            },
            child: Container(
              width: double.infinity,
              padding: context.paddingAll(14),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: ColorManager.grey2.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    StringManager.profile.tr(),
                    style: context.bodyMedium.w500.colorExt(ColorManager.black),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 14.h, color: ColorManager.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}