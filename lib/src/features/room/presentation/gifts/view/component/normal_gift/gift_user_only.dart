import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GiftUserOnly extends StatefulWidget {
  final String userId;
  final String ownerId;
  final String userImage;
  final String userName;
  final Color selectedBorderColor;

  const GiftUserOnly({
    required this.userId,
    required this.userImage,
    required this.userName,
    required this.ownerId,
    required this.selectedBorderColor,
    super.key,
  });

  static String userSelected = "";

  @override
  GiftUserOnlyState createState() => GiftUserOnlyState();
}

class GiftUserOnlyState extends State<GiftUserOnly> {
  int selectUserIndex = 0;

  @override
  void initState() {
    GiftUser.userSelected.value.clear();
    GiftUserOnly.userSelected = widget.userId;
    GiftUser.userSelected.value.putIfAbsent(
      0,
      () => SelectedObject(
        userId: widget.userId,
        selected: true,
        name: widget.userName,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.only(top: 10.h),
        height: 70.h,
        width: MediaQuery.of(context).size.width - 50,
        child: ValueListenableBuilder<Map<int, SelectedObject>>(
          valueListenable: GiftUser.userSelected,
          builder: (context, count, _) {
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(3),
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: GiftUser.userSelected.value.containsKey(index)
                              ? widget.selectedBorderColor
                              : ColorManager.transparent,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: ImageViewWidget(
                          boxFit: BoxFit.cover,
                          url: widget.userImage,
                          displayName: widget.userName,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30.h,
                      left: 13.w,
                      child: Container(
                        width: 20.w,
                        height: 15.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorManager.white,
                        ),
                        child: Center(
                          child: Text(
                            "${(RoomData.instance.utdController?.seatController.getSeatIndexByUserId(widget.userId) ?? -1) + 1}",
                            style: context.bodySmall.size(7),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
