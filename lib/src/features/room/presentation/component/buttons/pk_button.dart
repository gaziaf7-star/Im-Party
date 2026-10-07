import 'package:general/src/features/room/presentation/manager/manager_pk/pk_bloc.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_events.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/core/index.dart';

class PkButton extends StatelessWidget {
  const PkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (RoomData.instance.room.mode != '3') {
          Methods.showToast(
            context,
            message: StringManager.cantOpenPk.tr(),
          );
        } else
          if (RoomData.instance.room.mode == '5') {
          Methods.showToast(
            context,
            message: StringManager.closeCinemaMode.tr(),
            isError: true,
          );
        } else if (RoomData.instance.isCharismaVisible.value) {
          Methods.showToast(
            context,
            message: StringManager.closeCharisma.tr(),
            isError: true,
          );
        } else if (PKWidget.isStartPK.value) {
          Methods.showToast(
            context,
            message: StringManager.cantClosePk.tr(),
          );
        } else {
          await showDialog(
            context: context,
            builder: (ctx) => AnimatedDialog(
              title: '${StringManager.openPk.tr()} ?',
              description: StringManager.areYouSureopenPk.tr(),
              onTapCancel: () {
                Navigator.of(context).pop();
              },
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => const LoadingWidget(color: ColorManager.white),
                );
                Navigator.pop(context);
                activePK();
                di<PKBloc>().add(ShowPKEvent(
                  roomId: RoomData.instance.room.id.toString(),
                ));
              },
            ),
          );


        }
      },
      child: Image.asset(
        AssetsManager.pkRoomNew,
        width: 36.w,
        height: 36.h,
        fit: BoxFit.cover,
      ),
    );
  }
}
