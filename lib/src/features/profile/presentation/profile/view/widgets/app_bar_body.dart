import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

import '../../../../../../core/index.dart';
import 'f_f_f_body.dart';

class AppBarBody extends StatelessWidget {
  const AppBarBody({super.key, required this.data});

  final MyDataEntity data;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: ColorManager.transparent,
      expandedHeight: 280.h,
      actions: _actions(context),
      flexibleSpace: _flexSpace(context),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      // IconButton(
      //   onPressed: () {
      //     Methods().userProfileNavigator(
      //       context: context,
      //       userId: MyDataModel.getInstance()
      //           .convertMyDataEntityToUserEntity(data)
      //           .id
      //           .toString(),
      //       user_:
      //           MyDataModel.getInstance().convertMyDataEntityToUserEntity(data),
      //     );
      //   },
      //   // icon: ImageWidget(
      //   //   image: AssetsManager.eyeProfile,
      //   //   height: 20.5.h,
      //   //   width: 20.5.w,
      //   //   color: ColorManager.white,
      //   // ),
      // ),
      // IconButton(
      //   onPressed: () {},
      //   icon: ImageWidget(
      //     image: AssetsManager.dots,
      //     height: 20.5.h,
      //     width: 20.5.w,
      //   ),
      // ),
    ];
  }

  Widget _flexSpace(BuildContext context) {
    return FlexibleSpaceBar(
      background: Padding(
        padding: context.paddingOnly(top: 70.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ImageViewWidget(
                    height: 90,
                    width: 90,
                    border: Border.all(
                      color: ColorManager.white,
                      width: 2,
                    ),
                    url: data.profile?.image ?? '',
                    displayName: data.name ?? '',
                    shape: BoxShape.circle,
                  ),

                  // Positioned(
                  //   bottom: -10.h,
                  //   right: -5.w,
                  //   child: IconButton(
                  //     onPressed: () => Navigator.pushNamed(
                  //       context,
                  //       Routes.editProfile,
                  //       arguments: data,
                  //     ),
                  //     icon: ImageWidget(
                  //       image: AssetsManager.editProfile,
                  //       height: 20.5.h,
                  //       width: 20.5.w,
                  //     ),
                  //     //  CircleAvatar(
                  //     //   radius: 10.25.r,
                  //     //   backgroundColor: ColorManager.scaffoldBg,
                  //     //   child: CircleAvatar(
                  //     //     radius: 10.15.r,
                  //     //     backgroundColor: ColorManager.scaffoldBg,
                  //     //     child: ImageWidget(
                  //     //       image: AssetsManager.editProfile,
                  //     //       height: 10.h,
                  //     //       width: 10.w,
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //   ),
                  // ),
                ],
              ),
            ),
            10.hBox,
            GradientTextVip(
              isVip: false,
              text: '${data.name}',
              mainAxisAlignment: MainAxisAlignment.center,
              textAlign: TextAlign.center,
              textStyle: context.bodyMedium.w600
                  .size(14)
                  .colorExt(ColorManager.textPrimary),
            ),
            0.65.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  "ID: ${data.uuid}",
                  style: context.bodyMedium.w400
                      .size(10.5)
                      .colorExt(ColorManager.textPrimary),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '${data.uuid}'));
                    Methods.showToast(
                      context,
                      message: StringManager.theTextHasBeenCopied.tr(),
                    );
                  },
                  child: Padding(
                    padding: context.paddingAll(10.dm),
                    child: ImageWidget(
                      image: AssetsManager.copyId,
                      color: ColorManager.white,
                      height: 10.h,
                      width: 10.w,
                    ),
                  ),
                ),
              ],
            ),
            20.h.hBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: SizedBox(
                width: 270.w,
                child: FFLFBody(
                  isMyProfile: true,
                  horizontalP: 0.w,
                  dividerColor: ColorManager.white,
                  data: MyDataModel.getInstance()
                      .convertMyDataEntityToUserEntity(data),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
