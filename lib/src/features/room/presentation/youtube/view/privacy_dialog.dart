import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/room.dart';

import 'youtube_search_dialog.dart';

class PrivacyDialog extends StatefulWidget {
  final String roomId;
  final bool? isFromCinema;
  const PrivacyDialog({
    super.key,
    required this.roomId,
    this.isFromCinema,
  });

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  bool? value;

  @override
  void initState() {
    value = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.06,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
          height: MediaQuery.sizeOf(context).height * 0.32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsManager.youtube,
                  scale: 5,
                ),
                10.hBox,
                Text(
                  StringManager.cinemaModeHint.tr(),
                  style: context.bodyMedium.size(12).colorExt(ColorManager.textPrimary),
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Methods.safeLaunchUrl('https://www.youtube.com/t/terms');
                      },
                      child: Text(
                        StringManager.cinemaModeHint2.tr(),
                        style: context.bodyMedium
                            .size(10)
                            .colorExt(Colors.blue)
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                    Checkbox(
                      value: value,
                      onChanged: (_) {
                        setState(() {
                          if (value!) {
                            value = false;
                          } else {
                            value = true;
                          }
                        });
                      },
                      checkColor: ColorManager.headerColor,
                      activeColor: ColorManager.primary,
                      fillColor: WidgetStatePropertyAll(ColorManager.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
                ButtonWidget(
                  onPressed: () async {
                    RoomData.instance.runningCinemaMode = true;
                    if (widget.isFromCinema == true) {
                      if (HiveManager().getData<bool>(KeysManager.USER_BOX,
                              KeysManager.ACCEPT_YOUTUBE_TERMS_KEY) ==
                          null) {
                        if (value == true) {
                          await HiveManager().saveData<bool>(
                            KeysManager.USER_BOX,
                            KeysManager.ACCEPT_YOUTUBE_TERMS_KEY,
                            true,
                          );
                          context.popRoute();
                          bottomDailog(
                            context: context,
                            widget: YoutubeAPISearchDialog(
                              roomData: RoomData.instance.room,
                            ),
                          );
                        } else {
                          Methods.showToast(context,
                              isError: true,
                              message: StringManager.cinemaModeHint2.tr());
                        }
                      } else {
                        context.popRoute();
                        bottomDailog(
                          context: context,
                          widget: YoutubeAPISearchDialog(
                            roomData: RoomData.instance.room,
                          ),
                        );
                      }
                    } else {
                      if (value!) {
                        if (PKWidget.isStartPK.value) {
                          Methods.showToast(context,
                              isError: true,
                              message: StringManager.cantOpenCinemaMode.tr());
                        } else {
                          Future.delayed(const Duration(milliseconds: 50), () {
                            final controller =
                                RoomData.instance.utdController;
                            final mode = controller?.resolveMode('5');
                            controller?.seatController.setupSeats(
                              identity:
                                  MyDataModel.getInstance().id.toString(),
                              seatCount: mode?.seatCount ?? 9,
                              seatMode: controller
                                  .seatController.seatMode.value,
                              modeId: '5',
                            );
                            Navigator.pop(context);
                          });
                        }
                      }
                    }
                  },
                  title: StringManager.ok.tr(),
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  height: 40.h,
                ),
              ],
            ),
          )),
    );
  }
}
