import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/services/dynamic_link_handler.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/room/data/model/enter_room_model.dart';

class RoomShareDialog extends StatelessWidget {
  const RoomShareDialog({
    super.key,
    required this.roomEntity,
  });
  final EnterRoomModel roomEntity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225.h,
      child: Padding(
        padding: context.paddingAll(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              StringManager.share.tr(),
              style: context.bodyMedium.bold
                  .size(20)
                  .colorExt(ColorManager.black),
            ),
            20.hBox,
            InkWell(
              onTap: () {
                if (di<SearchBloc>().state.reqState == RequestState.loaded) {
                  di<SearchBloc>().add(
                    const SearchEvent(
                      isFriend: true,
                      page: '1',
                      keyWord: ' ',
                      loading: false,
                    ),
                  );
                } else {
                  di<SearchBloc>().add(
                    const SearchEvent(
                      isFriend: true,
                      page: '1',
                      keyWord: ' ',
                    ),
                  );
                }

                Navigator.pushNamed(
                  context,
                  Routes.shareRoomScreenInternal,
                  arguments: roomEntity,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: 5.radius,
                  border: Border.all(
                    color: ColorManager.grey.withValues(alpha: 0.1),
                    width: 1.h,
                  ),
                ),
                child: Padding(
                  padding: context.paddingAll(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 45.h,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.person_2_alt,
                            color: ColorManager.primary,
                          ),
                        ),
                      ),
                      20.wBox,
                      Text(
                        StringManager.friends.tr(),
                        style: context.bodyMedium.colorExt(ColorManager.black),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: ColorManager.grey,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            15.hBox,
            InkWell(
              onTap: () async => await shareRoomLink(context, roomEntity),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: 5.radius,
                  border: Border.all(
                    color: ColorManager.grey.withValues(alpha: 0.1),
                    width: 1.h,
                  ),
                ),
                child: Padding(
                  padding: context.paddingAll(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 45.h,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.share,
                            color: ColorManager.primary,
                          ),
                        ),
                      ),
                      20.wBox,
                      Text(
                        StringManager.more.tr(),
                        style: context.bodyMedium.colorExt(ColorManager.black),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: ColorManager.grey,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> shareRoomLink(
  BuildContext context,
  EnterRoomModel room,
) async {
  try {
    final Map<String, dynamic> map_ = {
      'type': 'room',
      'id': room.id.toString(),
      'description': room.roomIntro ?? room.roomName,
      'url': room.roomCover,
      'path': 'room',
      'user': {
        'id': room.ownerId,
        'name': room.ownerName,
        'profileUrl': room.ownerImage,
      },
    };

    final String dynamicLink =
        await DynamicLinkHandler.instance.createProductLink(map_, 'room');

    await SharePlus.instance.share(
      ShareParams(
        uri: Uri.parse(dynamicLink),
        subject: StringManager.amazingRoom.tr(),
      ),
    );
  } catch (error) {
    Methods.showToast(
      context,
      message: StringManager.unableToShare.tr(),
      isError: true,
    );
  }
}
