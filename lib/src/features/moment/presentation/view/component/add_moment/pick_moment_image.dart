part of 'package:general/src/features/moment/presentation/view/component/add_moment/add_moment_screen.dart';

class _PickMomentImageBody extends StatelessWidget {
  const _PickMomentImageBody({required this.moment});
  final String moment;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentBloc, MomentStates>(
      bloc: di<MomentBloc>(),
      buildWhen: (prev, curr) => prev.multiImages != curr.multiImages,
      builder: (context, state) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return index == state.multiImages.length
                ? GestureDetector(
                    onTap: () {
                      di<MomentBloc>().add(const PickMultiPicEvent());
                    },
                    child: Container(
                      width: 80.0.w,
                      height: 80.0.w,
                      margin: context.paddingSymmetric(
                          vertical: 15, horizontal: 10),
                      color: ColorManager.transparent,
                      child: Icon(
                        Icons.add,
                        size: 30,
                        color: ColorManager.grey.withValues(alpha: (0.45 )),
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80.0.w,
                        height: 80.0.w,
                        alignment: Alignment.topRight,
                        margin: context.paddingOnly(start: 10.w),
                        padding: context.paddingSymmetric(
                            horizontal: 5.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          borderRadius: 10.radius,
                          image: DecorationImage(
                            image: FileImage(
                              File(state.multiImages[index].path),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            di<MomentBloc>().add(RemoveMultiPickedImageEvent(
                              moment: moment,
                                element: index));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorManager.black.withValues(alpha: (0.6 )),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                                size: 20.h,
                                color: ColorManager.white,
                                Icons.clear),
                          ),
                        ),
                      ),
                    ],
                  );
          },
          itemCount:
              state.multiImages.isNotEmpty ? state.multiImages.length + 1 : 1,
        );
      },
    );

    // InkWell(
    //   onTap: () => di<MomentBloc>().add(
    //     PickImageMomentEvent(image: state.image),
    //   ),
    //   child: Container(
    //     height: 120.h,
    //     width: 120.w,
    //     decoration: BoxDecoration(
    //       borderRadius: 20.radius,
    //       color: ColorManager.lightGrey,
    //       image: state.image != null
    //           ? DecorationImage(
    //               fit: BoxFit.cover,
    //               image: FileImage(
    //                 state.image ?? File(''),
    //               ),
    //             )
    //           : null,
    //     ),
    //     child: state.image != null
    //         ? null
    //         : Image.asset(
    //             AssetsManager.addImageIcon,
    //             fit: BoxFit.none,
    //             scale: 2.5,
    //             color: ColorManager.black,
    //           ),
    //   ),
    // );
  }
}
