part of '../create_room_page.dart';

class PickImageBody extends StatelessWidget {
  final String? image;
  const PickImageBody({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateRoomBloc, CreateRoomStates>(
      bloc: di<CreateRoomBloc>(),
      buildWhen: (prev, curr) => prev.image != curr.image,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => di<CreateRoomBloc>().add(
            PickRoomImage(state.image),
          ),
          child: state.image != null
              ? Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 100.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: ColorManager.white.withValues(alpha: (0.3)),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(
                            state.image ?? File(''),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -5.h,
                      right: 10,
                      child: CircleAvatar(
                        radius: 12.r,
                        backgroundColor: ColorManager.primary,
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 12.r,
                        ),
                      ),
                    )
                  ],
                )
              : image == null || image == ""
                  ? Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          maxRadius: 40,
                          backgroundImage: AssetImage(
                            AssetsManager.logo,
                          ),
                        ),
                        Positioned(
                          bottom: -6.h,
                          right: 8.w,
                          child: CircleAvatar(
                            radius: 12.r,
                            backgroundColor: ColorManager.primary,
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 12.r,
                            ),
                          ),
                        )
                      ],
                    )
                  : Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: [
                        ImageViewWidget(
                          height: 100.h,
                          width: 100.w,
                          url: image ?? "",
                          shape: BoxShape.circle,
                          boxFit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: -5.h,
                          right: 10,
                          child: CircleAvatar(
                            radius: 12.r,
                            backgroundColor: ColorManager.primary,
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 12.r,
                            ),
                          ),
                        )
                      ],
                    ),
        );
      },
    );
  }
}
