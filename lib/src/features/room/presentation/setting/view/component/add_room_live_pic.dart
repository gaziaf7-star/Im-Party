part of '../setting_page.dart';

class _AddRoomLivePic extends StatelessWidget {
  const _AddRoomLivePic({required this.roomCover, required this.ownerId});

  final String? roomCover;
  final String? ownerId;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateRoomBloc, UpdateRoomStates>(
        bloc: di<UpdateRoomBloc>(),
        buildWhen: (prev, curr) => prev.imagePath != curr.imagePath,
        builder: (context, state) {
          return (state.imagePath.isNotEmpty)
              ? InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: TypeImagePickDialog(
                          ownerId: ownerId ?? '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 55.w,
                    height: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: 4.radius,
                      image: DecorationImage(
                        image: FileImage(
                          File(state.imagePath),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: TypeImagePickDialog(
                          ownerId: ownerId ?? '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 55.w,
                    height: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: 4.radius,
                    ),
                    child: ImageViewWidget(
                      width: 100.w,
                      height: 100.h,
                      radius: 0.r,
                      boxFit: BoxFit.cover,
                      url: roomCover ?? "",
                    ),
                  ),
                );
        });
  }
}
