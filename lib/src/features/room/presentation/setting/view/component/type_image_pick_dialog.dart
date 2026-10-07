import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/setting/bloc/update_room_bloc.dart';

class TypeImagePickDialog extends StatelessWidget {
  const TypeImagePickDialog({super.key,required this.ownerId});

  final String ownerId;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 10.radius,
      ),
      padding: context.paddingSymmetric(horizontal: 30, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            StringManager.uploadCover,
            style: context.bodyLarge.bold.colorExt(ColorManager.textPrimary),
          ),
          20.hBox,
          ButtonWidget(
            onPressed: () {
              final navContext = SafeNavigator.context;
              if (navContext == null) return;
              di<UpdateRoomBloc>().add(PickImageEvent(
                  context: navContext,
                  source: ImageSource.camera, ownerId: ownerId));
              context.popRoute();
            },
            titleColor: ColorManager.white,
            backgroundColor: ColorManager.primary,
            height: 50.h,
            title: StringManager.takePhoto,
          ),
          15.hBox,
          ButtonWidget(
            onPressed: () {
              final navContext = SafeNavigator.context;
              if (navContext == null) return;
              di<UpdateRoomBloc>().add(PickImageEvent(
                  context: navContext,
                  source: ImageSource.gallery, ownerId: ownerId));
              context.popRoute();
            },
            titleColor: ColorManager.white,
            backgroundColor: ColorManager.primary,
            height: 50.h,
            title: StringManager.selectFromAlbum,
          ),
        ],
      ),
    );
  }

}
