part of '../manger_family_page.dart';

class _PickImageBody extends StatelessWidget {
  const _PickImageBody({required this.managerFamilyBloc, this.path});

  final ManagerFamilyBloc managerFamilyBloc;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagerFamilyBloc, ManagerFamilyStates>(
      bloc: di<ManagerFamilyBloc>(),
      buildWhen: (prev, curr) => prev.pathImage != curr.pathImage,
      builder: (context, state) {
        return Align(
          alignment: AlignmentDirectional.topCenter,
          child: InkWell(
            onTap: () => managerFamilyBloc.add(const PickImageEvent()),
            borderRadius: 50.radius,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: 50.radius,
                  child: SizedBox(
                    child: managerFamilyBloc.state.pathImage.isEmpty &&
                            path == null
                        ? Container(
                            padding: context.paddingAll(25),
                            decoration: BoxDecoration(
                                borderRadius: 5.radius,
                                color: ColorManager.black
                                    .withValues(alpha: (0.3))),
                            child: Image.asset(
                              AssetsManager.familyCamera,
                              scale: 4,
                            ),
                          )
                        : path == null ||
                                managerFamilyBloc.state.pathImage.isNotEmpty
                            ? managerFamilyBloc.state.pathImage.isEmpty
                                ? null
                                : Container(
                                    width: 100.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      borderRadius: 100.radius,
                                      image: DecorationImage(
                                        image: FileImage(File(
                                            managerFamilyBloc.state.pathImage)),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                            : ImageViewWidget(
                                url: path ?? "",
                                boxFit: BoxFit.fill,
                                width: 100.w,
                                height: 100.h,
                                radius: 100.r,
                              ),
                  ),
                ),
                if (!(managerFamilyBloc.state.pathImage.isEmpty &&
                    path == null))
                  Positioned(
                    bottom: -5.h,
                    right: -1.w,
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
          ),
        );
      },
    );
  }
}

// class _PickImageBody extends StatelessWidget {
//   const _PickImageBody({required this.managerFamilyBloc, this.path});
//
//   final ManagerFamilyBloc managerFamilyBloc;
//   final String? path;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ManagerFamilyBloc, ManagerFamilyStates>(
//       builder: (context, state) {
//         return Align(
//           alignment: AlignmentDirectional.topCenter,
//           child: InkWell(
//             onTap: () => managerFamilyBloc.add(const PickImageEvent()),
//             child: Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.bottomRight,
//               children: [
//                 SizedBox(
//                     child: Container(
//                   height: 100.h,
//                   width: 100.w,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: ColorManager.white, width: 2),
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       image: FileImage(File(managerFamilyBloc.state.pathImage)),
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                   child: managerFamilyBloc.state.pathImage.isEmpty
//                       ? ImageViewWidget(
//                           url: path ?? "",
//                           boxFit: BoxFit.fill,
//                           radius: 50.r,
//                         )
//                       : const SizedBox(),
//                 )),
//                 Positioned(
//                   bottom: -5.h,
//                   right: 5.w,
//                   child: CircleAvatar(
//                     radius: 12.r,
//                     backgroundColor: ColorManager.primary,
//                     child: Icon(
//                       Icons.camera_alt_rounded,
//                       size: 12.r,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
