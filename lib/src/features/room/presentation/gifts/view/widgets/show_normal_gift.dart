import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

class ShowNormalGift extends StatelessWidget {
  final GiftState state;
  const ShowNormalGift({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      di<GiftBloc>().add(
        const ShowGiftsEvent(
          pathGift: '',
          isShowGift: false,
          giftType: ShowGiftType.image,
        ),
      );
      if (GiftController().normalGiftsToShow.isNotEmpty) {
        GiftController().normalGiftsToShow.removeAt(0);

        if (GiftController().normalGiftsToShow.isEmpty) {
          di<GiftBloc>().add(const ShowGiftsEvent(
            pathGift: "",
            isShowGift: false,
            giftType: ShowGiftType.image,
          ));
        } else {
          final gift = GiftController().normalGiftsToShow[0];
          _showNextGift(gift);
        }
      }
    });
    return state.isFamousGift == true
        ? ValueListenableBuilder<bool>(
            valueListenable: RoomData.instance.minimizeGiftFamous,
            builder: (context, isMinimize, child) {
              return Stack(
                children: [
                  CacheImageWidget(
                    url: EndPoints.getImage(state.gift),
                    height: isMinimize
                        ? (ScreenUtil().screenWidth / 1.15).h
                        : ScreenUtil().screenHeight,
                    width: isMinimize
                        ? (ScreenUtil().screenWidth / 1.15).w
                        : ScreenUtil().screenWidth,
                    isGift: true,
                    isFromRoom: true,
                  ),
                  Positioned(
                    top: 50.h,
                    right: 20.h,
                    child: InkWell(
                      onTap: () async {
                        bool newValue =
                            !RoomData.instance.minimizeGiftFamous.value;
                        await HiveManager().saveData<bool>(
                          KeysManager.ROOMS_BOX,
                          KeysManager.MINIMIZE_GIFT_KEY,
                          newValue,
                        );
                        RoomData.instance.minimizeGiftFamous.value = newValue;
                      },
                      child: Icon(
                        isMinimize
                            ? CupertinoIcons.fullscreen
                            : CupertinoIcons.fullscreen_exit,
                        color: Colors.white,
                        size: 30.h,
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        : CacheImageWidget(
            url: EndPoints.getImage(state.gift),
            isGift: true,
            isFromRoom: true,
          );
  }
}

void _showNextGift(Map<String, dynamic> gift) {
  final type = gift['giftType'];
  final path = gift['pathGift'];
  final isFamous = gift['isFamousGift'];
  final wappelImage = gift['wappel']['wappelImage'] ?? '';

  Future.delayed(
    Duration(milliseconds: type == 'svga' ? 650 : 100),
    () {
      if (type == 'alpha') {
        di<AlphaGiftManagerBloc>().add(
          ShowAlphaGift(imgFile: path, isFamousGift: isFamous),
        );
      } else {
        di<GiftBloc>().add(
          ShowGiftsEvent(
            isShowGift: true,
            pathGift: path,
            isFamousGift: isFamous,
            giftType: _mapGiftType(type),
          ),
        );
      }

      if (wappelImage.isNotEmpty) {
        ShowEntroWidget.showEntro.value = gift['wappel'];
      }
    },
  );
}

ShowGiftType _mapGiftType(String type) {
  switch (type) {
    case 'alpha':
      return ShowGiftType.alpha;
    case 'vap':
      return ShowGiftType.vap;
    case 'mp4':
      return ShowGiftType.mp4;
    default:
      return ShowGiftType.svga;
  }
}
